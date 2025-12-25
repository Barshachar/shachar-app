import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_recommendations_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters excluded and allowed variants for recommendations', () async {
    final Product productA = _buildProduct(
      id: 'p1',
      sku: 'SKU-1',
      nameEn: 'Alpha',
      leadTime: 1,
      variants: [
        _buildVariant(id: 'v1', productId: 'p1'),
      ],
    );
    final Product productB = _buildProduct(
      id: 'p2',
      sku: 'SKU-2',
      nameEn: 'Bravo',
      leadTime: 1,
      variants: [
        _buildVariant(id: 'v2', productId: 'p2'),
      ],
    );
    final Product productC = _buildProduct(
      id: 'p3',
      sku: 'SKU-3',
      nameEn: 'Charlie',
      moq: 2,
      variants: [
        _buildVariant(id: 'v3', productId: 'p3'),
        _buildVariant(id: 'v4', productId: 'p3'),
      ],
    );

    final ProviderContainer container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          _FakeCatalogRepository([productA, productB, productC]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final CatalogRecommendationRequest request = CatalogRecommendationRequest(
      excludedVariantIds: const {'v1'},
      allowedVariantIds: const {'v2', 'v4'},
      limit: 4,
    );

    final List<CatalogRecommendation> recommendations =
        await container.read(catalogRecommendationsProvider(request).future);

    expect(recommendations.map((r) => r.variant.id).toList(), ['v2', 'v4']);
    expect(
      recommendations.first.reason,
      CatalogRecommendationReason.fastDelivery,
    );
  });
}

Product _buildProduct({
  required String id,
  required String sku,
  required String nameEn,
  List<ProductVariant> variants = const [],
  int packSize = 1,
  int moq = 1,
  int leadTime = 0,
}) {
  return Product(
    id: id,
    vendorCompanyId: 'vendor-$id',
    sku: sku,
    nameHe: '',
    nameEn: nameEn,
    active: true,
    uom: 'EA',
    packSize: packSize,
    moq: moq,
    leadTime: leadTime,
    variants: variants,
  );
}

ProductVariant _buildVariant({
  required String id,
  required String productId,
}) {
  return ProductVariant(
    id: id,
    productId: productId,
    attributes: const <String, dynamic>{},
    active: true,
    uom: 'EA',
  );
}

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.items);

  final List<Product> items;

  @override
  Future<List<Category>> fetchCategories({bool refresh = false}) async {
    return const <Category>[];
  }

  @override
  Future<List<Product>> fetchProducts({bool refresh = false}) async {
    return items;
  }

  @override
  Future<PagedProducts> fetchProductsPage({
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  }) async {
    return PagedProducts(
      items: items,
      hasMore: false,
      nextOffset: 0,
    );
  }

  @override
  Future<PriceQuote> getPriceQuote({
    required String variantId,
    required int quantity,
  }) async {
    return PriceQuote(
      vendorId: 'vendor',
      variantId: variantId,
      currency: 'ILS',
      unitPrice: 0,
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
    return const <ProductSearchResult>[];
  }
}
