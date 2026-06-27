import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/repositories/cashback_repository.dart';

/// Static BTC rate used for local development and tests.
class FakeBtcRateRepository implements BtcRateRepository {
  const FakeBtcRateRepository();

  @override
  Future<BtcQuote> fetchRate() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return BtcQuote(rateIls: 250000, asOf: DateTime(2026, 6, 27));
  }
}
