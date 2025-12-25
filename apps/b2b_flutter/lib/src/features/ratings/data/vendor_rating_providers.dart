import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/ratings/data/supabase_vendor_rating_repository.dart';
import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating.dart';
import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating_repository.dart';

final vendorRatingSummaryProvider =
    FutureProvider.autoDispose.family<VendorRatingSummary?, String>(
  (ref, vendorCompanyId) async {
    final VendorRatingRepository repository =
        ref.watch(vendorRatingRepositoryProvider);
    return repository.fetchSummary(vendorCompanyId);
  },
);

@immutable
class VendorOrderRatingRequest {
  const VendorOrderRatingRequest({
    required this.orderId,
    required this.vendorCompanyId,
  });

  final String orderId;
  final String vendorCompanyId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorOrderRatingRequest &&
        orderId == other.orderId &&
        vendorCompanyId == other.vendorCompanyId;
  }

  @override
  int get hashCode => Object.hash(orderId, vendorCompanyId);
}

final vendorOrderRatingProvider =
    FutureProvider.autoDispose.family<VendorRating?, VendorOrderRatingRequest>(
  (ref, request) async {
    final VendorRatingRepository repository =
        ref.watch(vendorRatingRepositoryProvider);
    return repository.fetchRatingForOrder(
      orderId: request.orderId,
      vendorCompanyId: request.vendorCompanyId,
    );
  },
);
