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
  const _FakeOrdersRepository();

  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async {}

  @override
  Future<String> createDraftIfMissing() async => 'draft-1';

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async =>
      const <CartLine>[];

  @override
  Future<List<OrderSummary>> fetchOrders() async => const <OrderSummary>[];

  @override
  Future<OrderDetail> getOrder(String orderId) async =>
      throw UnimplementedError();

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
  }) async =>
      throw UnimplementedError();

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
    state = const CartState(draftOrderId: 'draft-1');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ensureSupabaseForTests();
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    required bool debugEnabled,
  }) async {
    final _FakeOrdersRepository orders = const _FakeOrdersRepository();
    final _FakeCatalogRepository catalog = const _FakeCatalogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AsyncValue.data(
              AppConfig(
                supabaseUrl: 'https://example.supabase.co',
                supabaseAnonKey: 'anon',
                sentryDsn: '',
                isDebug: false,
              ),
            ),
          ),
          appLoggerProvider.overrideWithValue(Logger('debug-gating-test')),
          debugFeaturesEnabledProvider.overrideWithValue(debugEnabled),
          ordersRepositoryProvider.overrideWithValue(orders),
          catalogRepositoryProvider.overrideWithValue(catalog),
          cartControllerProvider.overrideWith(
            (ref) => _FakeCartController(ref, orders, catalog),
          ),
          cartLinesProvider
              .overrideWith((ref, orderId) async => const <CartLine>[]),
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
    await tester.pumpAndSettle();
  }

  testWidgets('debug entrypoint is visible when debug features enabled',
      (WidgetTester tester) async {
    await pumpHome(tester, debugEnabled: true);
    expect(find.byKey(const ValueKey('debug_entrypoint')), findsOneWidget);
  });

  testWidgets('debug entrypoint hidden when debug features disabled',
      (WidgetTester tester) async {
    await pumpHome(tester, debugEnabled: false);
    expect(find.byKey(const ValueKey('debug_entrypoint')), findsNothing);
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
