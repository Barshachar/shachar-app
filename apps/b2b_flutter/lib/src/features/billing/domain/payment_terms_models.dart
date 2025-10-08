import 'package:collection/collection.dart';

class PaymentTermsTemplate {
  const PaymentTermsTemplate({
    required this.id,
    required this.code,
    required this.displayName,
    this.description,
    required this.netDays,
  });

  final String id;
  final String code;
  final String displayName;
  final String? description;
  final int netDays;
}

class VendorPaymentTermOverride {
  const VendorPaymentTermOverride({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.termsId,
    required this.termsDisplayName,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String termsId;
  final String termsDisplayName;
}

class VendorPaymentTermsProfile {
  const VendorPaymentTermsProfile({
    required this.vendorId,
    required this.templates,
    required this.allowedTermIds,
    required this.defaultTermsId,
    this.earlyPayDiscountPct,
    this.earlyPayDiscountDays,
    this.lateFeeInterestPct,
    this.gracePeriodDays,
    this.allowOverrides = false,
    this.overrides = const <VendorPaymentTermOverride>[],
  });

  final String vendorId;
  final List<PaymentTermsTemplate> templates;
  final Set<String> allowedTermIds;
  final String defaultTermsId;
  final double? earlyPayDiscountPct;
  final int? earlyPayDiscountDays;
  final double? lateFeeInterestPct;
  final int? gracePeriodDays;
  final bool allowOverrides;
  final List<VendorPaymentTermOverride> overrides;

  PaymentTermsTemplate? get defaultTerms => templates.firstWhereOrNull(
      (PaymentTermsTemplate template) => template.id == defaultTermsId);

  bool isAllowed(String termsId) =>
      allowedTermIds.contains(termsId) || termsId == defaultTermsId;

  VendorPaymentTermsProfile copyWith({
    Set<String>? allowedTermIds,
    String? defaultTermsId,
    double? earlyPayDiscountPct,
    bool clearEarlyPayDiscount = false,
    int? earlyPayDiscountDays,
    bool clearEarlyPayDays = false,
    double? lateFeeInterestPct,
    bool clearLateFee = false,
    int? gracePeriodDays,
    bool clearGracePeriod = false,
    bool? allowOverrides,
    List<VendorPaymentTermOverride>? overrides,
  }) {
    return VendorPaymentTermsProfile(
      vendorId: vendorId,
      templates: templates,
      allowedTermIds: allowedTermIds ?? this.allowedTermIds,
      defaultTermsId: defaultTermsId ?? this.defaultTermsId,
      earlyPayDiscountPct: clearEarlyPayDiscount
          ? null
          : (earlyPayDiscountPct ?? this.earlyPayDiscountPct),
      earlyPayDiscountDays: clearEarlyPayDays
          ? null
          : (earlyPayDiscountDays ?? this.earlyPayDiscountDays),
      lateFeeInterestPct:
          clearLateFee ? null : (lateFeeInterestPct ?? this.lateFeeInterestPct),
      gracePeriodDays:
          clearGracePeriod ? null : (gracePeriodDays ?? this.gracePeriodDays),
      allowOverrides: allowOverrides ?? this.allowOverrides,
      overrides: overrides ?? this.overrides,
    );
  }
}
