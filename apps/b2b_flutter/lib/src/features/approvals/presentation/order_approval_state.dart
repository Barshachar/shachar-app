import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/core/supabase/supabase_client_provider.dart';

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
    final String rawStatus =
        _asString(data['status'] ?? data['approval_status']) ?? '';
    final String? note = _asString(
      data['notes'] ??
          data['approval_note'] ??
          data['approval_reason'] ??
          data['rejection_note'],
    );
    final DateTime? sentAt =
        _asDateTime(data['created_at'] ?? data['approval_sent_at']);
    final DateTime? resolvedAt = _asDateTime(
      data['reviewed_at'] ??
          data['approval_resolved_at'] ??
          data['approval_decided_at'],
    );
    return OrderApprovalState(
      orderId: orderId,
      requiresApproval: true,
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

  final SupabaseClient client = ref.read(supabaseClientProvider);
  try {
    final dynamic orderResponse = await client
        .from('orders')
        .select('id, status')
        .eq('id', orderId)
        .maybeSingle();

    if (orderResponse == null) {
      throw StateError('Order $orderId not found');
    }

    if (orderResponse is! Map<String, dynamic>) {
      throw StateError('Unexpected response for order $orderId');
    }

    final String orderStatus = _asString(orderResponse['status']) ?? '';

    final dynamic requestResponse = await client
        .from('approval_requests')
        .select('id, status, notes, created_at, reviewed_at')
        .eq('entity_type', 'order')
        .eq('entity_id', orderId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (requestResponse == null) {
      if (!_requiresApprovalForStatus(orderStatus)) {
        return OrderApprovalState.notRequired(orderId);
      }
      return OrderApprovalState(
        orderId: orderId,
        requiresApproval: true,
        rawStatus: orderStatus.isEmpty ? 'draft' : orderStatus,
      );
    }

    if (requestResponse is! Map<String, dynamic>) {
      throw StateError('Unexpected approval response for order $orderId');
    }

    return OrderApprovalState.fromRow(orderId: orderId, row: requestResponse);
  } on PostgrestException catch (error, stackTrace) {
    debugPrint('orderApprovalProvider error: ${error.message}');
    Error.throwWithStackTrace(error, stackTrace);
  }
});

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

bool _requiresApprovalForStatus(String status) {
  final String normalized = status.trim().toLowerCase();
  if (normalized.isEmpty) {
    return true;
  }
  if (normalized == 'draft') {
    return true;
  }
  if (normalized.contains('approval')) {
    return true;
  }
  if (normalized == 'pending') {
    return true;
  }
  return false;
}
