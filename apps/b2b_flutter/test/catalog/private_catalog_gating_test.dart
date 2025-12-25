import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_session_controller.dart';
import '../test_utils/offline_supabase.dart';
import '../quick_order/quick_order_test_utils.dart' show FakeOrdersRepository;

class _FakeCatalogRepository implements CatalogRepository {
  _FakeCatalogRepository(this.products);

  final List<Product> products;

  @override
  Future<List<Category>> fetchCategories({bool refresh = false}) async =>
      const <Category>[];

  @override
  Future<List<Product>> fetchProducts({bool refresh = false}) async => products;

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
  }) async =>
      const <ProductSearchResult>[];

  @override
  Future<PagedProducts> fetchProductsPage({
    int limit = 20,
    int offset = 0,
    bool refresh = false,
  }) async =>
      PagedProducts(
        items: products,
        hasMore: false,
        nextOffset: products.length,
      );
}

class _FakePriceResolutionService implements PriceResolutionService {
  @override
  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  }) async =>
      {'VAR-2'};

  @override
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async =>
      null;

  @override
  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  }) async =>
      const <num, PriceResolution?>{};
}

Session _fakeSession() => Session.fromJson(<String, dynamic>{
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

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await ensureSupabaseForTests();
  });

  testWidgets('Catalog card shows overlay when variant not in private catalog',
      (tester) async {
    const productId = 'PROD-1';
    final product = Product(
      id: productId,
      vendorCompanyId: 'COMP-1',
      sku: 'SKU-1',
      nameHe: 'מוצר בדיקה',
      nameEn: 'Test Product',
      active: true,
      uom: 'unit',
      packSize: 1,
      moq: 1,
      leadTime: 0,
      variants: const [
        ProductVariant(
          id: 'VAR-1',
          productId: productId,
          attributes: <String, dynamic>{},
          barcode: null,
          active: true,
          uom: 'unit',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider
              .overrideWithValue(_FakeCatalogRepository([product])),
          ordersRepositoryProvider.overrideWithValue(FakeOrdersRepository()),
          priceResolutionServiceProvider
              .overrideWithValue(_FakePriceResolutionService()),
          sessionControllerProvider.overrideWith(
            (ref) => FakeSessionController(_fakeSession()),
          ),
          appConfigProvider.overrideWith(
            (ref) async => const AppConfig(
              supabaseUrl: 'https://example.com',
              supabaseAnonKey: 'anon',
              sentryDsn: '',
              isDebug: true,
            ),
          ),
        ],
        child: const MaterialApp(home: CatalogPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('catalog_not_in_catalog_chip_VAR-1')),
      findsOneWidget,
    );

    final AButton addButton = tester.widget<AButton>(
      find.byKey(const ValueKey('catalog_add_btn_VAR-1')),
    );
    expect(addButton.onPressed, isNull);

    final AQtyStepper stepper = tester.widget<AQtyStepper>(
      find.byType(AQtyStepper),
    );
    expect(stepper.enabled, isFalse);
  });
}
