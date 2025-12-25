class ReturnRequest {
  const ReturnRequest({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.qty,
    required this.status,
    required this.createdAt,
    this.reason,
    this.createdBy,
    this.resolutionNote,
    this.resolvedAt,
  });

  final String id;
  final String orderId;
  final String orderItemId;
  final double qty;
  final String status;
  final String? reason;
  final String? createdBy;
  final String? resolutionNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: (json['id'] as String?) ?? '',
      orderId: (json['order_id'] as String?) ?? '',
      orderItemId: (json['item_id'] as String?) ?? '',
      qty: _toDouble(json['qty']),
      status: (json['status'] as String?) ?? '',
      reason: json['reason'] as String?,
      createdBy: json['created_by'] as String?,
      resolutionNote: json['resolution_note'] as String?,
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
      resolvedAt: _toDateTime(json['resolved_at']),
    );
  }
}

class ReturnRequestSubmission {
  const ReturnRequestSubmission({this.request, this.queued = false});

  final ReturnRequest? request;
  final bool queued;
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
