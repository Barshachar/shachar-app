import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/returns/domain/return_request.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request_repository.dart';
import 'package:offline_toolkit/offline_toolkit.dart';

final returnRequestRepositoryProvider =
    Provider<ReturnRequestRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  return SupabaseReturnRequestRepository(client: client, queue: queue);
});

class SupabaseReturnRequestRepository implements ReturnRequestRepository {
  SupabaseReturnRequestRepository({
    required SupabaseClient client,
    required OfflineQueue queue,
  })  : _client = client,
        _queue = queue;

  final SupabaseClient _client;
  final OfflineQueue _queue;

  static const String _functionEndpoint = 'return_request_submit';

  @override
  Future<List<ReturnRequest>> fetchReturnRequests(String orderId) async {
    if (orderId.trim().isEmpty) {
      return const <ReturnRequest>[];
    }
    final dynamic response = await _client
        .from('returns')
        .select(
          'id, order_id, item_id, qty, reason, status, created_at, '
          'resolved_at, resolution_note, created_by',
        )
        .eq('order_id', orderId)
        .order('created_at', ascending: false);
    if (response is List) {
      final List<ReturnRequest> requests = [];
      for (final row in response) {
        if (row is Map<String, dynamic>) {
          requests.add(ReturnRequest.fromJson(row));
        } else if (row is Map) {
          requests.add(ReturnRequest.fromJson(Map<String, dynamic>.from(row)));
        }
      }
      return requests;
    }
    return const <ReturnRequest>[];
  }

  @override
  Future<ReturnRequestSubmission> submitReturnRequest({
    required String orderId,
    required String orderItemId,
    required double qty,
    String? reason,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'order_id': orderId,
      'order_item_id': orderItemId,
      'qty': qty,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };

    final _InvocationResult result = await _invokeOrQueue(payload);
    if (result.queued) {
      return const ReturnRequestSubmission(queued: true);
    }
    final Object? rawRequest = result.data['request'];
    if (rawRequest is Map) {
      final ReturnRequest request =
          ReturnRequest.fromJson(Map<String, dynamic>.from(rawRequest));
      return ReturnRequestSubmission(request: request);
    }
    return const ReturnRequestSubmission();
  }

  Future<Map<String, dynamic>> _invokeFunction(
    Map<String, dynamic> payload,
  ) async {
    final FunctionResponse response = await _client.functions.invoke(
      _functionEndpoint,
      body: payload,
    );
    if (response.status >= 400) {
      throw StateError(
        '$_functionEndpoint failed with status ${response.status}',
      );
    }
    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
  }

  Future<_InvocationResult> _invokeOrQueue(Map<String, dynamic> payload) async {
    try {
      final Map<String, dynamic> data = await _invokeFunction(payload);
      return _InvocationResult(data: data);
    } catch (error) {
      if (_shouldQueue(error)) {
        await _queue.enqueue(_functionEndpoint, payload);
        return const _InvocationResult(queued: true);
      }
      rethrow;
    }
  }

  bool _shouldQueue(Object error) {
    final String message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('name resolution failed') ||
        message.contains('service temporarily unavailable') ||
        message.contains('functionexception') ||
        message.contains('503') ||
        message.contains('network is unreachable') ||
        message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('offline');
  }
}

class _InvocationResult {
  const _InvocationResult({
    this.data = const <String, dynamic>{},
    this.queued = false,
  });

  final Map<String, dynamic> data;
  final bool queued;
}
