import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/repositories/cashback_repository.dart';

/// Reads cashback data from Supabase. Row Level Security scopes results to the
/// authenticated customer's company, so callers normally omit [companyId].
class SupabaseCashbackRepository implements CashbackRepository {
  SupabaseCashbackRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  @override
  Future<CashbackSummary> fetchSummary({String? companyId}) async {
    // Balance comes from the aggregate view; entries from the ledger table.
    PostgrestFilterBuilder<dynamic> balanceQuery =
        _client.from('cashback_balances').select('customer_company_id, balance');
    if (companyId != null && companyId.isNotEmpty) {
      balanceQuery = balanceQuery.eq('customer_company_id', companyId);
    }
    final List<dynamic> balanceRows = await balanceQuery.limit(1);
    final double balance = balanceRows.isEmpty
        ? 0
        : _toDouble((balanceRows.first as Map<String, dynamic>)['balance']);

    PostgrestFilterBuilder<dynamic> ledgerQuery = _client
        .from('cashback_ledger')
        .select('id, entry_type, amount, order_id, note, created_at');
    if (companyId != null && companyId.isNotEmpty) {
      ledgerQuery = ledgerQuery.eq('customer_company_id', companyId);
    }
    final List<dynamic> ledgerRows =
        await ledgerQuery.order('created_at', ascending: false).limit(50);

    final List<CashbackEntry> entries = ledgerRows
        .cast<Map<String, dynamic>>()
        .map(_entryFromRow)
        .toList(growable: false);

    return CashbackSummary(balanceIls: balance, entries: entries);
  }

  @override
  Future<void> redeem({required double amountIls, String? orderId}) async {
    await _client.rpc(
      'rpc_redeem_cashback',
      params: <String, dynamic>{
        'p_amount': amountIls,
        'p_order_id': orderId,
      },
    );
  }

  CashbackEntry _entryFromRow(Map<String, dynamic> row) {
    return CashbackEntry(
      id: row['id'] as String,
      type: CashbackEntryTypeCodec.fromWire(row['entry_type'] as String?),
      amountIls: _toDouble(row['amount']),
      orderId: row['order_id'] as String?,
      note: row['note'] as String?,
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
