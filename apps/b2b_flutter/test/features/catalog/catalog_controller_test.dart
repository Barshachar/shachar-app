import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  CatalogRepository buildRepository({Set<int> failOffsets = const {}}) {
    final List<Product> products = List<Product>.generate(
      25,
      (int index) {
        final String id = 'product-$index';
        return Product(
          id: id,
          vendorCompanyId: 'vendor-${index % 3}',
          sku: 'SKU-$index',
          nameHe: 'שם מוצר $index',
          nameEn: 'Product $index',
          active: true,
          uom: 'unit',
          packSize: 1,
          moq: 1,
          leadTime: 0,
          variants: <ProductVariant>[
            ProductVariant(
              id: 'variant-$index',
              productId: id,
              attributes: const <String, dynamic>{},
              active: true,
              uom: 'unit',
            ),
          ],
        );
      },
    );
    return _FakeCatalogRepository(products, failOffsets: failOffsets);
  }

  test('loads first page with hasMore flag when more products exist', () async {
    final CatalogRepository repository = buildRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final CatalogState state =
        await container.read(catalogControllerProvider.future);

    expect(state.items, hasLength(20));
    expect(state.hasMore, isTrue);
    expect(state.nextOffset, 20);
  });

  test('loadMore appends additional items and updates nextOffset', () async {
    final CatalogRepository repository = buildRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final CatalogController controller =
        container.read(catalogControllerProvider.notifier);
    await container.read(catalogControllerProvider.future);

    await controller.loadMore();
    final CatalogState? state =
        container.read(catalogControllerProvider).asData?.value;

    expect(state, isNotNull);
    expect(state!.items, hasLength(25));
    expect(state.hasMore, isFalse);
    expect(state.nextOffset, 25);
  });

  test('loadMore rethrows errors while preserving current state', () async {
    final CatalogRepository repository =
        buildRepository(failOffsets: <int>{20});
    final ProviderContainer container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final CatalogController controller =
        container.read(catalogControllerProvider.notifier);
    await container.read(catalogControllerProvider.future);

    expect(
      () => controller.loadMore(),
      throwsA(isA<Exception>()),
    );

    final CatalogState? state =
        container.read(catalogControllerProvider).asData?.value;
    expect(state, isNotNull);
    expect(state!.items, hasLength(20));
    expect(state.hasMore, isTrue);
    expect(state.nextOffset, 20);
  });
}

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this._products, {required this.failOffsets});

  final List<Product> _products;
  final Set<int> failOffsets;

  @override
  Future<List<Category>> fetchCategories({bool refresh = false}) async =>
      const <Category>[];

  @override
  Future<List<Product>> fetchProducts({bool refresh = false}) async =>
      _products;

  @override
  Future<PagedProducts> fetchProductsPage({
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  }) async {
    if (failOffsets.contains(offset)) {
      throw Exception('forced failure at offset $offset');
    }
    final int safeLimit = limit <= 0 ? 20 : limit;
    final int safeOffset = offset < 0 ? 0 : offset;
    if (safeOffset >= _products.length) {
      return PagedProducts(
        items: const <Product>[],
        hasMore: false,
        nextOffset: _products.length,
      );
    }
    final int endExclusive = (safeOffset + safeLimit) > _products.length
        ? _products.length
        : (safeOffset + safeLimit);
    final List<Product> slice =
        _products.sublist(safeOffset, endExclusive).toList(growable: false);
    final bool hasMore = endExclusive < _products.length;
    return PagedProducts(
      items: slice,
      hasMore: hasMore,
      nextOffset: safeOffset + slice.length,
    );
  }

  @override
  Future<PriceQuote> getPriceQuote({
    required String variantId,
    required int quantity,
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }
}
