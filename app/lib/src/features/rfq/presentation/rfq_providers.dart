import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final rfqServiceProvider = Provider<RfqRemoteService>((ref) {
  return RfqRemoteService(Supabase.instance.client);
});

final customerRfqsProvider =
    FutureProvider.autoDispose<List<RfqSummary>>((ref) async {
  final service = ref.watch(rfqServiceProvider);
  return service.fetchRfqsForCurrentUser();
});

final vendorRfqsProvider =
    FutureProvider.autoDispose<List<RfqSummary>>((ref) async {
  final service = ref.watch(rfqServiceProvider);
  return service.fetchRfqsForVendor();
});

final rfqDetailProvider =
    FutureProvider.autoDispose.family<RfqDetail, String>((ref, rfqId) async {
  final service = ref.watch(rfqServiceProvider);
  return service.fetchRfqDetail(rfqId);
});

final rfqActionControllerProvider = Provider<RfqActionController>((ref) {
  final service = ref.read(rfqServiceProvider);
  return RfqActionController(ref, service);
});

class RfqActionController {
  RfqActionController(this._ref, this._service);

  final Ref _ref;
  final RfqRemoteService _service;

  Future<String> createRfq({
    required List<RfqDraftLine> lines,
    Map<String, dynamic>? terms,
    Map<String, dynamic>? metadata,
  }) async {
    final String rfqId = await _service.createRfq(
      items: lines,
      terms: terms,
      metadata: metadata,
    );
    _invalidateLists();
    return rfqId;
  }

  Future<void> postMessage({
    required String rfqId,
    required String body,
  }) async {
    await _service.postMessage(rfqId: rfqId, body: body);
    _ref.invalidate(rfqDetailProvider(rfqId));
  }

  Future<String> submitQuote({
    required String rfqId,
    required List<RfqQuoteDraftLine> items,
    Map<String, dynamic>? terms,
  }) async {
    final String quoteId = await _service.submitQuote(
      rfqId: rfqId,
      items: items,
      terms: terms,
    );
    _invalidateLists();
    _ref.invalidate(rfqDetailProvider(rfqId));
    return quoteId;
  }

  Future<String> acceptQuote(String quoteId) async {
    final String orderId = await _service.acceptQuote(quoteId);
    _invalidateLists();
    return orderId;
  }

  void _invalidateLists() {
    _ref
      ..invalidate(customerRfqsProvider)
      ..invalidate(vendorRfqsProvider);
  }
}

class RfqRemoteService {
  RfqRemoteService(this.client);

  final SupabaseClient client;

  Future<List<RfqSummary>> fetchRfqsForCurrentUser() async {
    try {
      final dynamic response = await client
          .from('rfqs')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
      if (response is List) {
        return response
            .map((dynamic row) => _summaryFromRow(_stringKeyMap(row)))
            .whereType<RfqSummary>()
            .toList(growable: false);
      }
    } catch (error, stack) {
      debugPrint('RFQ fetch (customer) failed: $error');
      Error.throwWithStackTrace(error, stack);
    }
    return const <RfqSummary>[];
  }

  Future<List<RfqSummary>> fetchRfqsForVendor() async {
    try {
      final dynamic response = await client
          .from('rfqs')
          .select()
          .order('created_at', ascending: false)
          .limit(100);
      if (response is List) {
        return response
            .map((dynamic row) => _summaryFromRow(_stringKeyMap(row)))
            .whereType<RfqSummary>()
            .toList(growable: false);
      }
    } catch (error, stack) {
      debugPrint('RFQ fetch (vendor) failed: $error');
      Error.throwWithStackTrace(error, stack);
    }
    return const <RfqSummary>[];
  }

  Future<RfqDetail> fetchRfqDetail(String rfqId) async {
    final Map<String, dynamic> header = await _fetchRfqHead(rfqId);
    final List<RfqItem> items = await _fetchItems(rfqId);
    final List<RfqQuote> quotes = await _fetchQuotes(rfqId);
    final List<RfqMessage> messages = await _fetchMessages(rfqId);
    return RfqDetail(
      id: rfqId,
      status: header['status']?.toString() ?? 'open',
      reference: header['reference']?.toString(),
      createdAt: _parseDate(header['created_at']) ?? DateTime.now().toUtc(),
      needBy: _parseDate(header['need_by']),
      terms: header['terms'] is Map<String, dynamic>
          ? header['terms'] as Map<String, dynamic>
          : _decodeJsonMap(header['terms']),
      items: items,
      quotes: quotes,
      messages: messages,
      metadata: header['metadata'] is Map<String, dynamic>
          ? header['metadata'] as Map<String, dynamic>
          : _decodeJsonMap(header['metadata']),
    );
  }

  Future<Map<String, dynamic>> _fetchRfqHead(String rfqId) async {
    final dynamic response =
        await client.from('rfqs').select().eq('id', rfqId).maybeSingle();
    if (response is Map) {
      return _stringKeyMap(response);
    }
    return <String, dynamic>{};
  }

  Future<List<RfqItem>> _fetchItems(String rfqId) async {
    try {
      final dynamic response = await client
          .from('rfq_items')
          .select()
          .eq('rfq_id', rfqId)
          .order('line_number', ascending: true);
      if (response is List) {
        return response
            .map((dynamic row) => _itemFromRow(_stringKeyMap(row)))
            .whereType<RfqItem>()
            .toList(growable: false);
      }
    } catch (error, stack) {
      debugPrint('RFQ items fetch failed: $error');
      Error.throwWithStackTrace(error, stack);
    }
    return const <RfqItem>[];
  }

  Future<List<RfqQuote>> _fetchQuotes(String rfqId) async {
    try {
      final dynamic response = await client
          .from('rfq_quotes')
          .select()
          .eq('rfq_id', rfqId)
          .order('created_at', ascending: false);
      if (response is List) {
        return response
            .map((dynamic row) => _quoteFromRow(_stringKeyMap(row)))
            .whereType<RfqQuote>()
            .toList(growable: false);
      }
    } catch (error, stack) {
      debugPrint('RFQ quotes fetch failed: $error');
      Error.throwWithStackTrace(error, stack);
    }
    return const <RfqQuote>[];
  }

  Future<List<RfqMessage>> _fetchMessages(String rfqId) async {
    try {
      final dynamic response = await client
          .from('rfq_messages')
          .select()
          .eq('rfq_id', rfqId)
          .order('created_at', ascending: true);
      if (response is List) {
        return response
            .map((dynamic row) => _messageFromRow(_stringKeyMap(row)))
            .whereType<RfqMessage>()
            .toList(growable: false);
      }
    } catch (error, stack) {
      debugPrint('RFQ messages fetch failed: $error');
      Error.throwWithStackTrace(error, stack);
    }
    return const <RfqMessage>[];
  }

  Future<String> createRfq({
    required List<RfqDraftLine> items,
    Map<String, dynamic>? terms,
    Map<String, dynamic>? metadata,
  }) async {
    final List<Map<String, dynamic>> serialized =
        items.map((RfqDraftLine line) {
      return <String, dynamic>{
        'variant_id': line.variantId,
        'qty': line.qty,
        if (line.customerNotes != null && line.customerNotes!.isNotEmpty)
          'notes': line.customerNotes,
      };
    }).toList(growable: false);
    final Map<String, dynamic> payload = <String, dynamic>{
      'items': serialized,
      if (terms != null && terms.isNotEmpty) 'terms': terms,
      if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
    };
    final dynamic response = await client.rpc<dynamic>(
      'rpc_create_rfq',
      params: payload,
    );
    if (response is Map && response['rfq_id'] is String) {
      return response['rfq_id'] as String;
    }
    if (response is String && response.isNotEmpty) {
      return response;
    }
    if (response is Map && response['id'] is String) {
      return response['id'] as String;
    }
    throw StateError('rpc_create_rfq did not return an rfq_id');
  }

  Future<void> postMessage({
    required String rfqId,
    required String body,
  }) async {
    final String trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(body, 'body', 'cannot be empty');
    }
    try {
      await client.rpc<dynamic>(
        'rpc_post_rfq_message',
        params: <String, dynamic>{
          'rfq_id': rfqId,
          'body': trimmed,
        },
      );
    } catch (error) {
      debugPrint('RFQ message RPC missing, fallback to insert: $error');
      await client.from('rfq_messages').insert(<String, dynamic>{
        'rfq_id': rfqId,
        'body': trimmed,
      });
    }
  }

  Future<String> submitQuote({
    required String rfqId,
    required List<RfqQuoteDraftLine> items,
    Map<String, dynamic>? terms,
  }) async {
    final List<Map<String, dynamic>> serialized =
        items.map((RfqQuoteDraftLine line) {
      return <String, dynamic>{
        'rfq_item_id': line.rfqItemId,
        'unit_price': line.unitPrice,
        'min_qty': line.minimumOrderQty,
        if (line.stepQty != null) 'step_qty': line.stepQty,
        if (line.leadTimeDays != null) 'lead_time_days': line.leadTimeDays,
      };
    }).toList(growable: false);
    final dynamic response = await client.rpc<dynamic>(
      'rpc_vendor_submit_quote',
      params: <String, dynamic>{
        'rfq_id': rfqId,
        'items': serialized,
        if (terms != null && terms.isNotEmpty) 'terms': terms,
      },
    );
    if (response is Map && response['quote_id'] is String) {
      return response['quote_id'] as String;
    }
    if (response is String && response.isNotEmpty) {
      return response;
    }
    throw StateError('rpc_vendor_submit_quote did not return quote_id');
  }

  Future<String> acceptQuote(String quoteId) async {
    final dynamic response = await client.rpc<dynamic>(
      'rpc_customer_accept_quote',
      params: <String, dynamic>{'quote_id': quoteId},
    );
    if (response is Map && response['order_id'] is String) {
      return response['order_id'] as String;
    }
    if (response is String && response.isNotEmpty) {
      return response;
    }
    if (response is Map && response['id'] is String) {
      return response['id'] as String;
    }
    throw StateError('rpc_customer_accept_quote did not return order id');
  }

  RfqSummary? _summaryFromRow(Map<String, dynamic> row) {
    final String? id = row['id']?.toString();
    if (id == null || id.isEmpty) {
      return null;
    }
    return RfqSummary(
      id: id,
      status: row['status']?.toString() ?? 'open',
      reference: row['reference']?.toString(),
      createdAt: _parseDate(row['created_at']) ?? DateTime.now().toUtc(),
      needBy: _parseDate(row['need_by']),
      updatedAt: _parseDate(row['updated_at']) ?? _parseDate(row['created_at']),
      itemCount: _parseInt(row['item_count']),
      quoteCount: _parseInt(row['quote_count']),
      latestQuoteStatus: row['latest_quote_status']?.toString(),
      totalEstimate: _parseDouble(row['estimated_total']),
    );
  }

  RfqItem? _itemFromRow(Map<String, dynamic> row) {
    final String? id = row['id']?.toString();
    if (id == null || id.isEmpty) {
      return null;
    }
    return RfqItem(
      id: id,
      rfqId: row['rfq_id']?.toString() ?? '',
      description: row['description']?.toString(),
      sku: row['sku']?.toString(),
      qty: _parseDouble(row['qty']) ?? 0,
      uom: row['uom']?.toString(),
      variantId: row['variant_id']?.toString(),
      customerNotes: row['notes']?.toString(),
    );
  }

  RfqQuote? _quoteFromRow(Map<String, dynamic> row) {
    final String? id = row['id']?.toString();
    if (id == null || id.isEmpty) {
      return null;
    }
    return RfqQuote(
      id: id,
      rfqId: row['rfq_id']?.toString() ?? '',
      status: row['status']?.toString() ?? 'draft',
      createdAt: _parseDate(row['created_at']) ?? DateTime.now().toUtc(),
      terms: _extractMap(row['terms']),
      vendorCompanyId: row['vendor_company_id']?.toString(),
      total: _parseDouble(row['total']),
    );
  }

  RfqMessage? _messageFromRow(Map<String, dynamic> row) {
    final String? id = row['id']?.toString();
    if (id == null || id.isEmpty) {
      return null;
    }
    return RfqMessage(
      id: id,
      rfqId: row['rfq_id']?.toString() ?? '',
      body: row['body']?.toString() ?? '',
      authorRole: row['author_role']?.toString(),
      createdAt: _parseDate(row['created_at']) ?? DateTime.now().toUtc(),
    );
  }
}

class RfqSummary {
  const RfqSummary({
    required this.id,
    required this.status,
    required this.createdAt,
    this.reference,
    this.needBy,
    this.updatedAt,
    this.itemCount,
    this.quoteCount,
    this.latestQuoteStatus,
    this.totalEstimate,
  });

  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? needBy;
  final String? reference;
  final int? itemCount;
  final int? quoteCount;
  final String? latestQuoteStatus;
  final double? totalEstimate;

  String get displayReference =>
      (reference != null && reference!.trim().isNotEmpty) ? reference! : id;
}

class RfqItem {
  const RfqItem({
    required this.id,
    required this.rfqId,
    required this.qty,
    this.uom,
    this.variantId,
    this.description,
    this.sku,
    this.customerNotes,
  });

  final String id;
  final String rfqId;
  final double qty;
  final String? uom;
  final String? variantId;
  final String? description;
  final String? sku;
  final String? customerNotes;
}

class RfqQuote {
  const RfqQuote({
    required this.id,
    required this.rfqId,
    required this.status,
    required this.createdAt,
    this.vendorCompanyId,
    this.terms,
    this.total,
  });

  final String id;
  final String rfqId;
  final String status;
  final DateTime createdAt;
  final String? vendorCompanyId;
  final Map<String, dynamic>? terms;
  final double? total;
}

class RfqMessage {
  const RfqMessage({
    required this.id,
    required this.rfqId,
    required this.body,
    required this.createdAt,
    this.authorRole,
  });

  final String id;
  final String rfqId;
  final String body;
  final String? authorRole;
  final DateTime createdAt;
}

class RfqDetail {
  const RfqDetail({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.items,
    required this.quotes,
    required this.messages,
    this.needBy,
    this.reference,
    this.terms,
    this.metadata,
  });

  final String id;
  final String status;
  final DateTime createdAt;
  final DateTime? needBy;
  final String? reference;
  final Map<String, dynamic>? terms;
  final Map<String, dynamic>? metadata;
  final List<RfqItem> items;
  final List<RfqQuote> quotes;
  final List<RfqMessage> messages;
}

class RfqDraftLine {
  const RfqDraftLine({
    required this.variantId,
    required this.qty,
    this.customerNotes,
  });

  final String variantId;
  final double qty;
  final String? customerNotes;
}

class RfqQuoteDraftLine {
  const RfqQuoteDraftLine({
    required this.rfqItemId,
    required this.unitPrice,
    this.minimumOrderQty,
    this.stepQty,
    this.leadTimeDays,
  });

  final String rfqItemId;
  final double unitPrice;
  final double? minimumOrderQty;
  final double? stepQty;
  final int? leadTimeDays;
}

Map<String, dynamic> _stringKeyMap(dynamic source) {
  if (source is Map) {
    return source.map(
      (dynamic key, dynamic value) => MapEntry(key?.toString() ?? '', value),
    );
  }
  return <String, dynamic>{};
}

Map<String, dynamic>? _extractMap(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (dynamic key, dynamic val) => MapEntry(key?.toString() ?? '', val),
    );
  }
  if (value is String && value.trim().isNotEmpty) {
    return _decodeJsonMap(value);
  }
  return null;
}

Map<String, dynamic>? _decodeJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (dynamic key, dynamic val) => MapEntry(key?.toString() ?? '', val),
    );
  }
  if (value is String) {
    try {
      final dynamic decoded = jsonDecode(value);
      if (decoded is Map) {
        return decoded.map(
          (dynamic key, dynamic val) => MapEntry(key?.toString() ?? '', val),
        );
      }
    } catch (_) {
      return <String, dynamic>{'raw': value};
    }
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

int? _parseInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}
