// Shipping domain models
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipping_models.freezed.dart';
part 'shipping_models.g.dart';

@freezed
abstract class ShippingMethod with _$ShippingMethod {
  const factory ShippingMethod({
    required String id,
    required String name,
    required String code,
    required double rate,
    String? currency,
    String? estimatedDays,
    String? carrier,
    required bool active,
  }) = _ShippingMethod;

  factory ShippingMethod.fromJson(Map<String, dynamic> json) =>
      _$ShippingMethodFromJson(json);
}

@freezed
abstract class AdvancedShippingNotice with _$AdvancedShippingNotice {
  const factory AdvancedShippingNotice({
    required String id,
    required String orderId,
    required String shipmentId,
    required DateTime expectedArrival,
    String? trackingNumber,
    String? carrier,
    required List<AsnPackage> packages,
    String? notes,
    required DateTime createdAt,
  }) = _AdvancedShippingNotice;

  factory AdvancedShippingNotice.fromJson(Map<String, dynamic> json) =>
      _$AdvancedShippingNoticeFromJson(json);
}

@freezed
abstract class AsnPackage with _$AsnPackage {
  const factory AsnPackage({
    required String id,
    required String packageNumber,
    required double weight,
    String? weightUnit,
    Map<String, dynamic>? dimensions,
    required List<AsnItem> items,
  }) = _AsnPackage;

  factory AsnPackage.fromJson(Map<String, dynamic> json) =>
      _$AsnPackageFromJson(json);
}

@freezed
abstract class AsnItem with _$AsnItem {
  const factory AsnItem({
    required String orderItemId,
    required String variantId,
    required double qty,
    String? lotNumber,
    DateTime? expiryDate,
  }) = _AsnItem;

  factory AsnItem.fromJson(Map<String, dynamic> json) =>
      _$AsnItemFromJson(json);
}

@freezed
abstract class ProofOfDelivery with _$ProofOfDelivery {
  const factory ProofOfDelivery({
    required String id,
    required String shipmentId,
    required DateTime deliveredAt,
    required String recipientName,
    String? recipientSignature,
    List<String>? photoUrls,
    String? notes,
    required DateTime createdAt,
  }) = _ProofOfDelivery;

  factory ProofOfDelivery.fromJson(Map<String, dynamic> json) =>
      _$ProofOfDeliveryFromJson(json);
}
