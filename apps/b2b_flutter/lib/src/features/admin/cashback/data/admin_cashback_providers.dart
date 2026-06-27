import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/admin/cashback/data/fake_admin_cashback_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/cashback/domain/admin_cashback_models.dart';

/// Defaults to the fake so the admin screen renders without Supabase. Override
/// with SupabaseAdminCashbackRepository in the authenticated admin flow.
final adminCashbackRepositoryProvider = Provider<AdminCashbackRepository>((ref) {
  return const FakeAdminCashbackRepository();
});

final adminCashbackOverviewProvider =
    FutureProvider<List<AdminCashbackRow>>((ref) {
  return ref.watch(adminCashbackRepositoryProvider).fetchOverview();
});
