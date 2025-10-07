import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_session_controller.dart';
import '../test_utils/offline_supabase.dart';
import '../test_harness.dart';

import '../quick_order/quick_order_test_utils.dart'
    show
        FakeCatalogRepository,
        FakeOrdersRepository,
        FakePriceResolutionService;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await ensureSupabaseForTests();
  });

  const String orderId = 'draft-order';
  final List<CartLine> cartLines = <CartLine>[
    CartLine(
      id: 'line-1',
      orderId: orderId,
      variantId: 'VAR-1',
      vendorCompanyId: 'vendor-1',
      qty: 1,
      unitPrice: 10,
      lineTotal: 10,
      productName: 'Variant 1',
    ),
  ];

  final OrderApprovalState approvedState = OrderApprovalState(
    orderId: orderId,
    requiresApproval: true,
    rawStatus: 'approved',
  );

  Widget buildScope() {
    return makeTestApp(
      CheckoutPage(orderId: orderId),
      overrides: [
        catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ordersRepositoryProvider.overrideWithValue(FakeOrdersRepository()),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        priceResolutionServiceProvider.overrideWithValue(
          FakePriceResolutionService(catalog: const <String>{'VAR-2'}),
        ),
        sessionControllerProvider.overrideWith(
          (ref) => FakeSessionController(_fakeSession()),
        ),
        cartLinesProvider.overrideWith(
          (Ref ref, String requestedOrderId) async {
            if (requestedOrderId == orderId) {
              return cartLines;
            }
            return <CartLine>[];
          },
        ),
        orderApprovalProvider.overrideWith(
          (Ref ref, String requestedOrderId) async {
            if (requestedOrderId == orderId) {
              return approvedState;
            }
            return OrderApprovalState.notRequired(requestedOrderId);
          },
        ),
        cartControllerProvider.overrideWith((ref) {
          final controller = CartController(
            ref,
            ref.watch(ordersRepositoryProvider),
            catalogRepository: ref.watch(catalogRepositoryProvider),
          );
          controller.state = const CartState(draftOrderId: orderId);
          return controller;
        }),
      ],
    );
  }

  testWidgets(
      'checkout displays banner and disables submit when catalog mismatch',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildScope());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('checkout_not_in_catalog_banner')),
      findsOneWidget,
    );

    final AButton submitBtn = tester.widget(
      find.byKey(const ValueKey('checkout_submit_btn')),
    );
    expect(submitBtn.onPressed, isNull);
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
