import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_price_service.dart';
export '../fakes/fake_price_service.dart' show FakePriceResolutionService;
import '../test_harness.dart';

class FakeCatalogRepository implements CatalogRepository {
  @override
  Future<List<Category>> fetchCategories({bool refresh = false}) async =>
      const <Category>[];

  @override
  Future<List<Product>> fetchProducts({bool refresh = false}) async =>
      const <Product>[];

  @override
  Future<PriceQuote> getPriceQuote({
    required String variantId,
    required int quantity,
  }) async {
    return const PriceQuote(
      vendorId: 'vendor',
      variantId: 'variant',
      currency: 'ILS',
      unitPrice: 0,
      minQty: 1,
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
  }) async =>
      const <ProductSearchResult>[];

  @override
  Future<PagedProducts> fetchProductsPage({
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  }) async =>
      const PagedProducts(
        items: <Product>[],
        hasMore: false,
        nextOffset: 0,
      );
}

class FakeOrdersRepository implements OrdersRepository {
  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async {}

  @override
  Future<void> deleteLine({required String orderItemId}) async {}

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async =>
      const <CartLine>[];

  @override
  Future<List<OrderSummary>> fetchOrders() async => const <OrderSummary>[];

  @override
  Future<OrderDetail> getOrder(String orderId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  }) async {}

  @override
  Future<String> createDraftIfMissing() async => 'draft-order';

  @override
  Future<String> submitDraftOrder(String orderId) async => orderId;

  @override
  Future<List<CheckoutAccountOption>> fetchBillToAccounts({
    required String companyId,
  }) async =>
      const <CheckoutAccountOption>[];

  @override
  Future<List<CheckoutLocationOption>> fetchShipToLocations({
    required String companyId,
  }) async =>
      const <CheckoutLocationOption>[];

  @override
  Future<List<CheckoutPaymentTermOption>> fetchPaymentTerms({
    required String companyId,
  }) async =>
      const <CheckoutPaymentTermOption>[];
}

ProductSearchResult buildQuickOrderResult(String variantId) {
  final Product base = Product(
    id: 'PROD-$variantId',
    vendorCompanyId: 'vendor',
    sku: variantId,
    nameHe: 'שם $variantId',
    nameEn: 'Name $variantId',
    active: true,
    uom: 'EA',
    packSize: 1,
    moq: 1,
    leadTime: 0,
    variants: const <ProductVariant>[],
  );
  final ProductVariant variant = ProductVariant(
    id: variantId,
    productId: base.id,
    attributes: const <String, dynamic>{},
    barcode: variantId,
    active: true,
    uom: 'EA',
  );
  final Product product = base.copyWith(variants: <ProductVariant>[variant]);
  return ProductSearchResult(product: product, variant: variant);
}

Widget buildQuickOrderHarness(Set<String> allowed) {
  return makeTestApp(
    Scaffold(
      body: Center(
        child: SizedBox(
          width: 1440,
          height: 1024,
          child: const QuickOrderPage(
            showFilters: false,
            autoSearch: false,
          ),
        ),
      ),
    ),
    overrides: [
      catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
      ordersRepositoryProvider.overrideWithValue(FakeOrdersRepository()),
      quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
      priceResolutionServiceProvider.overrideWithValue(
        FakePriceResolutionService(catalog: allowed),
      ),
    ],
  );
}

dynamic seedQuickOrderRows(WidgetTester tester, List<dynamic> rows) {
  final dynamic state = tester.state(find.byType(QuickOrderPage));
  state.debugSetBulkRows(rows);
  return state;
}

Future<void> pumpQuickOrderWithRows(
  WidgetTester tester, {
  required Set<String> allowedCatalog,
  required List<dynamic> rows,
  required List<ProductSearchResult> results,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  tester.view.physicalSize = const Size(1440, 1024);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(buildQuickOrderHarness(allowedCatalog));
  await tester.pumpAndSettle();
  final dynamic state = seedQuickOrderRows(tester, rows);
  state.debugSetResults(results);
  final String companyId = state.ref.read(quickOrderCompanyIdProvider);
  assert(
    companyId.isNotEmpty,
    'quickOrderCompanyIdProvider returned empty company id in tests',
  );
  if (companyId.isNotEmpty) {
    await state.ref
        .read(quickOrderCompanyCatalogProvider(companyId).future)
        .catchError((_) => null);
    final AsyncValue<Set<String>?> catalogState =
        state.ref.read(quickOrderCompanyCatalogProvider(companyId));
    assert(
      catalogState.maybeWhen(
        data: (catalog) => catalog != null,
        orElse: () => false,
      ),
      'quickOrderCompanyCatalogProvider did not resolve in test harness',
    );
  }
  await tester.pumpAndSettle();
  final dynamic firstRow = rows.isNotEmpty ? rows.first : null;
  final String? variantId = firstRow?.match?.variant?.id as String?;
  if (variantId != null) {
    assert(
      find
          .byKey(ValueKey('qo_row_not_in_catalog_$variantId'))
          .evaluate()
          .isNotEmpty,
      'Quick order review is missing not-in-catalog chip for $variantId',
    );
  }
}

Finder findQuickOrderReviewTable() => find.byType(DataTable);
