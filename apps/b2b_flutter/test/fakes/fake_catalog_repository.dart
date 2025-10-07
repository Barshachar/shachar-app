import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';

class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository()
      : _products = [
          Product(
            id: 'p1',
            vendorCompanyId: 'v1',
            sku: 'SKU-1',
            nameHe: 'תה נענע',
            nameEn: 'Mint Tea',
            active: true,
            uom: 'EA',
            packSize: 1,
            moq: 1,
            leadTime: 0,
            variants: [
              ProductVariant(
                id: 'var1',
                productId: 'p1',
                attributes: const <String, dynamic>{'flavor': 'mint'},
                barcode: '12345',
                active: true,
                uom: 'EA',
              ),
            ],
          ),
          Product(
            id: 'p2',
            vendorCompanyId: 'v2',
            sku: 'SKU-2',
            nameHe: 'מוצר בדיקה',
            nameEn: 'Sample Product',
            active: true,
            uom: 'EA',
            packSize: 1,
            moq: 1,
            leadTime: 0,
            variants: [
              ProductVariant(
                id: 'var2',
                productId: 'p2',
                attributes: const <String, dynamic>{},
                barcode: null,
                active: true,
                uom: 'EA',
              ),
            ],
          ),
        ];

  final List<Product> _products;

  @override
  Future<List<Category>> fetchCategories({bool refresh = false}) async =>
      const <Category>[];

  @override
  Future<List<Product>> fetchProducts({bool refresh = false}) async {
    return _products;
  }

  @override
  Future<PriceQuote> getPriceQuote({
    required String variantId,
    required int quantity,
  }) async {
    return PriceQuote(
      vendorId: 'v1',
      variantId: variantId,
      currency: 'ILS',
      unitPrice: 0.0,
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
    final query = q.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _products
        : _products.where((product) {
            final heMatch = product.nameHe.contains(q.trim());
            final enMatch = product.nameEn.toLowerCase().contains(query);
            final skuMatch = product.sku.toLowerCase() == query;
            final barcodeMatch = product.variants
                .any((variant) => variant.barcode?.toLowerCase() == query);
            return heMatch || enMatch || skuMatch || barcodeMatch;
          }).toList();

    final results = <ProductSearchResult>[
      for (final product in filtered)
        for (final variant in product.variants)
          ProductSearchResult(
            product: product,
            variant: variant,
            inventoryQty: inStockOnly ? 5.0 : null,
            unitPrice: 12.0,
          ),
    ];

    final safeOffset = offset < 0 ? 0 : offset;
    final paged = safeOffset >= results.length
        ? <ProductSearchResult>[]
        : results.skip(safeOffset).toList();

    if (limit > 0 && paged.length > limit) {
      return paged.take(limit).toList();
    }
    return paged;
  }

  @override
  Future<PagedProducts> fetchProductsPage({
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  }) async {
    final int safeOffset = offset < 0 ? 0 : offset;
    final List<Product> slice = safeOffset >= _products.length
        ? <Product>[]
        : _products.skip(safeOffset).take(limit).toList();
    final bool hasMore = safeOffset + slice.length < _products.length;
    return PagedProducts(
      items: slice,
      hasMore: hasMore,
      nextOffset: safeOffset + slice.length,
    );
  }
}
