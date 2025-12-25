import 'package:ashachar_marketplace/src/features/orders/domain/order_cancellation.dart';

abstract class OrderCancellationRepository {
  Future<OrderCancellationSubmission> cancelOrder({
    required String orderId,
    String? reason,
  });
}
