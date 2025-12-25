class VendorRating {
  const VendorRating({
    required this.id,
    required this.vendorCompanyId,
    required this.customerCompanyId,
    required this.orderId,
    required this.rating,
    required this.createdAt,
    required this.createdBy,
    this.comment,
  });

  final String id;
  final String vendorCompanyId;
  final String customerCompanyId;
  final String orderId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String createdBy;

  factory VendorRating.fromJson(Map<String, dynamic> json) {
    return VendorRating(
      id: (json['id'] as String?) ?? '',
      vendorCompanyId: (json['vendor_company_id'] as String?) ?? '',
      customerCompanyId: (json['customer_company_id'] as String?) ?? '',
      orderId: (json['order_id'] as String?) ?? '',
      rating: _toInt(json['rating']),
      comment: json['comment'] as String?,
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
      createdBy: (json['created_by'] as String?) ?? '',
    );
  }
}

class VendorRatingSummary {
  const VendorRatingSummary({
    required this.vendorCompanyId,
    required this.averageRating,
    required this.ratingsCount,
    this.lastRatingAt,
  });

  final String vendorCompanyId;
  final double averageRating;
  final int ratingsCount;
  final DateTime? lastRatingAt;

  factory VendorRatingSummary.fromJson(Map<String, dynamic> json) {
    return VendorRatingSummary(
      vendorCompanyId: (json['vendor_company_id'] as String?) ?? '',
      averageRating: _toDouble(json['average_rating']),
      ratingsCount: _toInt(json['ratings_count']),
      lastRatingAt: _toDateTime(json['last_rating_at']),
    );
  }
}

class VendorRatingSubmission {
  const VendorRatingSubmission({this.rating, this.queued = false});

  final VendorRating? rating;
  final bool queued;
}

int _toInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

double _toDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

DateTime? _toDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
