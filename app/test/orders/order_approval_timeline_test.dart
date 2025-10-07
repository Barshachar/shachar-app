import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
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

  testWidgets('order detail shows approval timeline',
      (WidgetTester tester) async {
    final OrderDetail detail = OrderDetail(
      id: 'order-123',
      orderNumber: 'PO-9001',
      status: 'pending_approval',
      subtotal: 100,
      tax: 17,
      total: 117,
      createdAt: DateTime(2024, 4, 10, 9, 30),
      items: const [],
      shipments: const [],
    );

    final OrderApprovalState approvalState = OrderApprovalState(
      orderId: detail.id,
      requiresApproval: true,
      rawStatus: 'pending',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderDetailProvider.overrideWith((ref, orderId) async => detail),
          orderApprovalProvider.overrideWith(
            (ref, orderId) async => approvalState,
          ),
          approvalTimelineProvider.overrideWith(
            (ref, String orderId) {
              if (orderId != detail.id) {
                return const [];
              }
              return [
                createUiApprovalStep(
                  id: 'STEP-A',
                  status: 'approved',
                  approverName: 'Dana Cohen',
                  note: 'אושר ללא הערות',
                  decidedAt: DateTime(2024, 4, 10, 10, 00),
                ),
                createUiApprovalStep(
                  id: 'STEP-B',
                  status: 'pending',
                  approverName: 'Yossi Levi',
                  decidedAt: DateTime(2024, 4, 10, 10, 15),
                ),
              ];
            },
          ),
        ],
        child: buildApp(const OrderDetailPage(orderId: 'order-123')),
      ),
    );

    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('order_approval_timeline')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('approval_step_chip_approved_STEP-A')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('approval_step_chip_pending_STEP-B')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('order_detail_pending_approval_banner')),
      findsOneWidget,
    );
  });
}
