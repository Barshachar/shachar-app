import 'package:ashachar_marketplace/src/features/promotions/presentation/widgets/premium_promotions_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap({required VoidCallback onTap}) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: PremiumPromotionsBanner(
              title: 'מבצעי הקיץ',
              subtitle: 'חבילות משתלמות ללקוחות החוזרים',
              cta: 'לכל המבצעים',
              badgeLabel: 'מועדון פרימיום',
              highlight: 'עד 40% הנחה',
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders premium banner content and settles', (tester) async {
    await tester.pumpWidget(wrap(onTap: () {}));
    // A finite entrance animation must complete (no infinite repaint loop).
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('home_campaign_banner')),
      findsOneWidget,
    );
    expect(find.text('מבצעי הקיץ'), findsOneWidget);
    expect(find.text('מועדון פרימיום'), findsOneWidget);
    expect(find.text('עד 40% הנחה'), findsOneWidget);
    expect(find.text('לכל המבצעים'), findsOneWidget);
  });

  testWidgets('invokes onTap when pressed', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(wrap(onTap: () => tapped++));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home_campaign_banner')));
    expect(tapped, 1);
  });
}
