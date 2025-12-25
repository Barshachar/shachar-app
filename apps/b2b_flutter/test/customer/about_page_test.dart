import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/customer/about_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_harness.dart';

void main() {
  testWidgets('about page renders key sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      makeTestApp(
        const AboutPage(),
        extraDelegates: const [MarketplaceLocalizations.delegate],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('אודות א.שחר'), findsWidgets);
    expect(find.text('המשימה שלנו'), findsOneWidget);

    final Finder contactFinder = find.text('צור קשר');
    await tester.scrollUntilVisible(contactFinder, 300);
    expect(contactFinder, findsOneWidget);
  });
}
