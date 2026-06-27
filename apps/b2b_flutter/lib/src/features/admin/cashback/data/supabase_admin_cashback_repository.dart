import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/admin/cashback/domain/admin_cashback_models.dart';

/// Admin cashback overview/adjust backed by the admin-only RPCs
/// (rpc_cashback_overview, rpc_adjust_cashback). Access is enforced server-side.
class SupabaseAdminCashbackRepository implements AdminCashbackRepository {
  SupabaseAdminCashbackRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<AdminCashbackRow>> fetchOverview() async {
    final dynamic response = await _client.rpc('rpc_cashback_overview');
    final List<dynamic> rows = (response as List<dynamic>?) ?? <dynamic>[];
    return rows.cast<Map<String, dynamic>>().map((Map<String, dynamic> row) {
      return AdminCashbackRow(
        companyId: row['company_id'] as String,
        companyName: row['company_name'] as String? ?? '—',
        balanceIls: _toDouble(row['balance']),
      );
    }).toList(growable: false);
  }

  @override
  Future<void> adjust({
    required String companyId,
    required double amountIls,
    String? note,
  }) async {
    await _client.rpc(
      'rpc_adjust_cashback',
      params: <String, dynamic>{
        'p_company': companyId,
        'p_amount': amountIls,
        'p_note': note,
      },
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
