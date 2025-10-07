import 'package:freezed_annotation/freezed_annotation.dart';

part 'rfq_models.freezed.dart';
part 'rfq_models.g.dart';

enum RfqStatus { draft, sent, quoted, expired, converted }

@freezed
abstract class RfqLine with _$RfqLine {
  const factory RfqLine({
    required String productId,
    required String sku,
    required String uom,
    required int quantity,
    double? targetUnitPrice,
  }) = _RfqLine;

  factory RfqLine.fromJson(Map<String, dynamic> json) =>
      _$RfqLineFromJson(json);
}

@freezed
abstract class QuoteLine with _$QuoteLine {
  const factory QuoteLine({
    required String productId,
    required String sku,
    required String uom,
    required int minQty,
    required double unitPrice,
    required int leadTimeDays,
  }) = _QuoteLine;

  factory QuoteLine.fromJson(Map<String, dynamic> json) =>
      _$QuoteLineFromJson(json);
}

@freezed
abstract class RfqRequest with _$RfqRequest {
  @JsonSerializable(explicitToJson: true)
  const factory RfqRequest({
    required String id,
    required String buyerId,
    required List<RfqLine> lines,
    String? notes,
    required String targetCurrency,
    required DateTime requestedDeliveryDate,
    @Default(RfqStatus.draft) RfqStatus status,
  }) = _RfqRequest;

  factory RfqRequest.fromJson(Map<String, dynamic> json) =>
      _$RfqRequestFromJson(json);
}

@freezed
abstract class Quote with _$Quote {
  @JsonSerializable(explicitToJson: true)
  const factory Quote({
    required String id,
    required String rfqId,
    required String vendorId,
    required DateTime validUntil,
    required String currency,
    required List<QuoteLine> lines,
    String? terms,
    @Default(1) int version,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}
