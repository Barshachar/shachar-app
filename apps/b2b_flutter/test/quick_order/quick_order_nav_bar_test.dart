import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('QuickOrderNavBar emits quick tab selection',
      (WidgetTester tester) async {
    QuickNavTab? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickOrderNavBar(
            currentTab: QuickNavTab.quickOrder,
            onQuickTabSelected: (QuickNavTab tab) => selected = tab,
          ),
        ),
      ),
    );
    await tester.tap(find.text('הזמנה מהירה'));
    await tester.pumpAndSettle();

    expect(selected, QuickNavTab.quickOrder);
  });

  testWidgets('Checkout without draft shows unavailable message',
      (WidgetTester tester) async {
    bool unavailableCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickOrderNavBar(
            currentTab: QuickNavTab.checkout,
            checkoutOrderId: null,
            onCheckoutUnavailable: () => unavailableCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('תשלום'));
    await tester.pump(); // show SnackBar

    expect(unavailableCalled, isTrue);
    expect(find.text('פתחו הזמנה כדי לבצע תשלום'), findsOneWidget);
  });

  testWidgets('Nav bar navigates to catalog via GoRouter',
      (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: QuickOrderNavBar(
              currentTab: QuickNavTab.quickOrder,
              checkoutOrderId: 'draft-1',
            ),
          ),
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const SizedBox(),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('קטלוג'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/catalog');
  });
}
