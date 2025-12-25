import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
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
    Intl.defaultLocale = 'he';
  });

  testWidgets('order detail status and reorder button use localized labels',
      (WidgetTester tester) async {
    final OrderDetail detail = OrderDetail(
      id: 'order-localized',
      orderNumber: 'PO-42',
      status: 'placed',
      subtotal: 420,
      tax: 71.4,
      total: 491.4,
      createdAt: DateTime(2024, 5, 1, 10, 0),
      items: [
        OrderItem(
          id: 'item-localized-1',
          variantId: 'var-1',
          vendorCompanyId: 'vendor-1',
          qty: 2,
          unitPrice: 210,
          lineTotal: 420,
          productName: 'Product',
          variantSku: 'SKU-1',
        ),
      ],
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
              rawStatus: 'approved',
              sentAt: DateTime(2024, 5, 1, 9, 30),
              resolvedAt: DateTime(2024, 5, 1, 12, 15),
            ),
          ),
          returnRequestRepositoryProvider.overrideWithValue(
            FakeReturnRequestRepository(),
          ),
        ],
        child: _buildApp(const OrderDetailPage(orderId: 'order-localized')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('placed'), findsNothing);
    expect(find.text('הוזמנה'), findsOneWidget);
    expect(find.text('Approved'), findsNothing);
    expect(find.text('מאושר'), findsWidgets);

    final Finder reorderFinder =
        find.byKey(const ValueKey('order_detail_reorder_btn'));
    expect(reorderFinder, findsOneWidget);

    final AButton reorderButton = tester.widget<AButton>(reorderFinder);
    expect(reorderButton.label, 'הזמנה חוזרת');
    expect(reorderButton.semanticsLabel, 'הזמן שוב את ההזמנה');
  });
}

MaterialApp _buildApp(Widget home) {
  return MaterialApp(
    supportedLocales: const [Locale('en'), Locale('he')],
    locale: const Locale('he'),
    localizationsDelegates: const [
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}
