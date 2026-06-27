import 'package:ashachar_marketplace/src/features/admin/cashback/domain/admin_cashback_models.dart';

/// In-memory admin cashback data for local development and tests.
class FakeAdminCashbackRepository implements AdminCashbackRepository {
  const FakeAdminCashbackRepository();

  @override
  Future<List<AdminCashbackRow>> fetchOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const <AdminCashbackRow>[
      AdminCashbackRow(
        companyId: '30000000-0000-0000-0000-000000000000',
        companyName: 'SuperMart Chain',
        balanceIls: 54.70,
      ),
      AdminCashbackRow(
        companyId: '30000000-0000-0000-0000-000000000001',
        companyName: 'Cafe Delights',
        balanceIls: 12.00,
      ),
    ];
  }

  @override
  Future<void> adjust({
    required String companyId,
    required double amountIls,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}
