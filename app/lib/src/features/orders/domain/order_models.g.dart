// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderSummary _$OrderSummaryFromJson(Map<String, dynamic> json) => OrderSummary(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OrderSummaryToJson(OrderSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'status': instance.status,
      'total': instance.total,
      'createdAt': instance.createdAt.toIso8601String(),
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      variantId: json['variantId'] as String,
      vendorCompanyId: json['vendorCompanyId'] as String,
      qty: (json['qty'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      productName: json['productName'] as String?,
      variantSku: json['variantSku'] as String?,
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'variantId': instance.variantId,
      'vendorCompanyId': instance.vendorCompanyId,
      'qty': instance.qty,
      'unitPrice': instance.unitPrice,
      'lineTotal': instance.lineTotal,
      'productName': instance.productName,
      'variantSku': instance.variantSku,
    };

OrderDetail _$OrderDetailFromJson(Map<String, dynamic> json) => OrderDetail(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      shipments: (json['shipments'] as List<dynamic>)
          .map((e) => OrderShipment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderDetailToJson(OrderDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'status': instance.status,
      'subtotal': instance.subtotal,
      'tax': instance.tax,
      'total': instance.total,
      'createdAt': instance.createdAt.toIso8601String(),
      'items': instance.items,
      'shipments': instance.shipments,
    };

OrderShipment _$OrderShipmentFromJson(Map<String, dynamic> json) =>
    OrderShipment(
      id: json['id'] as String,
      vendorCompanyId: json['vendorCompanyId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tracking: json['tracking'] as String?,
      vendorName: json['vendorName'] as String?,
    );

Map<String, dynamic> _$OrderShipmentToJson(OrderShipment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendorCompanyId': instance.vendorCompanyId,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'tracking': instance.tracking,
      'vendorName': instance.vendorName,
    };
