import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/offline/cache/offline_cache_manager.dart';
import 'package:ashachar_marketplace/src/features/pricing/data/pricing_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final client = Supabase.instance.client;
  final cache = ref.watch(offlineCacheManagerProvider);
  final pricing = ref.watch(pricingRepositoryProvider);
  return SupabaseCatalogRepository(
      client: client, cache: cache, pricingRepository: pricing);
});

abstract class CatalogRepository {
  Future<List<Category>> fetchCategories({bool refresh = false});
  Future<List<Product>> fetchProducts({bool refresh = false});
  Future<PagedProducts> fetchProductsPage({
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  });
  Future<PriceQuote> getPriceQuote(
      {required String variantId, required int quantity});
  Future<List<ProductSearchResult>> searchProducts({
    String q = '',
    String? categoryId,
    bool inStockOnly = false,
    double? minPrice,
    double? maxPrice,
    int limit = 50,
    int offset = 0,
  });
}

class ProductSearchResult {
  ProductSearchResult({
    required this.product,
    required this.variant,
    this.inventoryQty,
    this.unitPrice,
  });

  final Product product;
  final ProductVariant variant;
  final double? inventoryQty;
  final double? unitPrice;
}

class SupabaseCatalogRepository implements CatalogRepository {
  SupabaseCatalogRepository({
    required this.client,
    required this.cache,
    required this.pricingRepository,
  });

  final SupabaseClient client;
  final OfflineCacheManager cache;
  final PricingRepository pricingRepository;

  static const _categoriesCacheKey = 'catalog_categories_v1';
  static const _productsCacheKey = 'catalog_products_v1';
  static const _productsPageCachePrefix = 'catalog_products_page_v1';

  Map<String, dynamic> _asMap(dynamic value) => safeCatalogMap(value);

  List<Map<String, dynamic>> _coerceRows(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<Object?, Object?>>()
          .map((raw) => Map<String, dynamic>.from(raw))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  String _asString(dynamic value) => value == null ? '' : value.toString();

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  Product _mapProductRow(dynamic rawRow) {
    final row = _asMap(rawRow);
    final rawName = row['name'];
    String nameHe;
    String nameEn;
    if (rawName is Map) {
      final nameMap = _asMap(rawName);
      final heRaw = nameMap['he'];
      final enRaw = nameMap['en'];
      final heString = heRaw is String ? heRaw : null;
      final enString = enRaw is String ? enRaw : null;
      nameHe = heString ?? enString ?? '';
      nameEn = enString ?? heString ?? '';
    } else if (rawName is String) {
      nameHe = rawName;
      nameEn = rawName;
    } else {
      nameHe = '';
      nameEn = '';
    }

    final rawVariants = row['product_variants'];
    final Iterable<dynamic> variantsRawList =
        rawVariants is List ? rawVariants : const <dynamic>[];
    final variants = variantsRawList.map((variantRaw) {
      final variant = _asMap(variantRaw);
      final attributes = _asMap(variant['attributes_json']);
      final barcode = (variant['barcode'] as String?)?.trim();
      return ProductVariant(
        id: _asString(variant['id']),
        productId: _asString(variant['product_id']),
        attributes: attributes,
        barcode: (barcode?.isEmpty ?? true) ? null : barcode,
        active: (variant['active'] as bool?) ?? true,
        uom: (variant['uom'] as String?) ?? '',
      );
    }).toList();

    return Product(
      id: _asString(row['id']),
      vendorCompanyId: _asString(row['vendor_company_id']),
      sku: (row['sku'] as String?) ?? '',
      nameHe: nameHe,
      nameEn: nameEn,
      active: (row['active'] as bool?) ?? true,
      uom: (row['uom'] as String?) ?? '',
      packSize: _asInt(row['pack_size']),
      moq: _asInt(row['moq']),
      leadTime: _asInt(row['lead_time']),
      variants: variants,
    );
  }

  String _escapePattern(String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  @override
  Future<List<Category>> fetchCategories({bool refresh = false}) async {
    if (!refresh) {
      final cached = cache.read(_categoriesCacheKey);
      if (cached != null) {
        return (cached['items'] as List<dynamic>)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    final response = await client.from('categories').select();
    final items = (response as List<dynamic>).map((rawRow) {
      final row = _asMap(rawRow);
      final nameMap = _asMap(row['name']);
      final nameHe = (nameMap['he'] ?? nameMap['en'] ?? '').toString();
      final nameEn = (nameMap['en'] ?? nameMap['he'] ?? '').toString();
      return Category(
        id: row['id'] as String,
        nameHe: nameHe,
        nameEn: nameEn,
        parentId: row['parent_id'] as String?,
      );
    }).toList();
    await cache.write(_categoriesCacheKey, {
      'items': items
          .map((e) => {
                'id': e.id,
                'nameHe': e.nameHe,
                'nameEn': e.nameEn,
                'parentId': e.parentId,
              })
          .toList(),
    });
    return items;
  }

  @override
  Future<List<Product>> fetchProducts({bool refresh = false}) async {
    if (!refresh) {
      final cached = cache.read(_productsCacheKey);
      if (cached != null) {
        return (cached['items'] as List<dynamic>)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    final PostgrestList response = await client
        .from('products')
        .select(
          'id,vendor_company_id,sku,name,active,uom,pack_size,moq,lead_time,'
          'product_variants(id,product_id,attributes_json,barcode,uom,active)',
        )
        .eq('active', true)
        .order('id');

    final rows = _coerceRows(response);

    final products = rows.map(_mapProductRow).toList();

    await cache.write(_productsCacheKey, {
      'items': products.map((e) => e.toJson()).toList(),
    });
    return products;
  }

  @override
  Future<PagedProducts> fetchProductsPage({
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  }) async {
    final int safeLimit = limit <= 0 ? 20 : limit;
    final int safeOffset = offset < 0 ? 0 : offset;
    final String cacheKey =
        '${_productsPageCachePrefix}_${safeOffset}_$safeLimit';

    if (!refresh) {
      final dynamic cachedRaw = cache.read(cacheKey);
      if (cachedRaw is Map<String, dynamic>) {
        final Map<String, dynamic> cached = cachedRaw;
        final List<Product> cachedItems = (cached['items'] as List<dynamic>)
            .map((dynamic e) =>
                Product.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final bool cachedHasMore = cached['hasMore'] as bool? ?? false;
        final int cachedNextOffset =
            cached['nextOffset'] as int? ?? (safeOffset + cachedItems.length);
        return PagedProducts(
          items: cachedItems,
          hasMore: cachedHasMore,
          nextOffset: cachedNextOffset,
        );
      }
    }

    final int upperBound = safeOffset + safeLimit;
    final PostgrestList response = await client
        .from('products')
        .select(
          'id,vendor_company_id,sku,name,active,uom,pack_size,moq,lead_time,'
          'product_variants(id,product_id,attributes_json,barcode,uom,active)',
        )
        .eq('active', true)
        .order('id')
        .range(safeOffset, upperBound);

    final List<Map<String, dynamic>> rows = _coerceRows(response);
    bool hasMore = false;
    List<Map<String, dynamic>> effectiveRows = rows;
    if (rows.length > safeLimit) {
      hasMore = true;
      effectiveRows = rows.sublist(0, safeLimit);
    }

    final List<Product> products =
        effectiveRows.map(_mapProductRow).toList(growable: false);
    final int nextOffset = safeOffset + products.length;

    await cache.write(cacheKey, {
      'items': products.map((Product e) => e.toJson()).toList(),
      'hasMore': hasMore,
      'nextOffset': nextOffset,
    });

    return PagedProducts(
      items: products,
      hasMore: hasMore,
      nextOffset: nextOffset,
    );
  }

  @override
  Future<PriceQuote> getPriceQuote(
      {required String variantId, required int quantity}) async {
    final effective = await pricingRepository.resolveEffectivePrice(
      variantId: variantId,
      quantity: quantity,
    );
    return PriceQuote(
      vendorId: effective.vendorId,
      variantId: effective.variantId,
      currency: effective.currency,
      unitPrice: effective.unitPrice,
      minQty: quantity,
    );
  }

  @override
  Future<List<ProductSearchResult>> searchProducts({
    String q = '',
    String? categoryId,
    bool inStockOnly = false,
    double? minPrice,
    double? maxPrice,
    int limit = 50,
    int offset = 0,
  }) async {
    final int effectiveLimit = limit <= 0 ? 50 : limit;
    final int effectiveOffset = offset < 0 ? 0 : offset;
    final String trimmedQuery = q.trim();

    var request = client
        .from('products')
        .select(
          'id,vendor_company_id,category_id,sku,name,active,uom,pack_size,moq,lead_time,'
          'product_variants(id,product_id,attributes_json,barcode,uom,active)',
        )
        .eq('active', true);

    if (categoryId != null && categoryId.isNotEmpty) {
      request = request.eq('category_id', categoryId);
    }

    if (trimmedQuery.isNotEmpty) {
      final String escaped = _escapePattern(trimmedQuery);
      final String pattern = '%$escaped%';
      request = request.or(
        'name->>he.ilike.$pattern,name->>en.ilike.$pattern,sku.ilike.$pattern',
      );
    }

    final PostgrestList response = await request
        .order('id')
        .range(effectiveOffset, effectiveOffset + effectiveLimit - 1);
    final List<Product> products =
        _coerceRows(response).map(_mapProductRow).toList();

    Map<String, double> inventoryMap = <String, double>{};
    if (inStockOnly && products.isNotEmpty) {
      // TODO(catalog): add `.gt('inventory_qty', 0)` when the column is
      // available on the products view.
      final List<String> variantIds = <String>{
        for (final product in products)
          for (final variant in product.variants) variant.id
      }.toList();

      if (variantIds.isNotEmpty) {
        final PostgrestList inventoryResponse = await client
            .from('inventory')
            .select('variant_id, qty')
            .inFilter('variant_id', variantIds);
        inventoryMap = {
          for (final Map<String, dynamic> row in _coerceRows(inventoryResponse))
            _asString(row['variant_id']): (row['qty'] is num)
                ? (row['qty'] as num).toDouble()
                : double.tryParse(row['qty'].toString()) ?? 0.0,
        };
      }
    }

    final List<ProductSearchResult> results = <ProductSearchResult>[];

    for (final Product product in products) {
      for (final ProductVariant variant in product.variants) {
        final double? qty =
            inventoryMap.isEmpty ? null : inventoryMap[variant.id];
        if (inStockOnly && ((qty ?? 0) <= 0)) {
          continue;
        }

        double? unitPrice;
        bool priceRejected = false;
        final bool shouldFilterByPrice = minPrice != null || maxPrice != null;

        try {
          final effective = await pricingRepository.resolveEffectivePrice(
            variantId: variant.id,
            quantity: 1,
          );
          unitPrice = effective.unitPrice;
          if ((minPrice != null && unitPrice < minPrice) ||
              (maxPrice != null && unitPrice > maxPrice)) {
            priceRejected = true;
          }
        } catch (_) {
          if (shouldFilterByPrice) {
            priceRejected = true;
          } else {
            unitPrice = null;
          }
        }

        if (priceRejected) {
          continue;
        }

        results.add(ProductSearchResult(
          product: product,
          variant: variant,
          inventoryQty: qty,
          unitPrice: unitPrice,
        ));
      }
    }

    if (results.length > effectiveLimit) {
      return results.take(effectiveLimit).toList();
    }
    return results;
  }
}
