import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/orders/domain/order_cancellation.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_cancellation_repository.dart';
import 'package:offline_toolkit/offline_toolkit.dart';

final orderCancellationRepositoryProvider =
    Provider<OrderCancellationRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  return SupabaseOrderCancellationRepository(client: client, queue: queue);
});

class SupabaseOrderCancellationRepository
    implements OrderCancellationRepository {
  SupabaseOrderCancellationRepository({
    required SupabaseClient client,
    required OfflineQueue queue,
  })  : _client = client,
        _queue = queue;

  final SupabaseClient _client;
  final OfflineQueue _queue;

  static const String _functionEndpoint = 'order_cancel_submit';

  @override
  Future<OrderCancellationSubmission> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'order_id': orderId,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };

    final _InvocationResult result = await _invokeOrQueue(payload);
    if (result.queued) {
      return const OrderCancellationSubmission(queued: true);
    }
    final Object? rawOrder = result.data['order'];
    if (rawOrder is Map) {
      final OrderCancellation cancellation = OrderCancellation.fromJson(
        Map<String, dynamic>.from(rawOrder),
      );
      return OrderCancellationSubmission(cancellation: cancellation);
    }
    return const OrderCancellationSubmission();
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

  Future<_InvocationResult> _invokeOrQueue(
    Map<String, dynamic> payload,
  ) async {
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
