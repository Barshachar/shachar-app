import 'package:ashachar_marketplace/src/features/admin/cashback/presentation/admin_cashback_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_harness.dart';

void main() {
  testWidgets('renders liability total and company balances',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestApp(const AdminCashbackPage()));
    await tester.pumpAndSettle();

    // Hebrew fallback strings (the harness omits the localization delegate).
    expect(find.text('סך התחייבות זיכויים'), findsOneWidget);
    expect(find.text('יתרות לפי חברה'), findsOneWidget);
    expect(find.text('SuperMart Chain'), findsOneWidget);
  });
}
