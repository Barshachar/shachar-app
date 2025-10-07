import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
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

  const String orderId = 'approval-order-1';
  final CartLine sampleLine = CartLine(
    id: 'line-1',
    orderId: orderId,
    variantId: 'VAR-1',
    vendorCompanyId: 'vendor-1',
    qty: 2,
    unitPrice: 25,
    lineTotal: 50,
    productName: 'בדיקת מוצר',
  );

  testWidgets('checkout enforces approvals gating flow',
      (WidgetTester tester) async {
    final ValueNotifier<OrderApprovalState> approvalNotifier =
        ValueNotifier<OrderApprovalState>(OrderApprovalState(
      orderId: orderId,
      requiresApproval: true,
      rawStatus: 'draft',
    ));
    addTearDown(approvalNotifier.dispose);

    final Widget app = ProviderScope(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
        ordersRepositoryProvider.overrideWithValue(FakeOrdersRepository()),
        quickOrderCompanyIdProvider.overrideWithValue('COMP-1'),
        priceResolutionServiceProvider.overrideWithValue(
          FakePriceResolutionService(<String>{'VAR-1'}),
        ),
        cartLinesProvider.overrideWith(
          (Ref ref, String requestedOrderId) async {
            if (requestedOrderId != orderId) {
              return <CartLine>[];
            }
            return <CartLine>[sampleLine];
          },
        ),
        orderApprovalProvider.overrideWith(
          (Ref ref, String requestedOrderId) async {
            if (requestedOrderId != orderId) {
              return OrderApprovalState.notRequired(requestedOrderId);
            }
            return approvalNotifier.value;
          },
        ),
        sessionControllerProvider.overrideWith(
          (Ref ref) => FakeSessionController(_fakeSession()),
        ),
        sendOrderForApprovalProvider.overrideWith(
          (Ref ref) {
            return ({required String orderId}) async {
              approvalNotifier.value =
                  approvalNotifier.value.copyWith(rawStatus: 'pending');
              ref.invalidate(orderApprovalProvider(orderId));
            };
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
      child: MaterialApp(
        home: CheckoutPage(orderId: orderId),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('checkout_requires_approval_banner')),
      findsOneWidget,
    );

    final Finder sendFinder =
        find.byKey(const ValueKey('checkout_send_for_approval_btn'));
    expect(sendFinder, findsOneWidget);
    final AButton sendBtn = tester.widget(sendFinder);
    expect(sendBtn.onPressed, isNotNull);

    await tester.ensureVisible(sendFinder);
    await tester.tap(sendFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('checkout_pending_approval_banner')),
      findsOneWidget,
    );

    approvalNotifier.value =
        approvalNotifier.value.copyWith(rawStatus: 'approved');
    final BuildContext context = tester.element(find.byType(CheckoutPage));
    final ProviderContainer container =
        ProviderScope.containerOf(context, listen: false);
    container.invalidate(orderApprovalProvider(orderId));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('checkout_approved_banner')),
      findsOneWidget,
    );

    final AButton submitBtn = tester.widget(
      find.byKey(const ValueKey('checkout_submit_btn')),
    );
    expect(submitBtn.onPressed, isNotNull);
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
