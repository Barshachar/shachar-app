import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/finance/domain/cost_center.dart';

final costCenterRepositoryProvider = Provider<CostCenterRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return SupabaseCostCenterRepository(client: client);
});

abstract class CostCenterRepository {
  Future<List<CostCenter>> fetchCostCenters({String? companyId});
  Future<void> setActive(String costCenterId, bool active);
  Future<void> setRequiresApprover(String costCenterId, bool requires);
}

class SupabaseCostCenterRepository implements CostCenterRepository {
  SupabaseCostCenterRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<CostCenter>> fetchCostCenters({String? companyId}) async {
    PostgrestFilterBuilder<dynamic> query =
        _client.from('cost_centers').select();
    if (companyId != null && companyId.isNotEmpty) {
      query = query.eq('company_id', companyId);
    }
    final List<dynamic> response = await query.order('code');
    return response
        .map((dynamic row) => CostCenter.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> setActive(String costCenterId, bool active) async {
    await _client
        .from('cost_centers')
        .update(<String, dynamic>{'status': active ? 'active' : 'archived'}).eq(
            'id', costCenterId);
  }

  @override
  Future<void> setRequiresApprover(String costCenterId, bool requires) async {
    await _client
        .from('cost_centers')
        .update(<String, dynamic>{'requires_approver': requires}).eq(
            'id', costCenterId);
  }
}
