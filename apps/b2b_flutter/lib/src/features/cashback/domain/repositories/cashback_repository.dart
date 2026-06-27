import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';

/// Reads a customer's cashback balance and recent ledger movements.
abstract class CashbackRepository {
  Future<CashbackSummary> fetchSummary({String? companyId});
}

/// Provides a live BTC reference rate for display-only conversion.
abstract class BtcRateRepository {
  Future<BtcQuote> fetchRate();
}
