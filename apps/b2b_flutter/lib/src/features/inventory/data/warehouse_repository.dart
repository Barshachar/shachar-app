import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/inventory/domain/putaway_map_view.dart';
import 'package:ashachar_marketplace/src/features/inventory/domain/warehouse_model.dart';

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return SupabaseWarehouseRepository(client: client);
});

abstract class WarehouseRepository {
  Future<List<Warehouse>> fetchWarehouses({String? companyId});
  Future<PutawayMapView> fetchPutawayMap({
    required String warehouseId,
  });
}

class SupabaseWarehouseRepository implements WarehouseRepository {
  SupabaseWarehouseRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  @override
  Future<List<Warehouse>> fetchWarehouses({String? companyId}) async {
    PostgrestFilterBuilder<dynamic> query = _client.from('warehouses').select();
    if (companyId != null && companyId.isNotEmpty) {
      query = query.eq('company_id', companyId);
    }
    final List<dynamic> response = await query.order('name');
    return response
        .map((dynamic row) => Warehouse.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<PutawayMapView> fetchPutawayMap({required String warehouseId}) async {
    final Map<String, dynamic> warehouseJson = await _client
        .from('warehouses')
        .select()
        .eq('id', warehouseId)
        .single();
    final Warehouse warehouse = Warehouse.fromJson(warehouseJson);

    final List<dynamic> zonesResponse = await _client
        .from('warehouse_zones')
        .select()
        .eq('warehouse_id', warehouseId)
        .order('sort_order');
    final List<WarehouseZone> zones = zonesResponse
        .map((dynamic row) =>
            WarehouseZone.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
    if (zones.isEmpty) {
      return PutawayMapView(warehouse: warehouse, zones: zones, bins: const []);
    }

    final List<String> zoneIds =
        zones.map((WarehouseZone zone) => zone.id).toList(growable: false);
    PostgrestFilterBuilder<dynamic> binQuery =
        _client.from('warehouse_bins').select();
    if (zoneIds.isNotEmpty) {
      final String formattedIds = zoneIds.map((id) => '"$id"').join(',');
      binQuery = binQuery.filter('zone_id', 'in', '($formattedIds)');
    }
    final List<dynamic> binsResponse =
        await binQuery.order('aisle').order('bin');
    final List<WarehouseBin> bins = binsResponse
        .map(
            (dynamic row) => WarehouseBin.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);

    return PutawayMapView(warehouse: warehouse, zones: zones, bins: bins);
  }
}
