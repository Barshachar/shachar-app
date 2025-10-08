// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfq_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RfqLine _$RfqLineFromJson(Map<String, dynamic> json) => _RfqLine(
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      uom: json['uom'] as String,
      quantity: (json['quantity'] as num).toInt(),
      targetUnitPrice: (json['targetUnitPrice'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RfqLineToJson(_RfqLine instance) => <String, dynamic>{
      'productId': instance.productId,
      'sku': instance.sku,
      'uom': instance.uom,
      'quantity': instance.quantity,
      'targetUnitPrice': instance.targetUnitPrice,
    };

_QuoteLine _$QuoteLineFromJson(Map<String, dynamic> json) => _QuoteLine(
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      uom: json['uom'] as String,
      minQty: (json['minQty'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      leadTimeDays: (json['leadTimeDays'] as num).toInt(),
    );

Map<String, dynamic> _$QuoteLineToJson(_QuoteLine instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'sku': instance.sku,
      'uom': instance.uom,
      'minQty': instance.minQty,
      'unitPrice': instance.unitPrice,
      'leadTimeDays': instance.leadTimeDays,
    };

_RfqRequest _$RfqRequestFromJson(Map<String, dynamic> json) => _RfqRequest(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => RfqLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      targetCurrency: json['targetCurrency'] as String,
      requestedDeliveryDate:
          DateTime.parse(json['requestedDeliveryDate'] as String),
      status: $enumDecodeNullable(_$RfqStatusEnumMap, json['status']) ??
          RfqStatus.draft,
    );

Map<String, dynamic> _$RfqRequestToJson(_RfqRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'buyerId': instance.buyerId,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'targetCurrency': instance.targetCurrency,
      'requestedDeliveryDate': instance.requestedDeliveryDate.toIso8601String(),
      'status': _$RfqStatusEnumMap[instance.status]!,
    };

const _$RfqStatusEnumMap = {
  RfqStatus.draft: 'draft',
  RfqStatus.sent: 'sent',
  RfqStatus.quoted: 'quoted',
  RfqStatus.expired: 'expired',
  RfqStatus.converted: 'converted',
};

_Quote _$QuoteFromJson(Map<String, dynamic> json) => _Quote(
      id: json['id'] as String,
      rfqId: json['rfqId'] as String,
      vendorId: json['vendorId'] as String,
      validUntil: DateTime.parse(json['validUntil'] as String),
      currency: json['currency'] as String,
      lines: (json['lines'] as List<dynamic>)
          .map((e) => QuoteLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      terms: json['terms'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$QuoteToJson(_Quote instance) => <String, dynamic>{
      'id': instance.id,
      'rfqId': instance.rfqId,
      'vendorId': instance.vendorId,
      'validUntil': instance.validUntil.toIso8601String(),
      'currency': instance.currency,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'terms': instance.terms,
      'version': instance.version,
    };
