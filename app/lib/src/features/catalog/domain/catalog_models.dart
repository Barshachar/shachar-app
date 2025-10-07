import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String nameHe,
    required String nameEn,
    String? parentId,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

@freezed
abstract class Product with _$Product {
  @JsonSerializable(explicitToJson: true)
  const factory Product({
    required String id,
    required String vendorCompanyId,
    required String sku,
    required String nameHe,
    required String nameEn,
    required bool active,
    required String uom,
    required int packSize,
    required int moq,
    required int leadTime,
    required List<ProductVariant> variants,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
abstract class ProductVariant with _$ProductVariant {
  @JsonSerializable(explicitToJson: true)
  const factory ProductVariant({
    required String id,
    required String productId,
    required Map<String, dynamic> attributes,
    String? barcode,
    required bool active,
    required String uom,
  }) = _ProductVariant;

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      _$ProductVariantFromJson(json);
}

@freezed
abstract class PriceQuote with _$PriceQuote {
  const factory PriceQuote({
    required String vendorId,
    required String variantId,
    required String currency,
    required double unitPrice,
    required int minQty,
  }) = _PriceQuote;

  factory PriceQuote.fromJson(Map<String, dynamic> json) =>
      _$PriceQuoteFromJson(json);
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v == null) return <String, dynamic>{};
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  if (v is String && v.trim().isNotEmpty) {
    final d = jsonDecode(v);
    if (d is Map) return Map<String, dynamic>.from(d);
  }
  return <String, dynamic>{};
}

Map<String, dynamic> safeCatalogMap(dynamic v) => _asMap(v);
