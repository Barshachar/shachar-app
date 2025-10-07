// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effective_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EffectivePrice _$EffectivePriceFromJson(Map<String, dynamic> json) =>
    _EffectivePrice(
      vendorId: json['vendorId'] as String,
      variantId: json['variantId'] as String,
      currency: json['currency'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      scope: json['scope'] as String,
    );

Map<String, dynamic> _$EffectivePriceToJson(_EffectivePrice instance) =>
    <String, dynamic>{
      'vendorId': instance.vendorId,
      'variantId': instance.variantId,
      'currency': instance.currency,
      'unitPrice': instance.unitPrice,
      'scope': instance.scope,
    };
