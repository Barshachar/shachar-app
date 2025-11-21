import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:offline_toolkit/src/offline/deps.dart';
import 'package:offline_toolkit/src/offline/hive_initializer.dart';

final offlineCacheManagerProvider = Provider<OfflineCacheManager>((ref) {
  final OTDeps deps = ref.watch(otDepsProvider);
  return OfflineCacheManager(deps: deps);
});

class OfflineCacheManager {
  OfflineCacheManager({required this.deps});

  final OTDeps deps;

  bool _initialized = false;
  Box<dynamic>? _box;
  String _activeTenant = _anonymousTenant;

  static const String _anonymousTenant = 'anonymous';

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await HiveInitializer.ensureInitialized();

    _box = await Hive.openBox<dynamic>(MapCache.boxName);
    _initialized = true;
  }

  Future<void> setActiveTenant(String? tenantId) async {
    final String normalized = await _resolveTenant(tenantId);
    if (_activeTenant == normalized) {
      return;
    }
    _activeTenant = normalized;
  }

  Future<void> clearActiveTenant() async {
    if (!_initialized) {
      return;
    }
    final Box<dynamic> box = _box ?? Hive.box<dynamic>(MapCache.boxName);
    final Iterable<dynamic> scopedKeys = box.keys.where(
      (dynamic key) =>
          key is String && key.startsWith(_tenantPrefix(_activeTenant)),
    );
    await box.deleteAll(scopedKeys);
  }

  Future<void> clearAllTenants() async {
    if (!_initialized) {
      return;
    }
    await (_box ?? Hive.box<dynamic>(MapCache.boxName)).clear();
  }

  Future<void> write(String key, Map<String, dynamic> value) async {
    await initialize();
    final Box<dynamic> box = _box ?? Hive.box<dynamic>(MapCache.boxName);
    await box.put(_scopedKey(key), value);
  }

  Map<String, dynamic>? read(String key) {
    if (!_initialized) {
      return null;
    }
    final Box<dynamic> box = _box ?? Hive.box<dynamic>(MapCache.boxName);
    final dynamic result = box.get(_scopedKey(key));
    if (result == null) {
      return null;
    }
    return Map<String, dynamic>.from(result as Map);
  }

  String _scopedKey(String key) => '${_tenantPrefix(_activeTenant)}$key';

  String _tenantPrefix(String tenant) => '$tenant::';

  Future<String> _resolveTenant(String? tenantId) async {
    final String? trimmed = tenantId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    try {
      final String resolved = await deps.tenant.activeCompanyId();
      if (resolved.trim().isNotEmpty) {
        return resolved.trim();
      }
    } catch (error) {
      deps.logger.warn(
        'offline.cache.tenant_resolver_failed',
        {'error': error.toString()},
      );
    }
    return _anonymousTenant;
  }
}

class MapCache {
  static const boxName = '_map_cache';
  static const int cacheVersion = 1;
}
