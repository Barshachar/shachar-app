// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShippingMethod _$ShippingMethodFromJson(Map<String, dynamic> json) =>
    _ShippingMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      rate: (json['rate'] as num).toDouble(),
      currency: json['currency'] as String?,
      estimatedDays: json['estimatedDays'] as String?,
      carrier: json['carrier'] as String?,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$ShippingMethodToJson(_ShippingMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'rate': instance.rate,
      'currency': instance.currency,
      'estimatedDays': instance.estimatedDays,
      'carrier': instance.carrier,
      'active': instance.active,
    };

_AdvancedShippingNotice _$AdvancedShippingNoticeFromJson(
        Map<String, dynamic> json) =>
    _AdvancedShippingNotice(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      shipmentId: json['shipmentId'] as String,
      expectedArrival: DateTime.parse(json['expectedArrival'] as String),
      trackingNumber: json['trackingNumber'] as String?,
      carrier: json['carrier'] as String?,
      packages: (json['packages'] as List<dynamic>)
          .map((e) => AsnPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdvancedShippingNoticeToJson(
        _AdvancedShippingNotice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'shipmentId': instance.shipmentId,
      'expectedArrival': instance.expectedArrival.toIso8601String(),
      'trackingNumber': instance.trackingNumber,
      'carrier': instance.carrier,
      'packages': instance.packages,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_AsnPackage _$AsnPackageFromJson(Map<String, dynamic> json) => _AsnPackage(
      id: json['id'] as String,
      packageNumber: json['packageNumber'] as String,
      weight: (json['weight'] as num).toDouble(),
      weightUnit: json['weightUnit'] as String?,
      dimensions: json['dimensions'] as Map<String, dynamic>?,
      items: (json['items'] as List<dynamic>)
          .map((e) => AsnItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AsnPackageToJson(_AsnPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'packageNumber': instance.packageNumber,
      'weight': instance.weight,
      'weightUnit': instance.weightUnit,
      'dimensions': instance.dimensions,
      'items': instance.items,
    };

_AsnItem _$AsnItemFromJson(Map<String, dynamic> json) => _AsnItem(
      orderItemId: json['orderItemId'] as String,
      variantId: json['variantId'] as String,
      qty: (json['qty'] as num).toDouble(),
      lotNumber: json['lotNumber'] as String?,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
    );

Map<String, dynamic> _$AsnItemToJson(_AsnItem instance) => <String, dynamic>{
      'orderItemId': instance.orderItemId,
      'variantId': instance.variantId,
      'qty': instance.qty,
      'lotNumber': instance.lotNumber,
      'expiryDate': instance.expiryDate?.toIso8601String(),
    };

_ProofOfDelivery _$ProofOfDeliveryFromJson(Map<String, dynamic> json) =>
    _ProofOfDelivery(
      id: json['id'] as String,
      shipmentId: json['shipmentId'] as String,
      deliveredAt: DateTime.parse(json['deliveredAt'] as String),
      recipientName: json['recipientName'] as String,
      recipientSignature: json['recipientSignature'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProofOfDeliveryToJson(_ProofOfDelivery instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shipmentId': instance.shipmentId,
      'deliveredAt': instance.deliveredAt.toIso8601String(),
      'recipientName': instance.recipientName,
      'recipientSignature': instance.recipientSignature,
      'photoUrls': instance.photoUrls,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
