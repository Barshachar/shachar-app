import 'package:flutter/foundation.dart';

@immutable
class CheckoutAccountOption {
  const CheckoutAccountOption({
    required this.id,
    required this.title,
    this.subtitle,
    this.addressLine,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? addressLine;
}

@immutable
class CheckoutLocationOption {
  const CheckoutLocationOption({
    required this.id,
    required this.label,
    this.addressLine,
    this.notes,
  });

  final String id;
  final String label;
  final String? addressLine;
  final String? notes;
}

@immutable
class CheckoutPaymentTermOption {
  const CheckoutPaymentTermOption({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    required this.netDays,
  });

  final String id;
  final String code;
  final String label;
  final String? description;
  final int netDays;
}

@immutable
class CheckoutFormOptions {
  const CheckoutFormOptions({
    required this.billToAccounts,
    required this.shipToLocations,
    required this.paymentTerms,
  });

  final List<CheckoutAccountOption> billToAccounts;
  final List<CheckoutLocationOption> shipToLocations;
  final List<CheckoutPaymentTermOption> paymentTerms;
}
