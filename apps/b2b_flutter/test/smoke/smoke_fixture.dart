import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_controller.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/order_detail_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/vendor_rfq_page.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_shipments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_session_controller.dart';

class SmokeScenario {
  const SmokeScenario(this.name, this.build);

  final String name;
  final Widget Function() build;
}

class SmokeFixture {
  SmokeFixture()
      : _ordersRepository = _SmokeOrdersRepository(),
        _catalogRepository = _SmokeCatalogRepository(_catalogProducts),
        _priceService = _SmokePriceResolutionService(_allowedVariants);

  final _SmokeOrdersRepository _ordersRepository;
  final _SmokeCatalogRepository _catalogRepository;
  final _SmokePriceResolutionService _priceService;

  static final DateTime _now = DateTime(2024, 5, 12, 9, 30);
  static const String _orderId = 'order-smoke-1';
  static final List<CartLine> _cartLines = <CartLine>[
    CartLine(
      id: 'line-1',
      orderId: _orderId,
      variantId: 'variant-green',
      vendorCompanyId: 'vendor-1',
      qty: 2,
      unitPrice: 48.5,
      lineTotal: 97.0,
      productName: 'עלי בזיליקום טרי',
      variantSku: 'HERB-001',
      variantAttributes: const <String, dynamic>{'pack': '500g', 'grade': 'A'},
      productTranslations: const <String, String>{
        'he': 'עלי בזיליקום טרי',
        'en': 'Fresh Basil Leaves',
      },
    ),
    CartLine(
      id: 'line-2',
      orderId: _orderId,
      variantId: 'variant-red',
      vendorCompanyId: 'vendor-2',
      qty: 1,
      unitPrice: 120.0,
      lineTotal: 120.0,
      productName: 'עגבניות שרי',
      variantSku: 'TOM-RED-500',
      variantAttributes: const <String, dynamic>{'pack': '500g'},
      productTranslations: const <String, String>{
        'he': 'עגבניות שרי',
        'en': 'Cherry Tomatoes',
      },
    ),
  ];

  static final OrderDetail _orderDetail = OrderDetail(
    id: _orderId,
    orderNumber: 'PO-240512',
    status: 'in_transit',
    subtotal: 217.0,
    tax: 36.89,
    total: 253.89,
    createdAt: _now,
    items: <OrderItem>[
      OrderItem(
        variantId: 'variant-green',
        vendorCompanyId: 'vendor-1',
        qty: 2,
        unitPrice: 48.5,
        lineTotal: 97.0,
        productName: 'עלי בזיליקום טרי',
        variantSku: 'HERB-001',
      ),
      OrderItem(
        variantId: 'variant-red',
        vendorCompanyId: 'vendor-2',
        qty: 1,
        unitPrice: 120.0,
        lineTotal: 120.0,
        productName: 'עגבניות שרי',
        variantSku: 'TOM-RED-500',
      ),
    ],
    shipments: <OrderShipment>[
      OrderShipment(
        id: 'ship-1',
        vendorCompanyId: 'vendor-1',
        status: 'in_transit',
        createdAt: _now,
        tracking: 'TRACK-123',
        vendorName: 'Green Farms Ltd',
      ),
    ],
  );

  static final List<OrderSummary> _orderSummaries = <OrderSummary>[
    OrderSummary(
      id: _orderId,
      orderNumber: 'PO-240512',
      status: 'in_transit',
      total: 253.89,
      createdAt: _now,
    ),
  ];

  static final List<Product> _catalogProducts = <Product>[
    Product(
      id: 'prod-1',
      vendorCompanyId: 'vendor-1',
      sku: 'HERB-001',
      nameHe: 'עלי בזיליקום טרי',
      nameEn: 'Fresh Basil Leaves',
      active: true,
      uom: 'יח',
      packSize: 1,
      moq: 1,
      leadTime: 1,
      variants: <ProductVariant>[
        ProductVariant(
          id: 'variant-green',
          productId: 'prod-1',
          attributes: const <String, dynamic>{'pack': '500g'},
          barcode: '1234567890',
          active: true,
          uom: 'יח',
        ),
      ],
    ),
    Product(
      id: 'prod-2',
      vendorCompanyId: 'vendor-2',
      sku: 'TOM-RED-500',
      nameHe: 'עגבניות שרי',
      nameEn: 'Cherry Tomatoes',
      active: true,
      uom: 'אריזה',
      packSize: 1,
      moq: 1,
      leadTime: 2,
      variants: <ProductVariant>[
        ProductVariant(
          id: 'variant-red',
          productId: 'prod-2',
          attributes: const <String, dynamic>{'pack': '500g'},
          barcode: '9876543210',
          active: true,
          uom: 'אריזה',
        ),
      ],
    ),
  ];

  static final Set<String> _allowedVariants = _catalogProducts
      .expand((Product product) => product.variants)
      .map((ProductVariant variant) => variant.id)
      .toSet();

  static final List<VendorShipment> _vendorShipments = <VendorShipment>[
    VendorShipment(
      id: 'ship-1',
      orderId: _orderId,
      vendorCompanyId: 'vendor-1',
      status: 'in_transit',
      createdAt: _now,
      tracking: 'TRACK-123',
      vendorName: 'Green Farms Ltd',
    ),
    VendorShipment(
      id: 'ship-2',
      orderId: 'order-2',
      vendorCompanyId: 'vendor-2',
      status: 'ready',
      createdAt: _now.subtract(const Duration(days: 1)),
      tracking: null,
      vendorName: 'Sunrise Produce',
    ),
  ];

  static final List<RfqSummary> _customerRfqs = <RfqSummary>[
    RfqSummary(
      id: 'rfq-1',
      status: 'awaiting_quotes',
      createdAt: _now.subtract(const Duration(days: 2)),
      reference: 'RFQ-2401',
      itemCount: 3,
      quoteCount: 1,
      totalEstimate: 480.0,
    ),
    RfqSummary(
      id: 'rfq-2',
      status: 'quoted',
      createdAt: _now.subtract(const Duration(days: 5)),
      updatedAt: _now.subtract(const Duration(days: 1)),
      reference: 'RFQ-2399',
      itemCount: 2,
      quoteCount: 2,
      latestQuoteStatus: 'expired',
      totalEstimate: 320.0,
    ),
  ];

  static final List<RfqSummary> _vendorRfqs = <RfqSummary>[
    RfqSummary(
      id: 'rfq-v-1',
      status: 'awaiting_quotes',
      createdAt: _now.subtract(const Duration(days: 1)),
      reference: 'RFQ-V-778',
      itemCount: 4,
      totalEstimate: 620.0,
    ),
  ];

  ProviderScope buildCatalogScenario() {
    return ProviderScope(
      overrides: [
        catalogControllerProvider.overrideWith(
          () => _StaticCatalogController(_catalogProducts),
        ),
        catalogRepositoryProvider.overrideWithValue(_catalogRepository),
        priceResolutionServiceProvider.overrideWithValue(_priceService),
        ordersRepositoryProvider.overrideWithValue(_ordersRepository),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
        debugFeaturesEnabledProvider.overrideWithValue(false),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        companyCatalogVariantsProvider.overrideWith(
          (Ref ref, String companyId) async => _allowedVariants,
        ),
        appConfigProvider.overrideWith((Ref ref) async {
          return const AppConfig(
            supabaseUrl: 'https://example.com',
            supabaseAnonKey: 'anon',
            sentryDsn: '',
            isDebug: false,
          );
        }),
      ],
      child: _buildApp(const CatalogPage()),
    );
  }

  ProviderScope buildProductScenario() {
    final Product product = _catalogProducts.first;
    return ProviderScope(
      overrides: [
        productByIdProvider.overrideWith(
          (Ref ref, String id) => id == product.id ? product : null,
        ),
        priceResolutionServiceProvider.overrideWithValue(_priceService),
        catalogRepositoryProvider.overrideWithValue(_catalogRepository),
        ordersRepositoryProvider.overrideWithValue(_ordersRepository),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
      ],
      child: _buildApp(ProductPage(productId: product.id)),
    );
  }

  ProviderScope buildQuickOrderScenario() {
    return ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(_catalogRepository),
        ordersRepositoryProvider.overrideWithValue(_ordersRepository),
        priceResolutionServiceProvider.overrideWithValue(_priceService),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
      ],
      child: _buildApp(
        const QuickOrderPage(
          showFilters: true,
          autoSearch: true,
        ),
      ),
    );
  }

  ProviderScope buildCartScenario() {
    return ProviderScope(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(_ordersRepository),
        catalogRepositoryProvider.overrideWithValue(_catalogRepository),
        priceResolutionServiceProvider.overrideWithValue(_priceService),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        cartLinesProvider.overrideWith(
          (Ref ref, String orderId) async => List<CartLine>.from(_cartLines),
        ),
      ],
      child: _buildApp(const CartPage()),
    );
  }

  ProviderScope buildCheckoutScenario() {
    return ProviderScope(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(_ordersRepository),
        catalogRepositoryProvider.overrideWithValue(_catalogRepository),
        priceResolutionServiceProvider.overrideWithValue(_priceService),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
        cartLinesProvider.overrideWith(
          (Ref ref, String orderId) async => List<CartLine>.from(_cartLines),
        ),
        orderApprovalProvider.overrideWith(
          (Ref ref, String orderId) async => OrderApprovalState(
            orderId: orderId,
            requiresApproval: true,
            rawStatus: 'approved',
          ),
        ),
      ],
      child: _buildApp(CheckoutPage(orderId: _orderId)),
    );
  }

  ProviderScope buildOrderDetailScenario() {
    return ProviderScope(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(_ordersRepository),
        orderDetailProvider.overrideWith(
          (Ref ref, String id) async => _orderDetail,
        ),
        orderApprovalProvider.overrideWith(
          (Ref ref, String orderId) async => OrderApprovalState(
            orderId: orderId,
            requiresApproval: true,
            rawStatus: 'pending',
          ),
        ),
        catalogRepositoryProvider.overrideWithValue(_catalogRepository),
        priceResolutionServiceProvider.overrideWithValue(_priceService),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
      ],
      child: _buildApp(OrderDetailPage(orderId: _orderId)),
    );
  }

  ProviderScope buildOrdersScenario() {
    return ProviderScope(
      overrides: [
        ordersControllerProvider.overrideWithValue(
          AsyncValue.data(_orderSummaries),
        ),
        ordersRepositoryProvider.overrideWithValue(_ordersRepository),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
      ],
      child: _buildApp(const OrdersPage()),
    );
  }

  ProviderScope buildVendorShipmentsScenario() {
    return ProviderScope(
      overrides: [
        vendorShipmentsControllerProvider.overrideWith(
          () => _StaticVendorShipmentsController(_vendorShipments),
        ),
        vendorShipmentsFiltersProvider.overrideWith(
          (Ref ref) => ShipmentsFiltersNotifier(),
        ),
      ],
      child: _buildApp(const VendorShipmentsPage()),
    );
  }

  ProviderScope buildCustomerRfqsScenario() {
    return ProviderScope(
      overrides: [
        customerRfqsProvider.overrideWith(
          (Ref ref) async => _customerRfqs,
        ),
        rfqServiceProvider.overrideWithValue(_FakeRfqService()),
      ],
      child: _buildApp(const CustomerRfqsPage()),
    );
  }

  ProviderScope buildVendorRfqsScenario() {
    return ProviderScope(
      overrides: [
        vendorRfqsProvider.overrideWith(
          (Ref ref) async => _vendorRfqs,
        ),
        rfqServiceProvider.overrideWithValue(_FakeRfqService()),
      ],
      child: _buildApp(const VendorRfqsPage()),
    );
  }

  static MaterialApp _buildApp(Widget home) {
    return MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('he')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        MarketplaceLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: home),
    );
  }

  static Session _fakeSession() => Session.fromJson(<String, dynamic>{
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
}

class _StaticCatalogController extends CatalogController {
  _StaticCatalogController(this._products);

  final List<Product> _products;

  CatalogState _state() => CatalogState(
        items: _products,
        hasMore: false,
        nextOffset: _products.length,
      );

  @override
  Future<CatalogState> build() async => _state();

  @override
  Future<void> refresh() async {
    state = AsyncValue.data(_state());
  }

  @override
  Future<void> loadMore() async {
    // No-op for static catalog.
  }
}

class _StaticVendorShipmentsController extends VendorShipmentsController {
  _StaticVendorShipmentsController(this._shipments);

  final List<VendorShipment> _shipments;

  @override
  Future<List<VendorShipment>> build() async => _shipments;
}

class _SmokeOrdersRepository implements OrdersRepository {
  _SmokeOrdersRepository();

  static const String _draftId = 'draft-order-id';

  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async {}

  @override
  Future<void> deleteLine({required String orderItemId}) async {}

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

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async =>
      SmokeFixture._cartLines
          .map((CartLine line) => line)
          .toList(growable: false);

  @override
  Future<List<OrderSummary>> fetchOrders() async =>
      SmokeFixture._orderSummaries.toList(growable: false);

  @override
  Future<OrderDetail> getOrder(String orderId) async =>
      SmokeFixture._orderDetail;

  @override
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  }) async {}

  @override
  Future<String> createDraftIfMissing() async => _draftId;

  @override
  Future<String> submitDraftOrder(String orderId) async =>
      SmokeFixture._orderDetail.id;
}

class _SmokeCatalogRepository implements CatalogRepository {
  _SmokeCatalogRepository(this._products);

  final List<Product> _products;

  @override
  Future<List<Category>> fetchCategories({bool refresh = false}) async =>
      const <Category>[];

  @override
  Future<List<Product>> fetchProducts({bool refresh = false}) async =>
      _products.toList(growable: false);

  @override
  Future<PriceQuote> getPriceQuote({
    required String variantId,
    required int quantity,
  }) async {
    return PriceQuote(
      vendorId: 'vendor-quote',
      variantId: variantId,
      currency: '₪',
      unitPrice: 42.0,
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
    final String query = q.trim().toLowerCase();
    final Iterable<Product> filtered = query.isEmpty
        ? _products
        : _products.where((Product product) {
            final String he = product.nameHe.toLowerCase();
            final String en = product.nameEn.toLowerCase();
            return he.contains(query) ||
                en.contains(query) ||
                product.sku.toLowerCase().contains(query);
          });
    return <ProductSearchResult>[
      for (final Product product in filtered)
        for (final ProductVariant variant in product.variants)
          ProductSearchResult(
            product: product,
            variant: variant,
            inventoryQty: 10,
            unitPrice: 42.0,
          ),
    ];
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

class _SmokePriceResolutionService implements PriceResolutionService {
  _SmokePriceResolutionService(this.allowedVariants);

  final Set<String> allowedVariants;

  @override
  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  }) async =>
      allowedVariants;

  @override
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async {
    return PriceResolution(
      price: 42.0,
      currency: '₪',
      vatIncluded: false,
      source: 'catalog',
      basePrice: 42.0,
    );
  }

  @override
  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  }) async {
    return <num, PriceResolution?>{
      for (final num quantity in qtys)
        quantity: await resolve(
          companyId: companyId,
          variantId: variantId,
          qty: quantity,
          at: at,
        ),
    };
  }
}

class _FakeRfqService extends RfqRemoteService {
  _FakeRfqService() : super(Supabase.instance.client);

  @override
  Future<List<RfqSummary>> fetchRfqsForCurrentUser() async =>
      SmokeFixture._customerRfqs;

  @override
  Future<List<RfqSummary>> fetchRfqsForVendor() async =>
      SmokeFixture._vendorRfqs;

  @override
  Future<RfqDetail> fetchRfqDetail(String rfqId) async {
    return RfqDetail(
      id: rfqId,
      status: 'awaiting_quotes',
      createdAt: DateTime.now().toUtc(),
      items: const <RfqItem>[],
      quotes: const <RfqQuote>[],
      messages: const <RfqMessage>[],
    );
  }
}
