import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/order_detail_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  MaterialApp buildApp(Widget home, {Locale locale = const Locale('he')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('he')],
      localizationsDelegates: const [
        MarketplaceLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }

  testWidgets('resend for approval button refreshes approval banner',
      (WidgetTester tester) async {
    final OrderDetail detail = OrderDetail(
      id: 'order-rejected',
      orderNumber: 'PO-9900',
      status: 'approval_rejected',
      subtotal: 320,
      tax: 54.4,
      total: 374.4,
      createdAt: DateTime(2024, 4, 11, 14, 40),
      items: const [],
      shipments: const [],
    );

    final OrderApprovalState rejectedState = OrderApprovalState(
      orderId: detail.id,
      requiresApproval: true,
      rawStatus: 'rejected',
    );

    final OrderApprovalState pendingState = rejectedState.copyWith(
      rawStatus: 'pending',
    );
    OrderApprovalState currentState = rejectedState;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderDetailProvider.overrideWith((ref, orderId) async => detail),
          orderApprovalProvider.overrideWith(
            (ref, orderId) async => currentState,
          ),
          approvalTimelineProvider.overrideWith(
            (ref, String orderId) {
              if (!currentState.requiresApproval || orderId != detail.id) {
                return const [];
              }
              if (currentState.stage == OrderApprovalStage.rejected) {
                return [
                  createUiApprovalStep(
                    id: 'STEP-1',
                    status: 'rejected',
                    approverName: 'Yael Bar',
                    note: 'חסרים מסמכים',
                    decidedAt: DateTime(2024, 4, 11, 15, 00),
                  ),
                ];
              }
              return [
                createUiApprovalStep(
                  id: 'STEP-1',
                  status: 'pending',
                  approverName: 'Yael Bar',
                  decidedAt: DateTime(2024, 4, 11, 15, 10),
                ),
              ];
            },
          ),
          sendOrderForApprovalProvider.overrideWith((ref) {
            return ({required String orderId}) async {
              currentState = pendingState;
              ref.invalidate(orderApprovalProvider(orderId));
              ref.invalidate(approvalTimelineProvider(orderId));
            };
          }),
        ],
        child: buildApp(const OrderDetailPage(orderId: 'order-rejected')),
      ),
    );

    await tester.pumpAndSettle();

    final Finder actionFinder =
        find.byKey(const ValueKey('order_detail_resend_for_approval_btn'));
    expect(actionFinder, findsOneWidget);

    await tester.tap(actionFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('order_detail_pending_approval_banner')),
      findsOneWidget,
    );
  });
}
