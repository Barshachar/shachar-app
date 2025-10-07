import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('checkoutFormOptionsProvider aggregates repository data', () async {
    final _FakeOrdersRepository repository = _FakeOrdersRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(repository),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
      ],
    );
    addTearDown(container.dispose);

    final CheckoutFormOptions options =
        await container.read(checkoutFormOptionsProvider.future);

    expect(options.billToAccounts, hasLength(2));
    expect(options.billToAccounts.first.title, contains('HQ'));
    expect(options.shipToLocations, hasLength(2));
    expect(options.paymentTerms.map((e) => e.code), contains('net_30'));
    expect(repository.billToCalls, 1);
    expect(repository.shipToCalls, 1);
    expect(repository.paymentTermCalls, 1);
  });

  test(
      'checkoutFormOptionsProvider returns empty lists when company is missing',
      () async {
    final _FakeOrdersRepository repository = _FakeOrdersRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        ordersRepositoryProvider.overrideWithValue(repository),
        quickOrderCompanyIdProvider.overrideWithValue(''),
      ],
    );
    addTearDown(container.dispose);

    final CheckoutFormOptions options =
        await container.read(checkoutFormOptionsProvider.future);

    expect(options.billToAccounts, isEmpty);
    expect(options.shipToLocations, isEmpty);
    expect(options.paymentTerms, isEmpty);
    expect(repository.billToCalls, 0);
    expect(repository.shipToCalls, 0);
    expect(repository.paymentTermCalls, 0);
  });
}

class _FakeOrdersRepository implements OrdersRepository {
  int billToCalls = 0;
  int shipToCalls = 0;
  int paymentTermCalls = 0;

  @override
  Future<List<CheckoutAccountOption>> fetchBillToAccounts({
    required String companyId,
  }) async {
    billToCalls++;
    return <CheckoutAccountOption>[
      CheckoutAccountOption(
        id: '$companyId:primary',
        title: 'Company HQ',
        subtitle: 'Tier A',
        addressLine: '123 Demo St, Tel Aviv',
      ),
      CheckoutAccountOption(
        id: '$companyId:finance',
        title: 'Finance Desk',
        subtitle: 'Attn: Dana Levi',
        addressLine: '56 Rothschild Blvd, Tel Aviv',
      ),
    ];
  }

  @override
  Future<List<CheckoutLocationOption>> fetchShipToLocations({
    required String companyId,
  }) async {
    shipToCalls++;
    return <CheckoutLocationOption>[
      CheckoutLocationOption(
        id: '$companyId:main',
        label: 'Main warehouse',
        addressLine: 'Logistics Park 1, Ashdod',
      ),
      CheckoutLocationOption(
        id: '$companyId:branch',
        label: 'Southern branch',
        addressLine: 'Negev Industrial Zone',
        notes: 'Call before arrival',
      ),
    ];
  }

  @override
  Future<List<CheckoutPaymentTermOption>> fetchPaymentTerms({
    required String companyId,
  }) async {
    paymentTermCalls++;
    return <CheckoutPaymentTermOption>[
      const CheckoutPaymentTermOption(
        id: 'term-net-30',
        code: 'net_30',
        label: 'Net 30',
        description: 'תשלום תוך 30 יום',
        netDays: 30,
      ),
      const CheckoutPaymentTermOption(
        id: 'term-due',
        code: 'due_on_receipt',
        label: 'Due on receipt',
        netDays: 0,
      ),
    ];
  }

  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteLine({required String orderItemId}) async =>
      throw UnimplementedError();

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async =>
      throw UnimplementedError();

  @override
  Future<List<OrderSummary>> fetchOrders() async => throw UnimplementedError();

  @override
  Future<OrderDetail> getOrder(String orderId) async =>
      throw UnimplementedError();

  @override
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  }) async =>
      throw UnimplementedError();

  @override
  Future<String> createDraftIfMissing() async => throw UnimplementedError();

  @override
  Future<String> submitDraftOrder(String orderId) async =>
      throw UnimplementedError();
}
