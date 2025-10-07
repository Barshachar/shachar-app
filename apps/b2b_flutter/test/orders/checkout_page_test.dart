import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/fake_session_controller.dart';
import '../test_utils/offline_supabase.dart';
import '../test_harness.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await ensureSupabaseForTests();
  });

  const String orderId = 'order-123';
  final List<CartLine> sampleLines = <CartLine>[
    CartLine(
      id: 'line-1',
      orderId: orderId,
      variantId: 'variant-1',
      vendorCompanyId: 'vendor-1',
      qty: 2,
      unitPrice: 50,
      lineTotal: 100,
      productName: 'עלי תרד',
      variantSku: 'SPIN-001',
    ),
  ];

  Widget buildScope({
    required OrderApprovalState approvalState,
    Locale locale = const Locale('en'),
  }) {
    return makeTestApp(
      CheckoutPage(orderId: orderId),
      locale: locale,
      overrides: [
        cartLinesProvider.overrideWith(
          (Ref ref, String requestedOrderId) async {
            if (requestedOrderId != orderId) {
              return <CartLine>[];
            }
            return sampleLines;
          },
        ),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        sessionControllerProvider.overrideWith(
          (ref) => FakeSessionController(_fakeSession()),
        ),
        orderApprovalProvider.overrideWith(
          (Ref ref, String requestedOrderId) async {
            if (requestedOrderId != orderId) {
              return OrderApprovalState.notRequired(requestedOrderId);
            }
            return approvalState;
          },
        ),
      ],
      extraDelegates: const [MarketplaceLocalizations.delegate],
    );
  }

  testWidgets('checkout summary shows submit button once approved',
      (WidgetTester tester) async {
    final OrderApprovalState approvalState = OrderApprovalState(
      orderId: orderId,
      requiresApproval: true,
      rawStatus: 'approved',
    );

    await tester.pumpWidget(buildScope(approvalState: approvalState));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('checkout_submit_btn')),
      findsOneWidget,
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
