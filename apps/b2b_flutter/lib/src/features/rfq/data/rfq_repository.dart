import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:ashachar_marketplace/src/features/rfq/domain/rfq_models.dart';

abstract class RfqRepository {
  Future<RfqRequest> create({
    required String buyerId,
    required List<RfqLine> lines,
    String? notes,
    required String targetCurrency,
    required DateTime requestedDeliveryDate,
  });

  Stream<List<Quote>> watchQuotes(String rfqId);

  Future<Quote> getQuote(String quoteId);

  Future<void> convertToOrder(String quoteId);
}

class FakeRfqRepository implements RfqRepository {
  FakeRfqRepository({
    this.latency = const Duration(milliseconds: 300),
    Iterable<RfqRequest>? seedRequests,
    Iterable<Quote>? seedQuotes,
    this.failCreate = false,
    this.failConvert = false,
  }) {
    for (final RfqRequest request in seedRequests ?? <RfqRequest>[]) {
      _rfqs[request.id] = request;
      _quotesByRfq.putIfAbsent(request.id, () => <Quote>[]);
    }
    for (final Quote quote in seedQuotes ?? <Quote>[]) {
      addQuote(quote);
    }
  }

  final Duration latency;
  final bool failCreate;
  final bool failConvert;
  final Uuid _uuid = const Uuid();

  final Map<String, RfqRequest> _rfqs = <String, RfqRequest>{};
  final Map<String, List<Quote>> _quotesByRfq = <String, List<Quote>>{};
  final Map<String, StreamController<List<Quote>>> _controllers =
      <String, StreamController<List<Quote>>>{};

  @override
  Future<RfqRequest> create({
    required String buyerId,
    required List<RfqLine> lines,
    String? notes,
    required String targetCurrency,
    required DateTime requestedDeliveryDate,
  }) async {
    await _maybeDelay();
    if (failCreate) {
      throw Exception('rfq.create.failed');
    }
    final String id = _uuid.v4();
    final RfqRequest request = RfqRequest(
      id: id,
      buyerId: buyerId,
      lines: List<RfqLine>.unmodifiable(lines),
      notes: notes,
      targetCurrency: targetCurrency,
      requestedDeliveryDate: requestedDeliveryDate,
      status: RfqStatus.sent,
    );
    _rfqs[id] = request;
    _quotesByRfq.putIfAbsent(id, () => <Quote>[]);
    _emitQuotes(id);
    _log('rfq.created', {'rfqId': id, 'buyerId': buyerId});
    return request;
  }

  @override
  Stream<List<Quote>> watchQuotes(String rfqId) {
    final StreamController<List<Quote>> controller =
        _controllers.putIfAbsent(rfqId, () {
      final StreamController<List<Quote>> streamController =
          StreamController<List<Quote>>.broadcast();
      streamController.onListen = () {
        streamController.add(List<Quote>.unmodifiable(
          _sortedQuotes(_quotesByRfq[rfqId] ?? <Quote>[]),
        ));
      };
      return streamController;
    });
    return controller.stream;
  }

  @override
  Future<Quote> getQuote(String quoteId) async {
    await _maybeDelay();
    for (final List<Quote> quotes in _quotesByRfq.values) {
      for (final Quote quote in quotes) {
        if (quote.id == quoteId) {
          _log('quote.viewed', {'quoteId': quoteId, 'rfqId': quote.rfqId});
          return quote;
        }
      }
    }
    throw StateError('Quote $quoteId not found');
  }

  @override
  Future<void> convertToOrder(String quoteId) async {
    await _maybeDelay();
    if (failConvert) {
      throw Exception('rfq.convert.failed');
    }
    final Quote quote = await getQuote(quoteId);
    final RfqRequest? request = _rfqs[quote.rfqId];
    if (request != null) {
      _rfqs[quote.rfqId] = request.copyWith(status: RfqStatus.converted);
    }
    _log('quote.converted', {'quoteId': quoteId, 'rfqId': quote.rfqId});
  }

  @visibleForTesting
  void addQuote(Quote quote) {
    final List<Quote> quotes =
        _quotesByRfq.putIfAbsent(quote.rfqId, () => <Quote>[]);
    quotes.removeWhere((Quote existing) => existing.id == quote.id);
    quotes.add(quote);
    _emitQuotes(quote.rfqId);
  }

  @visibleForTesting
  RfqRequest? getRequest(String rfqId) => _rfqs[rfqId];

  void dispose() {
    for (final StreamController<List<Quote>> controller
        in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  void _emitQuotes(String rfqId) {
    final StreamController<List<Quote>>? controller = _controllers[rfqId];
    if (controller != null && !controller.isClosed) {
      controller.add(List<Quote>.unmodifiable(
        _sortedQuotes(_quotesByRfq[rfqId] ?? <Quote>[]),
      ));
    }
  }

  Future<void> _maybeDelay() async {
    if (latency <= Duration.zero) {
      return;
    }
    await Future<void>.delayed(latency);
  }

  List<Quote> _sortedQuotes(List<Quote> quotes) {
    final List<Quote> copy = List<Quote>.from(quotes);
    copy.sort((Quote a, Quote b) {
      final int versionCompare = b.version.compareTo(a.version);
      if (versionCompare != 0) {
        return versionCompare;
      }
      return b.validUntil.compareTo(a.validUntil);
    });
    return copy;
  }

  void _log(String event, Map<String, Object?> payload) {
    assert(() {
      // ignore: avoid_print
      print('[telemetry] $event ${payload.toString()}');
      return true;
    }());
  }
}
