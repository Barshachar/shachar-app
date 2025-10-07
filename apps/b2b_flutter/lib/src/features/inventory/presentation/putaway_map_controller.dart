import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;

import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/features/inventory/data/warehouse_repository.dart';
import 'package:ashachar_marketplace/src/features/inventory/domain/putaway_map_view.dart';
import 'package:ashachar_marketplace/src/features/inventory/domain/warehouse_model.dart';

final availableWarehousesProvider =
    FutureProvider.autoDispose<List<Warehouse>>((ref) async {
  final profileAsync = ref.watch(userProfileProvider);
  final String? companyId = profileAsync.asData?.value?.companyId;
  final WarehouseRepository repository = ref.watch(warehouseRepositoryProvider);
  return repository.fetchWarehouses(companyId: companyId);
});

final selectedWarehouseIdProvider =
    legacy.StateProvider.autoDispose<String?>((ref) => null);

final selectedZoneIdProvider =
    legacy.StateProvider.autoDispose<String?>((ref) => null);
final selectedAisleFilterProvider =
    legacy.StateProvider.autoDispose<String?>((ref) => null);

final putawayMapProvider =
    FutureProvider.autoDispose<PutawayMapView?>((ref) async {
  final String? warehouseId = ref.watch(selectedWarehouseIdProvider);
  if (warehouseId == null) {
    final AsyncValue<List<Warehouse>> warehouses =
        ref.watch(availableWarehousesProvider);
    final List<Warehouse>? data = warehouses.asData?.value;
    if (data != null && data.isNotEmpty) {
      final String defaultId = data.first.id;
      ref.read(selectedWarehouseIdProvider.notifier).state = defaultId;
      return ref
          .read(warehouseRepositoryProvider)
          .fetchPutawayMap(warehouseId: defaultId);
    }
    return null;
  }
  final WarehouseRepository repository = ref.watch(warehouseRepositoryProvider);
  final PutawayMapView view =
      await repository.fetchPutawayMap(warehouseId: warehouseId);
  final String? selectedZone = ref.read(selectedZoneIdProvider);
  if (selectedZone == null && view.zones.isNotEmpty) {
    ref.read(selectedZoneIdProvider.notifier).state = view.zones.first.id;
  }
  return view;
});
