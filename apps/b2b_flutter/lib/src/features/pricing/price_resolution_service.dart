import 'dart:collection';

import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool suppressPriceResolutionLogs = false;

class PriceResolution {
  const PriceResolution({
    required this.price,
    required this.currency,
    required this.vatIncluded,
    required this.source,
    this.basePrice,
  });

  final double price;
  final String currency;
  final bool vatIncluded;
  final String source;
  final double? basePrice;
}

abstract class PriceResolutionService {
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  });

  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  });

  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  });
}

final offlinePricingFallbackProvider = Provider<bool>((ref) {
  final configAsync = ref.watch(appConfigProvider);
  return configAsync.maybeWhen(
    data: (config) => config.featureEnabled('offlinePricingFallback'),
    orElse: () => false,
  );
});

final priceResolutionServiceProvider = Provider<PriceResolutionService>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  ref.watch(offlinePricingFallbackProvider);
  return SupabasePriceResolutionService(
    client,
    offlineFallbackResolver: () => ref.read(offlinePricingFallbackProvider),
  );
});

class SupabasePriceResolutionService implements PriceResolutionService {
  SupabasePriceResolutionService(
    this._client, {
    Duration ttl = const Duration(seconds: 60),
    int maxEntries = 128,
    DateTime Function()? clock,
    Future<Map<String, dynamic>?> Function(
            String functionName, Map<String, dynamic> params)?
        rpcOverride,
    bool Function()? offlineFallbackResolver,
  })  : _ttl = ttl,
        _maxEntries = maxEntries,
        _clock = clock ?? DateTime.now,
        _rpcOverride = rpcOverride,
        _offlineFallbackResolver =
            offlineFallbackResolver ?? _defaultOfflineFallback;

  static bool _defaultOfflineFallback() => false;

  final SupabaseClient _client;
  final Duration _ttl;
  final int _maxEntries;
  final DateTime Function() _clock;
  final Future<Map<String, dynamic>?> Function(
      String functionName, Map<String, dynamic> params)? _rpcOverride;
  final bool Function() _offlineFallbackResolver;
  final LinkedHashMap<_CacheKey, _CacheEntry> _cache = LinkedHashMap();
  final LinkedHashMap<String, _CatalogCacheEntry> _catalogCache =
      LinkedHashMap();

  bool get _offlineFallbackEnabled {
    try {
      return _offlineFallbackResolver();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async {
    final num normalizedQty = qty <= 0 ? 1 : qty;
    final _CacheKey key = _CacheKey(
      companyId: companyId,
      variantId: variantId,
      qty: normalizedQty,
    );

    final DateTime now = _clock();
    final _CacheEntry? cached = _cache.remove(key);
    if (cached != null && now.difference(cached.timestamp) <= _ttl) {
      _cache[key] = cached.copyWith(timestamp: now);
      return cached.value;
    }

    final PriceResolution? fresh = await _fetchPrice(
      companyId: companyId,
      variantId: variantId,
      qty: normalizedQty,
      at: at,
    );
    if (fresh != null) {
      _insertCache(key, fresh, now);
    }
    return fresh;
  }

  @override
  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  }) async {
    final Map<num, PriceResolution?> results = <num, PriceResolution?>{};
    final Set<num> unique = LinkedHashSet<num>.from(qtys);
    for (final num quantity in unique) {
      results[quantity] = await resolve(
        companyId: companyId,
        variantId: variantId,
        qty: quantity,
        at: at,
      );
    }
    return results;
  }

  @override
  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  }) async {
    if (companyId.isEmpty) {
      return null;
    }

    final DateTime now = _clock();
    final _CatalogCacheEntry? cached = _catalogCache.remove(companyId);
    if (cached != null && now.difference(cached.timestamp) <= _ttl) {
      _catalogCache[companyId] = cached.copyWith(timestamp: now);
      return cached.value;
    }

    try {
      final Map<String, dynamic> params = <String, dynamic>{
        'p_company': companyId,
      };
      if (at != null) {
        params['p_at'] = at.toUtc().toIso8601String();
      }

      final dynamic raw = await _runCatalogRpc(params);
      final List<dynamic>? rows = _catalogResponseToList(raw);
      if (rows == null) {
        return null;
      }

      final Set<String> variants = <String>{};
      for (final dynamic row in rows) {
        final String? variantId = _extractCatalogVariantId(row);
        if (variantId != null) {
          variants.add(variantId);
        }
      }

      final Set<String> snapshot = Set<String>.unmodifiable(variants);
      _insertCatalogCache(companyId, snapshot, now);
      if (!suppressPriceResolutionLogs) {
        debugPrint('[CATALOG] company=$companyId variants=${snapshot.length}');
      }
      return snapshot;
    } catch (error, stackTrace) {
      if (!suppressPriceResolutionLogs) {
        debugPrint('Company catalog load failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (_offlineFallbackEnabled) {
        return null;
      }
      rethrow;
    }
  }

  void _insertCache(_CacheKey key, PriceResolution value, DateTime timestamp) {
    if (_cache.length >= _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _CacheEntry(value: value, timestamp: timestamp);
  }

  void _insertCatalogCache(
    String companyId,
    Set<String> value,
    DateTime timestamp,
  ) {
    if (_catalogCache.length >= _maxEntries) {
      _catalogCache.remove(_catalogCache.keys.first);
    }
    _catalogCache[companyId] =
        _CatalogCacheEntry(value: value, timestamp: timestamp);
  }

  Future<PriceResolution?> _fetchPrice({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async {
    try {
      final Map<String, dynamic> params = <String, dynamic>{
        'p_company': companyId,
        'p_variant': variantId,
        'p_qty': qty,
      };
      if (at != null) {
        params['p_at'] = at.toUtc().toIso8601String();
      }

      final Map<String, dynamic>? row = await _runRpc(params);
      if (row == null || row.isEmpty) {
        return null;
      }

      final double? price = _asDouble(row['price'] ?? row['unit_price']);
      final String? currency = _asString(row['currency']);
      final bool vatIncluded = _asBool(row['vat_included']);
      final String? source = _asString(row['pricing_source'] ?? '');
      final double? basePrice =
          _asDouble(row['base_price'] ?? row['base_unit_price']);

      if (price == null || currency == null || source == null) {
        return null;
      }

      return PriceResolution(
        price: price,
        currency: currency,
        vatIncluded: vatIncluded,
        source: source,
        basePrice: basePrice,
      );
    } catch (error, stackTrace) {
      debugPrint('Price resolve failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (_offlineFallbackEnabled) {
        return null;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _runRpc(Map<String, dynamic> params) async {
    final rpcOverride = _rpcOverride;
    if (rpcOverride != null) {
      return rpcOverride('rpc_resolve_price', params);
    }
    final PostgrestFilterBuilder<Map<String, dynamic>> builder =
        _client.rpc<Map<String, dynamic>>(
      'rpc_resolve_price',
      params: params,
    );
    return builder.maybeSingle();
  }

  Future<dynamic> _runCatalogRpc(Map<String, dynamic> params) {
    final rpcOverride = _rpcOverride;
    if (rpcOverride != null) {
      return rpcOverride('rpc_company_catalog', params);
    }

    final PostgrestFilterBuilder<List<dynamic>> builder =
        _client.rpc<List<dynamic>>(
      'rpc_company_catalog',
      params: params,
    );
    return builder;
  }

  List<dynamic>? _catalogResponseToList(dynamic raw) {
    if (raw == null) {
      return null;
    }

    if (raw is List<dynamic>) {
      return raw;
    }

    if (raw is Iterable<dynamic>) {
      return List<dynamic>.from(raw);
    }

    if (raw is PostgrestResponse) {
      final List<dynamic>? fromResponse =
          _catalogResponseToList(raw.data as dynamic);
      if (fromResponse != null) {
        return fromResponse;
      }
    }

    if (raw is Map) {
      final Map<dynamic, dynamic> map = raw;
      const List<String> preferredKeys = <String>['data', 'rows', 'result'];
      for (final String key in preferredKeys) {
        if (map.containsKey(key)) {
          final List<dynamic>? nested =
              _catalogResponseToList(map[key] as dynamic);
          if (nested != null) {
            return nested;
          }
        }
      }
      for (final dynamic value in map.values) {
        final List<dynamic>? nested = _catalogResponseToList(value as dynamic);
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  String? _extractCatalogVariantId(dynamic row) {
    if (row is Map<String, dynamic>) {
      final String? fromVariantId = _asString(row['variant_id']);
      if (fromVariantId != null) {
        return fromVariantId;
      }
      return _asString(row['id']);
    }
    if (row is Map) {
      final Map<dynamic, dynamic> map = row;
      final String? fromVariantId = _asString(map['variant_id']);
      if (fromVariantId != null) {
        return fromVariantId;
      }
      return _asString(map['id']);
    }
    return _asString(row);
  }

  double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  String? _asString(Object? value) {
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  bool _asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}

class _CacheKey {
  const _CacheKey({
    required this.companyId,
    required this.variantId,
    required this.qty,
  });

  final String companyId;
  final String variantId;
  final num qty;

  @override
  bool operator ==(Object other) {
    return other is _CacheKey &&
        other.companyId == companyId &&
        other.variantId == variantId &&
        other.qty == qty;
  }

  @override
  int get hashCode => Object.hash(companyId, variantId, qty);
}

class _CacheEntry {
  const _CacheEntry({required this.value, required this.timestamp});

  final PriceResolution value;
  final DateTime timestamp;

  _CacheEntry copyWith({DateTime? timestamp}) {
    return _CacheEntry(
      value: value,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class _CatalogCacheEntry {
  const _CatalogCacheEntry({required this.value, required this.timestamp});

  final Set<String> value;
  final DateTime timestamp;

  _CatalogCacheEntry copyWith({DateTime? timestamp}) {
    return _CatalogCacheEntry(
      value: value,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
