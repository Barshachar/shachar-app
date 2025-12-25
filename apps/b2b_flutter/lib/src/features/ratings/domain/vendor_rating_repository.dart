import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating.dart';

abstract class VendorRatingRepository {
  Future<VendorRatingSummary?> fetchSummary(String vendorCompanyId);
  Future<VendorRating?> fetchRatingForOrder({
    required String orderId,
    required String vendorCompanyId,
  });
  Future<VendorRatingSubmission> submitRating({
    required String orderId,
    required String vendorCompanyId,
    required int rating,
    String? comment,
  });
}
