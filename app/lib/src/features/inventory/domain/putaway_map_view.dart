import 'package:ashachar_marketplace/src/features/inventory/domain/warehouse_model.dart';

class PutawayMapView {
  const PutawayMapView({
    required this.warehouse,
    required this.zones,
    required this.bins,
  });

  final Warehouse warehouse;
  final List<WarehouseZone> zones;
  final List<WarehouseBin> bins;

  List<WarehouseBin> binsForZone(String zoneId) =>
      bins.where((WarehouseBin bin) => bin.zoneId == zoneId).toList();

  List<WarehouseBin> nearestEmptyBins({int limit = 3}) {
    final List<WarehouseBin> empties =
        bins.where((WarehouseBin bin) => bin.isEmpty).toList(growable: false);
    empties.sort((WarehouseBin a, WarehouseBin b) {
      final int aisleCompare = a.aisle.compareTo(b.aisle);
      if (aisleCompare != 0) return aisleCompare;
      return int.tryParse(a.bin)?.compareTo(int.tryParse(b.bin) ?? 0) ?? 0;
    });
    return empties.take(limit).toList(growable: false);
  }
}
