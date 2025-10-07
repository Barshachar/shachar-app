import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_session_controller.dart';
import '../test_utils/offline_supabase.dart';

import '../fakes/fake_catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await ensureSupabaseForTests();
  });

  testWidgets('cart quantity stepper updates line quantity',
      (WidgetTester tester) async {
    final _FakeOrdersRepository ordersRepository = _FakeOrdersRepository();
    final CatalogRepository catalogRepository = FakeCatalogRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(ordersRepository),
          catalogRepositoryProvider.overrideWithValue(catalogRepository),
          sessionControllerProvider.overrideWith(
            (ref) => FakeSessionController(_fakeSession()),
          ),
        ],
        child: const MaterialApp(
          home: CartPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    const ValueKey<String> qtyStepperKey =
        ValueKey<String>('cart_qty_stepper_line-1');

    final Finder stepperFinder = find.byKey(qtyStepperKey);
    expect(stepperFinder, findsOneWidget);
    expect(
      tester.widget<AQtyStepper>(stepperFinder).qty,
      1,
    );

    final Finder minusButtonFinder = find.descendant(
      of: stepperFinder,
      matching: find.byIcon(Icons.remove_circle_outline),
    );
    final Finder plusButtonFinder = find.descendant(
      of: stepperFinder,
      matching: find.byIcon(Icons.add_circle_outline),
    );
    expect(minusButtonFinder, findsOneWidget);
    expect(plusButtonFinder, findsOneWidget);

    await tester.tap(plusButtonFinder);
    await tester.pumpAndSettle();

    expect(
      tester.widget<AQtyStepper>(stepperFinder).qty,
      2,
    );

    await tester.tap(minusButtonFinder);
    await tester.pumpAndSettle();

    expect(
      tester.widget<AQtyStepper>(stepperFinder).qty,
      1,
    );
  });
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

class _FakeOrdersRepository implements OrdersRepository {
  _FakeOrdersRepository()
      : _lines = <String, List<CartLine>>{
          _draftId: <CartLine>[
            CartLine(
              id: 'line-1',
              orderId: _draftId,
              variantId: 'variant-1',
              vendorCompanyId: 'vendor-1',
              qty: 1,
              unitPrice: 10,
              lineTotal: 10,
              productName: 'Mint Tea',
              variantSku: 'SKU-1',
              variantAttributes: const <String, dynamic>{},
              productTranslations: const <String, String>{
                'he': 'תה נענע',
                'en': 'Mint Tea',
              },
            ),
          ],
        };

  static const String _draftId = 'draft-order';
  final Map<String, List<CartLine>> _lines;

  @override
  Future<List<OrderSummary>> fetchOrders() async => const <OrderSummary>[];

  @override
  Future<OrderDetail> getOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<String> submitDraftOrder(String orderId) async => orderId;

  @override
  Future<String> createDraftIfMissing() async => _draftId;

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async {
    final List<CartLine>? stored = _lines[orderId];
    if (stored == null) {
      return <CartLine>[];
    }
    return stored.map((CartLine line) => line).toList();
  }

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
    final List<CartLine>? stored = _lines[_draftId];
    if (stored == null) {
      return;
    }
    final int index =
        stored.indexWhere((CartLine line) => line.id == orderItemId);
    if (index == -1) {
      return;
    }
    stored[index] = stored[index].copyWithQty(qty);
  }

  @override
  Future<void> deleteLine({required String orderItemId}) async {
    final List<CartLine>? stored = _lines[_draftId];
    if (stored == null) {
      return;
    }
    stored.removeWhere((CartLine line) => line.id == orderItemId);
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
