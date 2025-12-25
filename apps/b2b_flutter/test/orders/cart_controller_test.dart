import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:postgrest/postgrest.dart';

import '../fakes/fake_catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ProductVariant variant = ProductVariant(
    id: 'variant-1',
    productId: 'product-1',
    attributes: const <String, dynamic>{'size': '1kg'},
    barcode: '1234567890',
    active: true,
    uom: 'EA',
  );

  late _FakeOrdersRepository repository;
  late FakeCatalogRepository catalogRepository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeOrdersRepository();
    catalogRepository = FakeCatalogRepository();
    container = ProviderContainer(overrides: [
      ordersRepositoryProvider.overrideWithValue(repository),
      catalogRepositoryProvider.overrideWithValue(catalogRepository),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  test('ensureDraftOrder only creates draft once', () async {
    final CartController controller =
        container.read(cartControllerProvider.notifier);
    repository.createDraftCalls = 0; // ignore warmup call

    final String id1 = await controller.ensureDraftOrder();
    final String id2 = await controller.ensureDraftOrder();

    expect(id1, equals(repository.draftId));
    expect(id2, equals(repository.draftId));
    expect(repository.createDraftCalls, 1);
  });

  test('addVariant aggregates qty via repository', () async {
    final CartController controller =
        container.read(cartControllerProvider.notifier);
    repository.createDraftCalls = 0; // ignore warmup call

    await controller.addVariant(variant, qty: 2);
    await controller.addVariant(variant, qty: 1);

    final _FakeLine line = repository.lineForVariant('variant-1');
    expect(line.qty, 3);
    expect(repository.updateCalls, 1);
  });

  test('addBySkuOrBarcode finds variant by sku', () async {
    final CartController controller =
        container.read(cartControllerProvider.notifier);
    repository.createDraftCalls = 0; // ignore warmup call

    await controller.addBySkuOrBarcode('SKU-1', qty: 2);

    final List<CartLine> lines =
        await repository.fetchCartLines(repository.draftId);
    expect(lines, isNotEmpty);
    expect(lines.first.qty, 2);
  });

  test('updateLineQty with zero deletes line', () async {
    final CartController controller =
        container.read(cartControllerProvider.notifier);
    repository.createDraftCalls = 0; // ignore warmup call

    await controller.addVariant(variant, qty: 1);
    final _FakeLine line = repository.lineForVariant('variant-1');

    await controller.updateLineQty(line.id, 0);

    expect(repository.deleteCalls, 1);
    expect(repository.hasLines, isFalse);
  });

  testWidgets('submitDraftAndNavigate returns order id',
      (WidgetTester tester) async {
    repository = _FakeOrdersRepository();
    catalogRepository = FakeCatalogRepository();

    late CartController controller;
    late BuildContext capturedContext;

    final GoRouter router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            final ProviderContainer scope =
                ProviderScope.containerOf(context, listen: false);
            controller = scope.read(cartControllerProvider.notifier);
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
        GoRoute(
          path: '/customer/orders/:id',
          builder: (BuildContext context, GoRouterState state) {
            return const SizedBox.shrink();
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(repository),
          catalogRepositoryProvider.overrideWithValue(catalogRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    repository.createDraftCalls = 0; // ignore warmup call

    final String orderId =
        await controller.submitDraftAndNavigate(capturedContext);

    expect(orderId, repository.draftId);
    expect(router.routeInformationProvider.value.uri.toString(),
        '/customer/orders/${repository.draftId}');
  });

  testWidgets('submitDraftAndNavigate retries once when draft closed',
      (WidgetTester tester) async {
    final _RetryingOrdersRepository retryRepository =
        _RetryingOrdersRepository();
    catalogRepository = FakeCatalogRepository();

    late CartController controller;
    late BuildContext capturedContext;

    final GoRouter router = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            final ProviderContainer scope =
                ProviderScope.containerOf(context, listen: false);
            controller = scope.read(cartControllerProvider.notifier);
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
        GoRoute(
          path: '/customer/orders/:id',
          builder: (BuildContext context, GoRouterState state) {
            return const SizedBox.shrink();
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(retryRepository),
          catalogRepositoryProvider.overrideWithValue(catalogRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    retryRepository.createDraftCalls = 0; // ignore warmup call

    final String orderId =
        await controller.submitDraftAndNavigate(capturedContext);

    expect(orderId, 'submitted-${retryRepository.lastDraftId}');
    expect(retryRepository.createDraftCalls, 1);
    expect(retryRepository.submitDraftCalls, 2);
    expect(router.routeInformationProvider.value.uri.toString(),
        '/customer/orders/submitted-${retryRepository.lastDraftId}');
  });
}

class _FakeOrdersRepository implements OrdersRepository {
  final Map<String, _FakeLine> _lines = <String, _FakeLine>{};
  int createDraftCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  final String draftId = 'draft-order-id';

  bool get hasLines => _lines.isNotEmpty;

  _FakeLine lineForVariant(String variantId) {
    return _lines.values.firstWhere(
      (line) => line.variantId == variantId,
      orElse: () => throw StateError('Variant not found'),
    );
  }

  @override
  Future<List<OrderSummary>> fetchOrders() async => const <OrderSummary>[];

  @override
  Future<OrderDetail> getOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<String> submitDraftOrder(String orderId) async => orderId;

  @override
  Future<String> createDraftIfMissing() async {
    createDraftCalls += 1;
    return draftId;
  }

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async {
    return _lines.values
        .where((line) => line.orderId == orderId)
        .map(
          (line) => CartLine(
            id: line.id,
            orderId: line.orderId,
            variantId: line.variantId,
            vendorCompanyId: line.vendorCompanyId,
            qty: line.qty,
            unitPrice: 10,
            lineTotal: line.qty * 11.7,
            productName: 'Test Product',
            variantSku: 'SKU',
            variantAttributes: const <String, dynamic>{'size': '1kg'},
            productTranslations: const <String, String>{
              'he': 'מוצר בדיקה',
              'en': 'Test Product',
            },
          ),
        )
        .toList();
  }

  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async {
    final String key = '$orderId::$variantId';
    final _FakeLine? existing = _lines[key];
    if (existing != null) {
      await updateLineQty(orderItemId: existing.id, qty: existing.qty + qty);
      return;
    }
    final _FakeLine newLine = _FakeLine(
      id: 'line-${_lines.length + 1}',
      orderId: orderId,
      variantId: variantId,
      vendorCompanyId: 'vendor-1',
      qty: qty,
    );
    _lines[key] = newLine;
  }

  @override
  Future<void> updateLineQty(
      {required String orderItemId, required double qty}) async {
    updateCalls += 1;
    final _FakeLine existing =
        _lines.values.firstWhere((line) => line.id == orderItemId);
    _lines['${existing.orderId}::${existing.variantId}'] =
        existing.copyWith(qty: qty);
  }

  @override
  Future<void> deleteLine({required String orderItemId}) async {
    deleteCalls += 1;
    final Iterable<String> keysToRemove = _lines.entries
        .where((entry) => entry.value.id == orderItemId)
        .map((entry) => entry.key)
        .toList();
    for (final String key in keysToRemove) {
      _lines.remove(key);
    }
  }

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

class _RetryingOrdersRepository implements OrdersRepository {
  int createDraftCalls = 0;
  int submitDraftCalls = 0;
  String _activeDraftId = 'draft-initial';
  bool _shouldFailNextSubmit = true;

  String get lastDraftId => _activeDraftId;

  @override
  Future<List<OrderSummary>> fetchOrders() async => const <OrderSummary>[];

  @override
  Future<OrderDetail> getOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<String> submitDraftOrder(String orderId) async {
    submitDraftCalls += 1;
    if (_shouldFailNextSubmit) {
      _shouldFailNextSubmit = false;
      _activeDraftId = 'draft-refreshed';
      throw const PostgrestException(
        message: 'Order is not draft',
        code: 'P0001',
        details: 'order status not draft',
      );
    }
    return 'submitted-$orderId';
  }

  @override
  Future<String> createDraftIfMissing() async {
    createDraftCalls += 1;
    return _activeDraftId;
  }

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async =>
      const <CartLine>[];

  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteLine({
    required String orderItemId,
  }) async {
    throw UnimplementedError();
  }

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

class _FakeLine {
  _FakeLine({
    required this.id,
    required this.orderId,
    required this.variantId,
    required this.vendorCompanyId,
    required this.qty,
  });

  final String id;
  final String orderId;
  final String variantId;
  final String vendorCompanyId;
  final double qty;

  _FakeLine copyWith({double? qty}) {
    return _FakeLine(
      id: id,
      orderId: orderId,
      variantId: variantId,
      vendorCompanyId: vendorCompanyId,
      qty: qty ?? this.qty,
    );
  }
}
