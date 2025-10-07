import 'package:freezed_annotation/freezed_annotation.dart';

part 'effective_price.freezed.dart';
part 'effective_price.g.dart';

@freezed
abstract class EffectivePrice with _$EffectivePrice {
  const factory EffectivePrice({
    required String vendorId,
    required String variantId,
    required String currency,
    required double unitPrice,
    required String scope,
  }) = _EffectivePrice;

  factory EffectivePrice.fromJson(Map<String, dynamic> json) =>
      _$EffectivePriceFromJson(json);
}
