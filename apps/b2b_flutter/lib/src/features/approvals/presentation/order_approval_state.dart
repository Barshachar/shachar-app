import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Describes the approval stage for an order/draft.
@immutable
class OrderApprovalState {
  const OrderApprovalState({
    required this.orderId,
    required this.requiresApproval,
    required this.rawStatus,
    this.note,
    this.sentAt,
    this.resolvedAt,
  });

  const OrderApprovalState.notRequired(this.orderId)
      : requiresApproval = false,
        rawStatus = 'not_required',
        note = null,
        sentAt = null,
        resolvedAt = null;

  final String orderId;
  final bool requiresApproval;
  final String rawStatus;
  final String? note;
  final DateTime? sentAt;
  final DateTime? resolvedAt;

  /// Normalized snake_case status string.
  String get statusNormalized {
    final String trimmed = rawStatus.trim();
    if (trimmed.isEmpty) {
      return requiresApproval ? 'draft' : 'not_required';
    }
    return trimmed.toLowerCase().replaceAll('-', '_');
  }

  OrderApprovalStage get stage {
    if (!requiresApproval) {
      return OrderApprovalStage.notRequired;
    }
    final String normalized = statusNormalized;
    if (normalized == 'approved' ||
        normalized == 'approval_approved' ||
        normalized == 'satisfied' ||
        normalized == 'ready') {
      return OrderApprovalStage.approved;
    }
    if (normalized == 'rejected' ||
        normalized == 'approval_rejected' ||
        normalized == 'declined' ||
        normalized == 'denied') {
      return OrderApprovalStage.rejected;
    }
    if (normalized == 'pending' ||
        normalized == 'pending_approval' ||
        normalized == 'awaiting_approval' ||
        normalized == 'in_review') {
      return OrderApprovalStage.pending;
    }
    return OrderApprovalStage.readyToRequest;
  }

  bool get canRequestApproval =>
      stage == OrderApprovalStage.readyToRequest ||
      stage == OrderApprovalStage.rejected;

  bool get isPending => stage == OrderApprovalStage.pending;

  bool get isApproved => stage == OrderApprovalStage.approved;

  bool get isRejected => stage == OrderApprovalStage.rejected;

  OrderApprovalState copyWith({
    bool? requiresApproval,
    String? rawStatus,
    String? note,
    DateTime? sentAt,
    DateTime? resolvedAt,
  }) {
    return OrderApprovalState(
      orderId: orderId,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      rawStatus: rawStatus ?? this.rawStatus,
      note: note ?? this.note,
      sentAt: sentAt ?? this.sentAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory OrderApprovalState.fromRow({
    required String orderId,
    required Map<String, dynamic> row,
  }) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(row);
    final bool requiresApproval = _asBool(data['requires_approval']);
    final String rawStatus = _asString(data['approval_status']) ?? '';
    final String? note = _asString(
      data['approval_note'] ??
          data['approval_reason'] ??
          data['rejection_note'],
    );
    final DateTime? sentAt = _asDateTime(data['approval_sent_at']);
    final DateTime? resolvedAt = _asDateTime(
        data['approval_resolved_at'] ?? data['approval_decided_at']);
    return OrderApprovalState(
      orderId: orderId,
      requiresApproval: requiresApproval,
      rawStatus: rawStatus,
      note: note,
      sentAt: sentAt,
      resolvedAt: resolvedAt,
    );
  }
}

enum OrderApprovalStage {
  notRequired,
  readyToRequest,
  pending,
  approved,
  rejected,
}

final orderApprovalProvider = FutureProvider.autoDispose
    .family<OrderApprovalState, String>((ref, orderId) async {
  if (orderId.isEmpty) {
    return OrderApprovalState.notRequired(orderId);
  }

  final SupabaseClient client = Supabase.instance.client;
  try {
    final dynamic response = await client
        .from('orders')
        .select(
          'id, requires_approval, approval_status, approval_note,'
          ' approval_reason, rejection_note, approval_sent_at, approval_resolved_at,'
          ' approval_decided_at',
        )
        .eq('id', orderId)
        .maybeSingle();

    if (response == null) {
      throw StateError('Order $orderId not found');
    }

    if (response is! Map<String, dynamic>) {
      throw StateError('Unexpected response for order $orderId');
    }

    return OrderApprovalState.fromRow(orderId: orderId, row: response);
  } on PostgrestException catch (error, stackTrace) {
    debugPrint('orderApprovalProvider error: ${error.message}');
    Error.throwWithStackTrace(error, stackTrace);
  }
});

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final String normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

String? _asString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

DateTime? _asDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String) {
    try {
      return DateTime.parse(value).toUtc();
    } catch (_) {
      return null;
    }
  }
  return null;
}
