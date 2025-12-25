import 'package:ashachar_marketplace/src/features/returns/domain/return_request.dart';

abstract class ReturnRequestRepository {
  Future<List<ReturnRequest>> fetchReturnRequests(String orderId);
  Future<ReturnRequestSubmission> submitReturnRequest({
    required String orderId,
    required String orderItemId,
    required double qty,
    String? reason,
  });
}
