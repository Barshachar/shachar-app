import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class ApprovalRequest {
  const ApprovalRequest({
    required this.stepId,
    required this.orderId,
    required this.orderNumber,
    required this.total,
    required this.currency,
    required this.requestedAt,
    this.status,
    this.requestedBy,
    this.buyerName,
    this.note,
  });

  final String stepId;
  final String orderId;
  final String orderNumber;
  final double total;
  final String currency;
  final DateTime requestedAt;
  final String? status;
  final String? requestedBy;
  final String? buyerName;
  final String? note;

  factory ApprovalRequest.fromMap(Map<String, dynamic> row) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(row);
    final String stepId = _asString(data['step_id']) ??
        _asString(data['id']) ??
        _asString(data['approval_step_id']) ??
        '';
    final String orderId =
        _asString(data['order_id']) ?? _asString(data['id_order']) ?? '';
    final String orderNumber =
        _asString(data['order_number']) ?? _asString(data['orderNo']) ?? '';
    final double total = _asDouble(data['total'] ?? data['order_total']);
    final String currency =
        _asString(data['currency']) ?? _asString(data['order_currency']) ?? '₪';
    final DateTime requestedAt =
        _asDateTime(data['requested_at'] ?? data['created_at']) ??
            DateTime.now().toUtc();
    final String? status = _asString(data['status']);
    final String? requestedBy =
        _asString(data['requested_by']) ?? _asString(data['requester_name']);
    final String? buyerName =
        _asString(data['buyer_name']) ?? _asString(data['company_name']);
    final String? note = _asString(data['note']) ??
        _asString(data['reason']) ??
        _asString(data['memo']);
    return ApprovalRequest(
      stepId: stepId,
      orderId: orderId,
      orderNumber: orderNumber,
      total: total,
      currency: currency,
      requestedAt: requestedAt,
      status: status,
      requestedBy: requestedBy,
      buyerName: buyerName,
      note: note,
    );
  }
}

final approvalsInboxProvider =
    FutureProvider.autoDispose<List<ApprovalRequest>>((ref) async {
  final SupabaseClient client = Supabase.instance.client;
  final Stopwatch stopwatch = Stopwatch()..start();
  try {
    final dynamic response =
        await client.rpc<dynamic>('rpc_approvals_inbox').timeout(
              const Duration(seconds: 8),
              onTimeout: () =>
                  throw TimeoutException('Approvals request timed out'),
            );
    return _parseApprovalsResponse(response);
  } on PostgrestException catch (error) {
    if (!_isUndefinedFunction(error)) {
      rethrow;
    }
  } finally {
    stopwatch.stop();
    _recordInboxTelemetry(stopwatch.elapsed, success: true);
  }

  final dynamic fallback = await client
      .from('order_approvals_inbox')
      .select()
      .order('requested_at', ascending: false)
      .timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TimeoutException('Approvals request timed out'),
      );

  return _parseApprovalsResponse(fallback);
});

List<ApprovalRequest> _parseApprovalsResponse(dynamic payload) {
  if (payload is List) {
    return payload
        .whereType<Map<String, dynamic>>()
        .map(ApprovalRequest.fromMap)
        .toList();
  }
  if (payload is Map && payload['data'] is List) {
    final List<dynamic> data = payload['data'] as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(ApprovalRequest.fromMap)
        .toList();
  }
  throw StateError('Approvals inbox returned unexpected response');
}

void _recordInboxTelemetry(Duration elapsed, {required bool success}) {
  // Simple hook to add logging/analytics later without breaking call sites.
  // Intentionally no-op; instrumentation can be injected here.
}

bool _isUndefinedFunction(PostgrestException error) {
  final String message = error.message.toLowerCase();
  return message.contains('function') && message.contains('does not exist');
}

double _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
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
