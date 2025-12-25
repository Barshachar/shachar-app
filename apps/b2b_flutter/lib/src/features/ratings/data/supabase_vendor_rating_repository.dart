import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating.dart';
import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating_repository.dart';
import 'package:offline_toolkit/offline_toolkit.dart';

final vendorRatingRepositoryProvider = Provider<VendorRatingRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  return SupabaseVendorRatingRepository(client: client, queue: queue);
});

class SupabaseVendorRatingRepository implements VendorRatingRepository {
  SupabaseVendorRatingRepository({
    required SupabaseClient client,
    required OfflineQueue queue,
  })  : _client = client,
        _queue = queue;

  final SupabaseClient _client;
  final OfflineQueue _queue;

  static const String _functionEndpoint = 'vendor_rating_submit';

  @override
  Future<VendorRatingSummary?> fetchSummary(String vendorCompanyId) async {
    if (vendorCompanyId.trim().isEmpty) {
      return null;
    }
    final dynamic row = await _client
        .from('vendor_rating_summary')
        .select()
        .eq('vendor_company_id', vendorCompanyId)
        .maybeSingle();
    if (row is Map<String, dynamic>) {
      return VendorRatingSummary.fromJson(row);
    }
    if (row is Map) {
      return VendorRatingSummary.fromJson(Map<String, dynamic>.from(row));
    }
    return null;
  }

  @override
  Future<VendorRating?> fetchRatingForOrder({
    required String orderId,
    required String vendorCompanyId,
  }) async {
    if (orderId.trim().isEmpty || vendorCompanyId.trim().isEmpty) {
      return null;
    }
    final dynamic row = await _client
        .from('vendor_ratings')
        .select()
        .eq('order_id', orderId)
        .eq('vendor_company_id', vendorCompanyId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row is Map<String, dynamic>) {
      return VendorRating.fromJson(row);
    }
    if (row is Map) {
      return VendorRating.fromJson(Map<String, dynamic>.from(row));
    }
    return null;
  }

  @override
  Future<VendorRatingSubmission> submitRating({
    required String orderId,
    required String vendorCompanyId,
    required int rating,
    String? comment,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'order_id': orderId,
      'vendor_company_id': vendorCompanyId,
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    };

    final _InvocationResult result = await _invokeOrQueue(payload);
    if (result.queued) {
      return const VendorRatingSubmission(queued: true);
    }
    final Object? rawRating = result.data['rating'];
    if (rawRating is Map) {
      final VendorRating ratingModel =
          VendorRating.fromJson(Map<String, dynamic>.from(rawRating));
      return VendorRatingSubmission(rating: ratingModel);
    }
    return const VendorRatingSubmission();
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
