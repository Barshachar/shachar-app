import 'package:ashachar_marketplace/src/features/cashback/data/cashback_providers.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/repositories/cashback_repository.dart';
import 'package:ashachar_marketplace/src/features/cashback/presentation/cashback_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_harness.dart';

class _FakeCashbackRepository implements CashbackRepository {
  const _FakeCashbackRepository(this.summary);

  final CashbackSummary summary;

  @override
  Future<CashbackSummary> fetchSummary({String? companyId}) async => summary;
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

    // BTC conversion UI is gated behind the (default-off) feature flag.
    expect(find.text('המרה לביטקוין'), findsNothing);
  });
}
