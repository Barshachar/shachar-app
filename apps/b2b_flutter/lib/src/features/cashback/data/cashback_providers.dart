import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/cashback/data/fake_btc_rate_repository.dart';
import 'package:ashachar_marketplace/src/features/cashback/data/fake_cashback_repository.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/repositories/cashback_repository.dart';

/// Feature flag key (see AppConfig.featureEnabled) that gates BTC conversion UI.
const String kCashbackBtcFlag = 'cashback_btc';

/// Defaults to the in-memory fake so the UI renders without Supabase. Swap to
/// SupabaseCashbackRepository via an override once auth/config is wired.
final cashbackRepositoryProvider = Provider<CashbackRepository>((ref) {
  return const FakeCashbackRepository();
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
