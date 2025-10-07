import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';

final priceResolutionProvider =
    FutureProvider.autoDispose.family<PriceResolution?, PriceQuoteRequest>(
  (ref, request) async {
    final service = ref.watch(priceResolutionServiceProvider);
    return service.resolve(
      companyId: request.companyId,
      variantId: request.variantId,
      qty: request.quantity,
    );
  },
);

class PriceQuoteRequest {
  const PriceQuoteRequest({
    required this.companyId,
    required this.variantId,
    required this.quantity,
  });

  final String companyId;
  final String variantId;
  final int quantity;
}
