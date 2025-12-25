import 'package:ashachar_marketplace/src/features/returns/domain/return_request.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request_repository.dart';

class FakeReturnRequestRepository implements ReturnRequestRepository {
  FakeReturnRequestRepository({this.requests = const <ReturnRequest>[]});

  final List<ReturnRequest> requests;

  @override
  Future<List<ReturnRequest>> fetchReturnRequests(String orderId) async {
    return requests;
  }

  @override
  Future<ReturnRequestSubmission> submitReturnRequest({
    required String orderId,
    required String orderItemId,
    required double qty,
    String? reason,
  }) async {
    return ReturnRequestSubmission(
      request: ReturnRequest(
        id: 'return-request-test',
        orderId: orderId,
        orderItemId: orderItemId,
        qty: qty,
        status: 'requested',
        createdAt: DateTime.now(),
        reason: reason,
        createdBy: 'tester',
      ),
    );
  }
}
