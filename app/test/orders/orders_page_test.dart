import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  MaterialApp buildApp(Widget home) {
    return MaterialApp(
      locale: const Locale('he'),
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

  testWidgets('orders page shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersControllerProvider.overrideWithValue(
            const AsyncValue.data(<OrderSummary>[]),
          ),
        ],
        child: buildApp(const OrdersPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('אין הזמנות עדיין'), findsOneWidget);
    expect(find.text('עבור לקטלוג'), findsOneWidget);
  });

  testWidgets('orders page renders single order row',
      (WidgetTester tester) async {
    final DateTime now = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ordersControllerProvider.overrideWithValue(
            AsyncValue.data(<OrderSummary>[
              OrderSummary(
                id: '1',
                orderNumber: 'PO-1001',
                status: 'submitted',
                total: 1234.0,
                createdAt: now,
              ),
            ]),
          ),
        ],
        child: buildApp(const OrdersPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('אין הזמנות עדיין'), findsNothing);
  });
}
