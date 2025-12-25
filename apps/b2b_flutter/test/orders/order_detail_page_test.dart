import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/widgets/approval_status_banner.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/order_detail_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';
import 'package:ashachar_marketplace/src/features/returns/data/supabase_return_request_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../test_utils/fake_return_request_repository.dart';

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

  testWidgets('order detail shows formatted totals and sections',
      (WidgetTester tester) async {
    final DateTime now = DateTime(2024, 4, 10, 9, 30);
    final OrderDetail detail = OrderDetail(
      id: 'order-1',
      orderNumber: 'PO-2042',
      status: 'completed',
      subtotal: 1000,
      tax: 170,
      total: 1170,
      createdAt: now,
      items: [
        OrderItem(
          id: 'item-1',
          variantId: 'var-1',
          vendorCompanyId: 'vendor-1',
          qty: 2,
          unitPrice: 500,
          lineTotal: 1170,
          productName: 'עלי נענע',
          variantSku: 'HERB-002-A',
        ),
      ],
      shipments: [
        OrderShipment(
          id: 'ship-1',
          vendorCompanyId: 'vendor-1',
          status: 'in_transit',
          createdAt: now,
          tracking: 'TRACK-1',
          vendorName: 'ספק ירקות',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderDetailProvider.overrideWith((ref, id) async => detail),
          returnRequestRepositoryProvider.overrideWithValue(
            FakeReturnRequestRepository(),
          ),
        ],
        child: buildApp(const OrderDetailPage(orderId: 'order-1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PO-2042'), findsOneWidget);
    expect(find.textContaining('₪'), findsWidgets);
    expect(find.textContaining('מע״מ'), findsOneWidget);

    final Finder shipmentsVendorFinder = find.textContaining('ספק ירקות');
    await tester.scrollUntilVisible(
      shipmentsVendorFinder,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(shipmentsVendorFinder, findsOneWidget);
    expect(find.textContaining('TRACK-1'), findsOneWidget);
  });

  testWidgets('order detail shows approval banner when pending',
      (WidgetTester tester) async {
    final DateTime now = DateTime(2024, 4, 10, 9, 30);
    final OrderDetail detail = OrderDetail(
      id: 'order-approval',
      orderNumber: 'PO-3001',
      status: 'pending_approval',
      subtotal: 500,
      tax: 85,
      total: 585,
      createdAt: now,
      items: const [],
      shipments: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderDetailProvider.overrideWith((ref, id) async => detail),
          orderApprovalProvider.overrideWith(
            (ref, String orderId) async => OrderApprovalState(
              orderId: orderId,
              requiresApproval: true,
              rawStatus: 'pending',
            ),
          ),
          returnRequestRepositoryProvider.overrideWithValue(
            FakeReturnRequestRepository(),
          ),
        ],
        child: buildApp(
          const OrderDetailPage(orderId: 'order-approval'),
          locale: const Locale('en'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ApprovalStatusBanner), findsOneWidget);
    expect(
      find.text('Awaiting approval from your approvers.'),
      findsOneWidget,
    );
  });
}
