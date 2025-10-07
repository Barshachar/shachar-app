class CustomerCompanyProfile {
  const CustomerCompanyProfile({
    required this.companyId,
    required this.companyName,
    required this.status,
    required this.tier,
    required this.industry,
    required this.salesRepName,
    required this.salesRepEmail,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  final String companyId;
  final String companyName;
  final String status;
  final String tier;
  final String industry;
  final String salesRepName;
  final String salesRepEmail;
  final String phone;
  final String addressLine;
  final String city;
  final String postalCode;
  final String country;

  String get formattedAddress {
    final List<String> parts = <String>[
      if (addressLine.isNotEmpty) addressLine,
      if (city.isNotEmpty) city,
      if (postalCode.isNotEmpty) postalCode,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }
}
