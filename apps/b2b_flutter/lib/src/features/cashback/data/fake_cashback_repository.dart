import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/repositories/cashback_repository.dart';

/// In-memory cashback data used for local development and widget tests, so the
/// UI works without a Supabase connection (mirrors FakeBusinessCreditRepository).
class FakeCashbackRepository implements CashbackRepository {
  const FakeCashbackRepository();

  @override
  Future<CashbackSummary> fetchSummary({String? companyId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final List<CashbackEntry> entries = <CashbackEntry>[
      CashbackEntry(
        id: 'demo-earn-1',
        type: CashbackEntryType.earn,
        amountIls: 36.50,
        createdAt: DateTime(2026, 6, 21),
        orderId: 'A0000000-0000-0000-0000-000000000000',
        note: 'הזמנה #A0000000',
      ),
      CashbackEntry(
        id: 'demo-earn-2',
        type: CashbackEntryType.earn,
        amountIls: 18.20,
        createdAt: DateTime(2026, 6, 12),
        note: 'הזמנה חוזרת',
      ),
    ];
    final double balance =
        entries.fold<double>(0, (double sum, CashbackEntry e) => sum + e.amountIls);
    return CashbackSummary(balanceIls: balance, entries: entries);
  }

  @override
  Future<void> redeem({required double amountIls, String? orderId}) async {
    // Dev/test fake: redemption is a no-op (the real ledger lives in Supabase).
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}
