import 'package:ashachar_marketplace/src/features/cashback/data/cashback_providers.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/repositories/cashback_repository.dart';
import 'package:ashachar_marketplace/src/features/cashback/presentation/cashback_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_harness.dart';

class _FakeCashbackRepository implements CashbackRepository {
  _FakeCashbackRepository(this.summary);

  final CashbackSummary summary;
  double? lastRedeemed;

  @override
  Future<CashbackSummary> fetchSummary({String? companyId}) async => summary;

  @override
  Future<void> redeem({required double amountIls, String? orderId}) async {
    lastRedeemed = amountIls;
  }
}

void main() {
  final CashbackSummary summary = CashbackSummary(
    balanceIls: 54.70,
    entries: <CashbackEntry>[
      CashbackEntry(
        id: '1',
        type: CashbackEntryType.earn,
        amountIls: 36.50,
        createdAt: DateTime(2026, 6, 21),
        note: 'הזמנה לדוגמה',
      ),
    ],
  );

  testWidgets('renders balance, history and hides BTC when flag is off',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      makeTestApp(
        const CashbackPage(),
        overrides: <Object?>[
          cashbackRepositoryProvider
              .overrideWithValue(_FakeCashbackRepository(summary)),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // Hebrew fallback strings are used because the test harness does not load
    // the MarketplaceLocalizations delegate.
    expect(find.text('הזיכויים שלי'), findsWidgets);
    expect(find.text('יתרת זיכוי'), findsOneWidget);
    expect(find.text('תנועות אחרונות'), findsOneWidget);
    expect(find.text('הזמנה לדוגמה'), findsOneWidget);

    // Redeem CTA is shown when there is a balance; BTC conversion UI is gated
    // behind the (default-off) feature flag.
    expect(find.text('מימוש זיכוי'), findsOneWidget);
    expect(find.text('המרה לביטקוין'), findsNothing);
  });

  testWidgets('redeem flow submits the entered amount',
      (WidgetTester tester) async {
    final _FakeCashbackRepository repo = _FakeCashbackRepository(summary);
    await tester.pumpWidget(
      makeTestApp(
        const CashbackPage(),
        overrides: <Object?>[
          cashbackRepositoryProvider.overrideWithValue(repo),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Open the redeem sheet.
    await tester.tap(find.text('מימוש זיכוי'));
    await tester.pumpAndSettle();
    expect(find.text('סכום למימוש (₪)'), findsOneWidget);

    // Enter an amount within balance and confirm.
    await tester.enterText(find.byType(TextField), '20');
    await tester.tap(find.text('אישור מימוש'));
    await tester.pumpAndSettle();

    expect(repo.lastRedeemed, 20.0);
  });
}
