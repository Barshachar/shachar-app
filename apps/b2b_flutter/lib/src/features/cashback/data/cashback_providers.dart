import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/cashback/data/fake_btc_rate_repository.dart';
import 'package:ashachar_marketplace/src/features/cashback/data/supabase_cashback_repository.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/repositories/cashback_repository.dart';

/// Feature flag key (see AppConfig.featureEnabled) that gates BTC conversion UI.
const String kCashbackBtcFlag = 'cashback_btc';

/// Backed by Supabase (RLS scopes results to the authenticated customer) in
/// production. Tests override this with a fake.
final cashbackRepositoryProvider = Provider<CashbackRepository>((ref) {
  return SupabaseCashbackRepository(client: Supabase.instance.client);
});

final btcRateRepositoryProvider = Provider<BtcRateRepository>((ref) {
  return const FakeBtcRateRepository();
});

final cashbackSummaryProvider = FutureProvider<CashbackSummary>((ref) {
  final CashbackRepository repository = ref.watch(cashbackRepositoryProvider);
  return repository.fetchSummary();
});

final btcRateProvider = FutureProvider<BtcQuote>((ref) {
  final BtcRateRepository repository = ref.watch(btcRateRepositoryProvider);
  return repository.fetchRate();
});
