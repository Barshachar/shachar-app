// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
      id: json['id'] as String,
      nameHe: json['nameHe'] as String,
      nameEn: json['nameEn'] as String,
      parentId: json['parentId'] as String?,
    );

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
      'id': instance.id,
      'nameHe': instance.nameHe,
      'nameEn': instance.nameEn,
      'parentId': instance.parentId,
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
      id: json['id'] as String,
      vendorCompanyId: json['vendorCompanyId'] as String,
      sku: json['sku'] as String,
      nameHe: json['nameHe'] as String,
      nameEn: json['nameEn'] as String,
      active: json['active'] as bool,
      uom: json['uom'] as String,
      packSize: (json['packSize'] as num).toInt(),
      moq: (json['moq'] as num).toInt(),
      leadTime: (json['leadTime'] as num).toInt(),
      variants: (json['variants'] as List<dynamic>)
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
      'id': instance.id,
      'vendorCompanyId': instance.vendorCompanyId,
      'sku': instance.sku,
      'nameHe': instance.nameHe,
      'nameEn': instance.nameEn,
      'active': instance.active,
      'uom': instance.uom,
      'packSize': instance.packSize,
      'moq': instance.moq,
      'leadTime': instance.leadTime,
      'variants': instance.variants.map((e) => e.toJson()).toList(),
    };

_ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) =>
    _ProductVariant(
      id: json['id'] as String,
      productId: json['productId'] as String,
      attributes: json['attributes'] as Map<String, dynamic>,
      barcode: json['barcode'] as String?,
      active: json['active'] as bool,
      uom: json['uom'] as String,
    );

Map<String, dynamic> _$ProductVariantToJson(_ProductVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'attributes': instance.attributes,
      'barcode': instance.barcode,
      'active': instance.active,
      'uom': instance.uom,
    };

_PriceQuote _$PriceQuoteFromJson(Map<String, dynamic> json) => _PriceQuote(
      vendorId: json['vendorId'] as String,
      variantId: json['variantId'] as String,
      currency: json['currency'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      minQty: (json['minQty'] as num).toInt(),
    );

Map<String, dynamic> _$PriceQuoteToJson(_PriceQuote instance) =>
    <String, dynamic>{
      'vendorId': instance.vendorId,
      'variantId': instance.variantId,
      'currency': instance.currency,
      'unitPrice': instance.unitPrice,
      'minQty': instance.minQty,
    };
