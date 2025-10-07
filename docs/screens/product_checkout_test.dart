import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/order_detail_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_page.dart';

import '../../test/qa/qa_screenshot.dart';
import '../../test/qa/qa_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  testWidgets('capture orders list and detail screenshots', (tester) async {
    setDeviceSize(tester, width: 1280, height: 800);

    final DateTime now = DateTime(2024, 9, 1, 10, 30);
    final OrderSummary summary = OrderSummary(
      id: 'order-1',
      orderNumber: 'PO-2042',
      status: 'fulfilled',
      total: 1170.0,
      createdAt: now,
    );
    final OrderDetail detail = OrderDetail(
      id: 'order-1',
      orderNumber: 'PO-2042',
      status: 'fulfilled',
      subtotal: 1000.0,
      tax: 170.0,
      total: 1170.0,
      createdAt: now,
      items: [
        OrderItem(
          variantId: 'var-1',
          vendorCompanyId: 'vendor-1',
          qty: 2,
          unitPrice: 500.0,
          lineTotal: 1000.0,
          productName: 'עלי נענע טריים',
          variantSku: 'HERB-002-A',
        ),
      ],
      shipments: [
        OrderShipment(
          id: 'ship-1',
          vendorCompanyId: 'vendor-1',
          status: 'in_transit',
          createdAt: now.add(const Duration(days: 1)),
          tracking: 'TRACK-1',
          vendorName: 'Fresh Greens Ltd',
        ),
      ],
    );
    final List<CartLine> cartLines = <CartLine>[
      CartLine(
        id: 'line-1',
        orderId: detail.id,
        variantId: 'var-1',
        vendorCompanyId: 'vendor-1',
        qty: 2,
        unitPrice: 500.0,
        lineTotal: 1000.0,
        productName: 'עלי נענע טריים',
        variantSku: 'HERB-002-A',
        variantAttributes: const <String, dynamic>{
          'pack': '10 יחידות',
        },
        productTranslations: const <String, String>{
          'he': 'עלי נענע טריים',
          'en': 'Fresh Mint Leaves',
        },
      ),
    ];
    final OrderApprovalState approvalState = OrderApprovalState(
      orderId: detail.id,
      requiresApproval: true,
      rawStatus: 'approved',
      note: 'אושר על ידי מנהל הרכש',
      sentAt: now.subtract(const Duration(days: 1)),
      resolvedAt: now,
    );

    final _FakeOrdersRepository fakeOrdersRepository = _FakeOrdersRepository(
      summaries: <OrderSummary>[summary],
      detail: detail,
      cartLines: cartLines,
      approvalState: approvalState,
    );

    final AppConfig config = AppConfig(
      supabaseUrl: 'https://offline.dev.supabase.local',
      supabaseAnonKey: 'anon-key',
      sentryDsn: '',
      isDebug: true,
      features: const <String, dynamic>{
        'offlinePricingFallback': true,
      },
    );

    final overrides = [
      appConfigProvider.overrideWithValue(AsyncValue.data(config)),
      ordersRepositoryProvider.overrideWithValue(fakeOrdersRepository),
      orderApprovalProvider.overrideWith(
        (Ref ref, String orderId) async =>
            fakeOrdersRepository.approvalFor(orderId),
      ),
      cartLinesProvider.overrideWith(
        (Ref ref, String orderId) async =>
            fakeOrdersRepository.cartLinesFor(orderId),
      ),
      catalogRepositoryProvider.overrideWithValue(
        const _FakeCatalogRepository(),
      ),
      cartControllerProvider.overrideWith((Ref ref) {
        final CartController controller = CartController(
          ref,
          ref.watch(ordersRepositoryProvider),
          catalogRepository: ref.watch(catalogRepositoryProvider),
        );
        // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
        controller.state = CartState(draftOrderId: detail.id);
        return controller;
      }),
    ];

    Future<void> pumpWith(Widget child) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: _buildApp(child),
        ),
      );
      await tester.pump();
    }

    await pumpWith(const OrdersPage());
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('orders_list_root')),
      timeout: const Duration(seconds: 15),
    );
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('orders_list_capture')),
      timeout: const Duration(seconds: 15),
    );
    await tester.runAsync(() async {
      await savePngFromFinder(
        tester,
        target: find.byKey(const ValueKey('orders_list_capture')),
        path: 'docs/screens/orders/orders_list.png',
      );
    });

    await pumpWith(OrderDetailPage(orderId: detail.id));
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('order_detail_root')),
      timeout: const Duration(seconds: 15),
    );
    await pumpUntilFound(
      tester,
      find.byKey(const ValueKey('order_detail_capture')),
      timeout: const Duration(seconds: 15),
    );
    await tester.runAsync(() async {
      await savePngFromFinder(
        tester,
        target: find.byKey(const ValueKey('order_detail_capture')),
        path: 'docs/screens/orders/order_detail.png',
      );
    });
  });
}

MaterialApp _buildApp(Widget home) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('he'),
    supportedLocales: const <Locale>[Locale('he'), Locale('en')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AColors.primary),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(centerTitle: true),
    ),
    home: home,
  );
}

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository({
    required this.summaries,
    required this.detail,
    required this.cartLines,
    required this.approvalState,
  });

  final List<OrderSummary> summaries;
  final OrderDetail detail;
  final List<CartLine> cartLines;
  final OrderApprovalState approvalState;

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
      cartLinesFor(orderId);

  @override
  Future<List<OrderSummary>> fetchOrders() async => summaries;

  @override
  Future<OrderDetail> getOrder(String orderId) async => detail;

  @override
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  }) async {}

  @override
  Future<String> submitDraftOrder(String orderId) async => orderId;

  @override
  Future<String> createDraftIfMissing() async => detail.id;

  @override
  Future<List<CheckoutAccountOption>> fetchBillToAccounts({
    required String companyId,
  }) async =>
      const <CheckoutAccountOption>[
        CheckoutAccountOption(
          id: 'billto-primary',
          title: 'Headquarters',
          subtitle: 'Finance team',
          addressLine: '123 Demo St, Tel Aviv',
        ),
      ];

  @override
  Future<List<CheckoutLocationOption>> fetchShipToLocations({
    required String companyId,
  }) async =>
      const <CheckoutLocationOption>[
        CheckoutLocationOption(
          id: 'shipto-main',
          label: 'Main warehouse',
          addressLine: 'Logistics Park, Ashdod',
        ),
      ];

  @override
  Future<List<CheckoutPaymentTermOption>> fetchPaymentTerms({
    required String companyId,
  }) async =>
      const <CheckoutPaymentTermOption>[
        CheckoutPaymentTermOption(
          id: 'net-30',
          code: 'net_30',
          label: 'Net 30',
          netDays: 30,
        ),
      ];

  List<CartLine> cartLinesFor(String orderId) =>
      orderId == detail.id ? cartLines : const <CartLine>[];

  OrderApprovalState approvalFor(String orderId) => orderId == detail.id
      ? approvalState
      : OrderApprovalState.notRequired(orderId);
}

class _FakeCatalogRepository implements CatalogRepository {
  const _FakeCatalogRepository();

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
    return PriceQuote(
      vendorId: 'vendor-1',
      variantId: variantId,
      currency: 'ILS',
      unitPrice: 500.0,
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
