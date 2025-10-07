// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Warehouse _$WarehouseFromJson(Map<String, dynamic> json) => _Warehouse(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String?,
      active: json['active'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WarehouseToJson(_Warehouse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'address': instance.address,
      'active': instance.active,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_WarehouseInventory _$WarehouseInventoryFromJson(Map<String, dynamic> json) =>
    _WarehouseInventory(
      warehouseId: json['warehouseId'] as String,
      variantId: json['variantId'] as String,
      qty: (json['qty'] as num).toDouble(),
      lowStockThreshold: (json['lowStockThreshold'] as num).toDouble(),
      inboundEta: json['inboundEta'] == null
          ? null
          : DateTime.parse(json['inboundEta'] as String),
      backorderAllowed: json['backorderAllowed'] as bool? ?? false,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WarehouseInventoryToJson(_WarehouseInventory instance) =>
    <String, dynamic>{
      'warehouseId': instance.warehouseId,
      'variantId': instance.variantId,
      'qty': instance.qty,
      'lowStockThreshold': instance.lowStockThreshold,
      'inboundEta': instance.inboundEta?.toIso8601String(),
      'backorderAllowed': instance.backorderAllowed,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_InventoryStatus _$InventoryStatusFromJson(Map<String, dynamic> json) =>
    _InventoryStatus(
      totalQty: (json['totalQty'] as num).toDouble(),
      inStock: json['inStock'] as bool,
      lowStock: json['lowStock'] as bool,
      earliestEta: json['earliestEta'] == null
          ? null
          : DateTime.parse(json['earliestEta'] as String),
      backorderAvailable: json['backorderAvailable'] as bool? ?? false,
      warehouseBreakdown: (json['warehouseBreakdown'] as List<dynamic>)
          .map((e) => WarehouseInventory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InventoryStatusToJson(_InventoryStatus instance) =>
    <String, dynamic>{
      'totalQty': instance.totalQty,
      'inStock': instance.inStock,
      'lowStock': instance.lowStock,
      'earliestEta': instance.earliestEta?.toIso8601String(),
      'backorderAvailable': instance.backorderAvailable,
      'warehouseBreakdown': instance.warehouseBreakdown,
    };

_WarehouseZone _$WarehouseZoneFromJson(Map<String, dynamic> json) =>
    _WarehouseZone(
      id: json['id'] as String,
      warehouseId: json['warehouse_id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WarehouseZoneToJson(_WarehouseZone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'warehouse_id': instance.warehouseId,
      'name': instance.name,
      'sort_order': instance.sortOrder,
    };

_WarehouseBin _$WarehouseBinFromJson(Map<String, dynamic> json) =>
    _WarehouseBin(
      id: json['id'] as String,
      zoneId: json['zone_id'] as String,
      aisle: json['aisle'] as String,
      bin: json['bin'] as String,
      fillState: $enumDecode(_$WarehouseBinFillEnumMap, json['fill_state']),
      currentQty: (json['current_qty'] as num?)?.toDouble() ?? 0,
      capacity: (json['capacity'] as num?)?.toDouble(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WarehouseBinToJson(_WarehouseBin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'zone_id': instance.zoneId,
      'aisle': instance.aisle,
      'bin': instance.bin,
      'fill_state': _$WarehouseBinFillEnumMap[instance.fillState]!,
      'current_qty': instance.currentQty,
      'capacity': instance.capacity,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$WarehouseBinFillEnumMap = {
  WarehouseBinFill.empty: 'empty',
  WarehouseBinFill.partial: 'partial',
  WarehouseBinFill.full: 'full',
};
