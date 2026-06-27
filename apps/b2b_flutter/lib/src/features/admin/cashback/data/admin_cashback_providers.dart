import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/admin/cashback/data/supabase_admin_cashback_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/cashback/domain/admin_cashback_models.dart';

/// Backed by Supabase (admin-only RPCs) in production. Tests override this with
/// a fake. Mirrors the other admin repositories, which default to Supabase.
final adminCashbackRepositoryProvider = Provider<AdminCashbackRepository>((ref) {
  return SupabaseAdminCashbackRepository(client: Supabase.instance.client);
});

final adminCashbackOverviewProvider =
    FutureProvider<List<AdminCashbackRow>>((ref) {
  return ref.watch(adminCashbackRepositoryProvider).fetchOverview();
});
