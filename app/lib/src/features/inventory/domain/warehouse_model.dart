// Warehouse domain models
import 'package:freezed_annotation/freezed_annotation.dart';

part 'warehouse_model.freezed.dart';
part 'warehouse_model.g.dart';

@freezed
abstract class Warehouse with _$Warehouse {
  const factory Warehouse({
    required String id,
    required String name,
    required String code,
    String? address,
    required bool active,
    DateTime? createdAt,
  }) = _Warehouse;

  factory Warehouse.fromJson(Map<String, dynamic> json) =>
      _$WarehouseFromJson(json);
}

@freezed
abstract class WarehouseInventory with _$WarehouseInventory {
  const factory WarehouseInventory({
    required String warehouseId,
    required String variantId,
    required double qty,
    required double lowStockThreshold,
    DateTime? inboundEta,
    @Default(false) bool backorderAllowed,
    DateTime? updatedAt,
  }) = _WarehouseInventory;

  factory WarehouseInventory.fromJson(Map<String, dynamic> json) =>
      _$WarehouseInventoryFromJson(json);
}

@freezed
abstract class InventoryStatus with _$InventoryStatus {
  const factory InventoryStatus({
    required double totalQty,
    required bool inStock,
    required bool lowStock,
    DateTime? earliestEta,
    @Default(false) bool backorderAvailable,
    required List<WarehouseInventory> warehouseBreakdown,
  }) = _InventoryStatus;

  factory InventoryStatus.fromJson(Map<String, dynamic> json) =>
      _$InventoryStatusFromJson(json);
}

@JsonEnum(alwaysCreate: true)
enum WarehouseBinFill { empty, partial, full }

@freezed
abstract class WarehouseZone with _$WarehouseZone {
  const factory WarehouseZone({
    required String id,
    @JsonKey(name: 'warehouse_id') required String warehouseId,
    required String name,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _WarehouseZone;

  factory WarehouseZone.fromJson(Map<String, dynamic> json) =>
      _$WarehouseZoneFromJson(json);
}

@freezed
abstract class WarehouseBin with _$WarehouseBin {
  const WarehouseBin._();

  const factory WarehouseBin({
    required String id,
    @JsonKey(name: 'zone_id') required String zoneId,
    required String aisle,
    required String bin,
    @JsonKey(name: 'fill_state') required WarehouseBinFill fillState,
    @JsonKey(name: 'current_qty') @Default(0) double currentQty,
    double? capacity,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _WarehouseBin;

  factory WarehouseBin.fromJson(Map<String, dynamic> json) =>
      _$WarehouseBinFromJson(json);

  bool get isEmpty => fillState == WarehouseBinFill.empty;
  bool get isPartial => fillState == WarehouseBinFill.partial;
  bool get isFull => fillState == WarehouseBinFill.full;
}
