import 'package:ashachar_marketplace/src/features/pricing/domain/effective_price.dart';

typedef PriceResolver = Future<EffectivePrice> Function({
  required String variantId,
  required int quantity,
});

/// Represents a single order_items row enriched with merchandising details
/// for cart interactions.
class CartLine {
  CartLine({
    required this.id,
    required this.orderId,
    required this.variantId,
    required this.vendorCompanyId,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    required this.productName,
    this.variantSku,
    Map<String, dynamic>? variantAttributes,
    Map<String, String>? productTranslations,
  })  : variantAttributes = Map<String, dynamic>.unmodifiable(
          variantAttributes ?? const <String, dynamic>{},
        ),
        productTranslations = Map<String, String>.unmodifiable(
          _normalizeTranslations(productTranslations),
        );

  final String id;
  final String orderId;
  final String variantId;
  final String vendorCompanyId;
  final double qty;
  final double unitPrice;
  final double lineTotal;
  final String productName;
  final String? variantSku;
  final Map<String, dynamic> variantAttributes;
  final Map<String, String> productTranslations;

  /// Unique identifier for the line row used by the UI.
  String get rowId => id;

  /// Title combining product name and variant SKU when available.
  String get title => localizedTitle();

  /// Local subtotal before tax/discounts as displayed pre-submit.
  double get subtotal => unitPrice * qty;

  /// Human readable label for variant attributes (e.g. "size: 1kg · color: red").
  String get variantLabel {
    if (variantAttributes.isEmpty) {
      return '';
    }
    final Iterable<String> parts =
        variantAttributes.entries.map((MapEntry<String, dynamic> entry) {
      final String value = entry.value?.toString() ?? '';
      if (value.trim().isEmpty) {
        return '';
      }
      return '${entry.key}: $value';
    }).where((String value) => value.isNotEmpty);
    return parts.join(' · ');
  }

  /// Computes a localized title, falling back to the stored product name.
  String localizedTitle({String? languageCode}) {
    String? resolved;
    if (languageCode != null && languageCode.isNotEmpty) {
      final String normalized = languageCode.toLowerCase();
      resolved = productTranslations[normalized] ??
          productTranslations[_languagePart(normalized)];
    }
    resolved ??= productTranslations['he'] ?? productTranslations['en'];
    final String base =
        resolved?.trim().isNotEmpty == true ? resolved!.trim() : productName;
    if (variantSku == null || variantSku!.trim().isEmpty) {
      return base;
    }
    return '$base • ${variantSku!}';
  }

  /// Convenience getter to keep backwards-compatible display title access.
  String get displayTitle => localizedTitle();

  /// Returns a copy of the line with a new quantity, recalculating the total.
  CartLine copyWithQty(double qty) {
    final double safeQty = qty.isFinite ? qty : this.qty;
    final double clamped = safeQty < 0 ? 0 : safeQty;
    return copyWith(
      qty: clamped,
      lineTotal: unitPrice * clamped,
    );
  }

  /// Recomputes the line price using the provided resolver; returns unchanged
  /// instance if pricing lookup fails.
  Future<CartLine> repriceIfNeeded(PriceResolver resolvePrice) async {
    try {
      final double safeQty = qty <= 0 ? 1 : qty;
      final int quantityAsInt = safeQty.ceil();
      final EffectivePrice effective = await resolvePrice(
        variantId: variantId,
        quantity: quantityAsInt,
      );
      final double newUnitPrice = effective.unitPrice;
      final String newVendor =
          effective.vendorId.isNotEmpty ? effective.vendorId : vendorCompanyId;
      final double newLineTotal = newUnitPrice * qty;
      final bool priceSame = (newUnitPrice - unitPrice).abs() < 0.0001;
      final bool vendorSame = newVendor == vendorCompanyId;
      if (priceSame && vendorSame) {
        return this;
      }
      return copyWith(
        unitPrice: newUnitPrice,
        lineTotal: newLineTotal,
        vendorCompanyId: newVendor,
      );
    } catch (_) {
      return this;
    }
  }

  /// Generic copy helper for internal updates.
  CartLine copyWith({
    String? vendorCompanyId,
    double? qty,
    double? unitPrice,
    double? lineTotal,
    String? productName,
    String? variantSku,
    Map<String, dynamic>? variantAttributes,
    Map<String, String>? productTranslations,
  }) {
    final double resolvedQty = qty ?? this.qty;
    final double resolvedUnitPrice = unitPrice ?? this.unitPrice;
    final double resolvedLineTotal =
        lineTotal ?? (resolvedUnitPrice * resolvedQty);
    return CartLine(
      id: id,
      orderId: orderId,
      variantId: variantId,
      vendorCompanyId: vendorCompanyId ?? this.vendorCompanyId,
      qty: resolvedQty,
      unitPrice: resolvedUnitPrice,
      lineTotal: resolvedLineTotal,
      productName: productName ?? this.productName,
      variantSku: variantSku ?? this.variantSku,
      variantAttributes: variantAttributes ?? this.variantAttributes,
      productTranslations: productTranslations ?? this.productTranslations,
    );
  }

  static Map<String, String> _normalizeTranslations(
    Map<String, String>? source,
  ) {
    if (source == null || source.isEmpty) {
      return <String, String>{};
    }
    return source
        .map((String key, String value) => MapEntry(key.toLowerCase(), value));
  }

  static String _languagePart(String code) {
    final int index = code.indexOf('-');
    if (index <= 0) {
      return code;
    }
    return code.substring(0, index);
  }
}
