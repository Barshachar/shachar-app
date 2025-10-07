import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/logger/app_logger.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';
import 'package:ashachar_marketplace/src/features/customer/customer_home_page.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_session_controller.dart';
import '../test_utils/offline_supabase.dart';

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository(this.lines);

  final List<CartLine> lines;

  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async {}

  @override
  Future<String> createDraftIfMissing() async => 'draft-order-1';

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async => lines;

  @override
  Future<List<OrderSummary>> fetchOrders() async => <OrderSummary>[
        OrderSummary(
          id: 'order-1',
          orderNumber: 'PO-1001',
          status: 'fulfilled',
          total: 512.0,
          createdAt: DateTime(2024, 9, 1),
        ),
      ];

  @override
  Future<OrderDetail> getOrder(String orderId) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteLine({required String orderItemId}) async {}

  @override
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  }) async {}

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

class _FakeCatalogRepository implements CatalogRepository {
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

class _FakeCartController extends CartController {
  // ignore: use_super_parameters
  _FakeCartController(
    dynamic ref,
    OrdersRepository repository,
    CatalogRepository catalog,
  ) : super(ref, repository, catalogRepository: catalog) {
    state = const CartState(draftOrderId: 'draft-order-1');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ensureSupabaseForTests();
  });

  testWidgets('home page shows shortcuts and continue order CTA',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));

    final List<CartLine> lines = <CartLine>[
      CartLine(
        id: 'line-1',
        orderId: 'draft-order-1',
        variantId: 'variant-1',
        vendorCompanyId: 'vendor-1',
        qty: 3,
        unitPrice: 42,
        lineTotal: 126,
        productName: 'תבלין גורמה',
        variantSku: 'SKU-001',
      ),
    ];

    final _FakeOrdersRepository fakeOrdersRepository =
        _FakeOrdersRepository(lines);
    final _FakeCatalogRepository fakeCatalogRepository =
        _FakeCatalogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AsyncValue.data(
              AppConfig(
                supabaseUrl: 'https://example.supabase.co',
                supabaseAnonKey: 'anon-key',
                sentryDsn: '',
                isDebug: true,
              ),
            ),
          ),
          appLoggerProvider.overrideWithValue(Logger('test')),
          debugFeaturesEnabledProvider.overrideWithValue(true),
          ordersRepositoryProvider.overrideWithValue(fakeOrdersRepository),
          catalogRepositoryProvider.overrideWithValue(fakeCatalogRepository),
          cartControllerProvider.overrideWith(
            (ref) => _FakeCartController(
                ref, fakeOrdersRepository, fakeCatalogRepository),
          ),
          cartLinesProvider.overrideWith((ref, orderId) async => lines),
          sessionControllerProvider.overrideWith(
            (ref) => FakeSessionController(_stubSession()),
          ),
        ],
        child: MaterialApp(
          supportedLocales: const [Locale('he'), Locale('en')],
          locale: const Locale('he'),
          localizationsDelegates: const [
            MarketplaceLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData.from(
            colorScheme: ColorScheme.fromSeed(seedColor: AColors.primary),
          ),
          home: const CustomerHomePage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('home_campaign_banner')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('home_current_order_card')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('home_continue_order_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_quick_order_chip')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_saved_lists_chip')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_reorder_order_order-1')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('home_view_all_orders_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_menu_catalog')), findsWidgets);
    expect(find.byKey(const ValueKey('home_menu_promotions')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_menu_orders')), findsOneWidget);
  });
}

Session _stubSession() => Session.fromJson(<String, dynamic>{
      'access_token': 'token',
      'token_type': 'bearer',
      'refresh_token': 'refresh',
      'expires_in': 3600,
      'expires_at':
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
      'user': <String, dynamic>{
        'id': 'user-id',
        'aud': 'authenticated',
        'email': 'tester@example.com',
        'app_metadata': <String, dynamic>{
          'provider': 'email',
          'providers': <String>['email'],
          'company_id': 'COMP-1',
        },
        'user_metadata': const <String, dynamic>{},
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    })!;
