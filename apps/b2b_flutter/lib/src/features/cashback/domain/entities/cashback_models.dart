import 'package:equatable/equatable.dart';

/// Type of a cashback ledger movement. Mirrors the `cashback_entry_type`
/// enum defined in supabase/sql/patches/023_cashback_ledger.sql.
enum CashbackEntryType { earn, redeem, expire, adjust }

extension CashbackEntryTypeCodec on CashbackEntryType {
  String get wire {
    switch (this) {
      case CashbackEntryType.earn:
        return 'earn';
      case CashbackEntryType.redeem:
        return 'redeem';
      case CashbackEntryType.expire:
        return 'expire';
      case CashbackEntryType.adjust:
        return 'adjust';
    }
  }

  static CashbackEntryType fromWire(String? value) {
    switch (value) {
      case 'redeem':
        return CashbackEntryType.redeem;
      case 'expire':
        return CashbackEntryType.expire;
      case 'adjust':
        return CashbackEntryType.adjust;
      case 'earn':
      default:
        return CashbackEntryType.earn;
    }
  }
}

/// A single cashback movement in ILS. Positive amounts add to the balance
/// (earn/adjust), negative amounts reduce it (redeem/expire).
class CashbackEntry extends Equatable {
  const CashbackEntry({
    required this.id,
    required this.type,
    required this.amountIls,
    required this.createdAt,
    this.orderId,
    this.note,
  });

  final String id;
  final CashbackEntryType type;
  final double amountIls;
  final DateTime createdAt;
  final String? orderId;
  final String? note;

  @override
  List<Object?> get props => <Object?>[id, type, amountIls, createdAt, orderId, note];
}

/// Aggregated cashback view for a customer company.
class CashbackSummary extends Equatable {
  const CashbackSummary({
    required this.balanceIls,
    required this.entries,
  });

  final double balanceIls;
  final List<CashbackEntry> entries;

  @override
  List<Object?> get props => <Object?>[balanceIls, entries];
}

/// Live BTC reference rate, used for display-only conversion. We never store
/// BTC amounts; the ledger is always denominated in ILS.
class BtcQuote extends Equatable {
  const BtcQuote({
    required this.rateIls,
    required this.asOf,
  });

  /// Price of 1 BTC in ILS.
  final double rateIls;
  final DateTime asOf;

  /// Convert an ILS amount to its BTC equivalent. Returns null when the rate
  /// is unavailable so callers can hide the conversion gracefully.
  double? btcFor(double amountIls) {
    if (rateIls <= 0) {
      return null;
    }
    return amountIls / rateIls;
  }

  @override
  List<Object?> get props => <Object?>[rateIls, asOf];
}
