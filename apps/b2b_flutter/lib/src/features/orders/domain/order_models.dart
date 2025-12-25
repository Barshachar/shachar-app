import 'package:json_annotation/json_annotation.dart';

part 'order_models.g.dart';

@JsonSerializable()
class OrderSummary {
  OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) =>
      _$OrderSummaryFromJson(json);

  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);
}

@JsonSerializable()
class OrderItem {
  OrderItem({
    required this.id,
    required this.variantId,
    required this.vendorCompanyId,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    this.productName,
    this.variantSku,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  final String id;
  final String variantId;
  final String vendorCompanyId;
  final double qty;
  final double unitPrice;
  final double lineTotal;
  final String? productName;
  final String? variantSku;

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class OrderDetail {
  OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.shipments,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailFromJson(json);

  final String id;
  final String orderNumber;
  final String status;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;
  final List<OrderShipment> shipments;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;

  Map<String, dynamic> toJson() => _$OrderDetailToJson(this);
}

@JsonSerializable()
class OrderShipment {
  OrderShipment({
    required this.id,
    required this.vendorCompanyId,
    required this.status,
    required this.createdAt,
    this.tracking,
    this.vendorName,
  });

  factory OrderShipment.fromJson(Map<String, dynamic> json) =>
      _$OrderShipmentFromJson(json);

  final String id;
  final String vendorCompanyId;
  final String status;
  final DateTime createdAt;
  final String? tracking;
  final String? vendorName;

  Map<String, dynamic> toJson() => _$OrderShipmentToJson(this);
}
