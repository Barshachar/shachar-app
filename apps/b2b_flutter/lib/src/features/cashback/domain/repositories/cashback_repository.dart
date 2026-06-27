import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';

/// Reads a customer's cashback balance and recent ledger movements, and lets
/// them redeem cashback (e.g. against an order at checkout).
abstract class CashbackRepository {
  Future<CashbackSummary> fetchSummary({String? companyId});

  /// Redeem [amountIls] of cashback, optionally tied to [orderId]. The server
  /// enforces tenant ownership and sufficient balance.
  Future<void> redeem({required double amountIls, String? orderId});
}

/// Provides a live BTC reference rate for display-only conversion.
abstract class BtcRateRepository {
  Future<BtcQuote> fetchRate();
}
