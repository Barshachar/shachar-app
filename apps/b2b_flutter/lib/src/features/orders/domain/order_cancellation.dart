class OrderCancellation {
  const OrderCancellation({
    required this.orderId,
    required this.status,
    this.cancelledAt,
    this.cancelledBy,
    this.reason,
  });

  final String orderId;
  final String status;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? reason;

  factory OrderCancellation.fromJson(Map<String, dynamic> json) {
    return OrderCancellation(
      orderId: (json['id'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      cancelledAt: _toDateTime(json['cancelled_at']),
      cancelledBy: json['cancelled_by'] as String?,
      reason: json['cancellation_reason'] as String?,
    );
  }
}

class OrderCancellationSubmission {
  const OrderCancellationSubmission({this.cancellation, this.queued = false});

  final OrderCancellation? cancellation;
  final bool queued;
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
