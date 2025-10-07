import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/vendor_rfq_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_utils/tester_view_compat.dart';

void main() {
  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  testWidgets(
      'customer create → vendor quote → customer accept navigates to order',
      (WidgetTester tester) async {
    await tester.setDevicePixelRatio(1.0);
    await tester.setSurfaceSize(const Size(1200, 2400));
    final FakeRfqRemoteService fakeService = FakeRfqRemoteService();
    final ProviderContainer container = ProviderContainer(
      overrides: [rfqServiceProvider.overrideWithValue(fakeService)],
    );
    addTearDown(container.dispose);

    // Stage 1: customer creates RFQ from the cart stub and lands on detail page.
    final GoRouter createRouter = GoRouter(
      initialLocation: '/',
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const CustomerRfqsPage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'customer/cart',
              builder: (BuildContext context, GoRouterState state) =>
                  const _CartCreateStub(),
            ),
            GoRoute(
              path: 'customer/rfqs/:rfqId',
              builder: (BuildContext context, GoRouterState state) =>
                  CustomerRfqDetailPage(
                rfqId: state.pathParameters['rfqId']!,
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _localizedRouterApp(createRouter),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('rfq_create_btn')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('rfq_create_btn')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('rfq_detail_root')), findsOneWidget);

    createRouter.dispose();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    final String rfqId = fakeService.lastCreatedRfqId!;

    // Stage 2: vendor submits a quote via VendorQuotePage UI.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _localizedApp(
          Scaffold(
            body: Center(
              child: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    key: const ValueKey('vendor_root_stub'),
                    onPressed: () {},
                    child: const Text('vendor-root'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext vendorRoot =
        tester.element(find.byKey(const ValueKey('vendor_root_stub')));
    Navigator.of(vendorRoot).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => VendorQuotePage(rfqId: rfqId),
      ),
    );
    await tester.pumpAndSettle();

    final Finder priceField = find.byKey(
      ValueKey('vendor_quote_price_field_$rfqId-item-1'),
    );
    expect(priceField, findsOneWidget);
    await tester.enterText(priceField, '12.5');
    await tester.pump();

    final Finder submitQuoteFinder =
        find.byKey(const ValueKey('vendor_quote_submit_btn'));
    await tester.ensureVisible(submitQuoteFinder);
    await tester.tap(submitQuoteFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    // Stage 3: customer accepts the quote and navigates to order detail stub.
    final GoRouter detailRouter = GoRouter(
      initialLocation: '/customer/rfqs/$rfqId',
      routes: <GoRoute>[
        GoRoute(
          path: '/customer/rfqs/:rfqId',
          builder: (BuildContext context, GoRouterState state) =>
              CustomerRfqDetailPage(
            rfqId: state.pathParameters['rfqId']!,
          ),
        ),
        GoRoute(
          path: '/customer/orders/:orderId',
          builder: (BuildContext context, GoRouterState state) =>
              _OrderDetailStub(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _localizedRouterApp(detailRouter),
      ),
    );
    await tester.pumpAndSettle();

    final String quoteId = fakeService.lastCreatedQuoteId!;
    final Finder acceptFinder =
        find.byKey(ValueKey('rfq_accept_quote_btn_$quoteId'));
    await tester.ensureVisible(acceptFinder);
    expect(acceptFinder, findsOneWidget);

    await tester.tap(acceptFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('order_detail_stub')), findsOneWidget);

    detailRouter.dispose();
  });
}

MaterialApp _localizedApp(Widget child) {
  return MaterialApp(
    supportedLocales: const [Locale('en'), Locale('he')],
    localizationsDelegates: const [
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

MaterialApp _localizedRouterApp(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    supportedLocales: const [Locale('en'), Locale('he')],
    localizationsDelegates: const [
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

class _CartCreateStub extends ConsumerWidget {
  const _CartCreateStub();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton.icon(
          key: const ValueKey('rfq_create_btn'),
          onPressed: () async {
            final String rfqId =
                await ref.read(rfqActionControllerProvider).createRfq(
              lines: const [
                RfqDraftLine(variantId: 'variant-1', qty: 12),
              ],
              terms: const {'payment': 'net30'},
            );
            if (!context.mounted) {
              return;
            }
            GoRouter.of(context).go('/customer/rfqs/$rfqId');
          },
          icon: const Icon(Icons.request_quote_outlined),
          label: const Text('create-rfq'),
        ),
      ),
    );
  }
}

class _OrderDetailStub extends StatelessWidget {
  const _OrderDetailStub({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          key: const ValueKey('order_detail_stub'),
          child: Text('order-$orderId'),
        ),
      ),
    );
  }
}

class FakeRfqRemoteService extends RfqRemoteService {
  FakeRfqRemoteService()
      : super(
          SupabaseClient(
            'https://example.supabase.co',
            'public-anon-key',
            authOptions: const AuthClientOptions(autoRefreshToken: false),
          ),
        );

  final Map<String, _FakeRfqRecord> _records = <String, _FakeRfqRecord>{};
  int _rfqCounter = 0;
  int _quoteCounter = 0;
  int _orderCounter = 0;

  String? lastCreatedRfqId;
  String? lastCreatedQuoteId;
  String? lastCreatedOrderId;

  @override
  Future<List<RfqSummary>> fetchRfqsForCurrentUser() async {
    return _records.values.map(_toSummary).toList(growable: false);
  }

  @override
  Future<List<RfqSummary>> fetchRfqsForVendor() async {
    return _records.values.map(_toSummary).toList(growable: false);
  }

  @override
  Future<RfqDetail> fetchRfqDetail(String rfqId) async {
    final _FakeRfqRecord record = _requireRecord(rfqId);
    return RfqDetail(
      id: record.id,
      status: record.status,
      createdAt: record.createdAt,
      needBy: null,
      reference: null,
      terms: record.terms,
      metadata: record.metadata,
      items: List<RfqItem>.unmodifiable(record.items),
      quotes: List<RfqQuote>.unmodifiable(record.quotes),
      messages: List<RfqMessage>.unmodifiable(record.messages),
    );
  }

  @override
  Future<String> createRfq({
    required List<RfqDraftLine> items,
    Map<String, dynamic>? terms,
    Map<String, dynamic>? metadata,
  }) async {
    final String id = 'rfq-${++_rfqCounter}';
    final DateTime createdAt =
        DateTime(2024, 1, 1, 9, 0).add(Duration(minutes: _rfqCounter));
    final List<RfqItem> rfqItems = <RfqItem>[
      for (int i = 0; i < items.length; i++)
        RfqItem(
          id: '$id-item-${i + 1}',
          rfqId: id,
          qty: items[i].qty,
          uom: 'EA',
          variantId: items[i].variantId,
          description: 'Item ${i + 1}',
          sku: items[i].variantId,
          customerNotes: items[i].customerNotes,
        ),
    ];
    _records[id] = _FakeRfqRecord(
      id: id,
      createdAt: createdAt,
      items: rfqItems,
      terms: terms,
      metadata: metadata,
    );
    lastCreatedRfqId = id;
    return id;
  }

  @override
  Future<void> postMessage({
    required String rfqId,
    required String body,
  }) async {
    final _FakeRfqRecord record = _requireRecord(rfqId);
    record.messages.add(
      RfqMessage(
        id: '$rfqId-msg-${record.messages.length + 1}',
        rfqId: rfqId,
        body: body,
        createdAt:
            record.createdAt.add(Duration(minutes: record.messages.length + 1)),
        authorRole: 'customer',
      ),
    );
  }

  @override
  Future<String> submitQuote({
    required String rfqId,
    required List<RfqQuoteDraftLine> items,
    Map<String, dynamic>? terms,
  }) async {
    final _FakeRfqRecord record = _requireRecord(rfqId);
    final String quoteId = 'quote-${++_quoteCounter}';
    double total = 0;
    for (final RfqQuoteDraftLine line in items) {
      final RfqItem item =
          record.items.firstWhere((RfqItem it) => it.id == line.rfqItemId);
      final double quantity = line.minimumOrderQty ?? item.qty;
      total += line.unitPrice * quantity;
    }
    final RfqQuote quote = RfqQuote(
      id: quoteId,
      rfqId: rfqId,
      status: 'submitted',
      createdAt: record.createdAt.add(Duration(hours: _quoteCounter)),
      vendorCompanyId: 'vendor-stub',
      terms: terms,
      total: double.parse(total.toStringAsFixed(2)),
    );
    record.quotes.add(quote);
    record.status = 'quoted';
    lastCreatedQuoteId = quoteId;
    return quoteId;
  }

  @override
  Future<String> acceptQuote(String quoteId) async {
    final _FakeRfqRecord record = _records.values.firstWhere(
      (_FakeRfqRecord rec) =>
          rec.quotes.any((RfqQuote quote) => quote.id == quoteId),
    );
    final int index =
        record.quotes.indexWhere((RfqQuote quote) => quote.id == quoteId);
    final RfqQuote quote = record.quotes[index];
    record.quotes[index] = RfqQuote(
      id: quote.id,
      rfqId: quote.rfqId,
      status: 'accepted',
      createdAt: quote.createdAt,
      vendorCompanyId: quote.vendorCompanyId,
      terms: quote.terms,
      total: quote.total,
    );
    record.status = 'accepted';
    final String orderId = 'order-${++_orderCounter}';
    lastCreatedOrderId = orderId;
    return orderId;
  }

  RfqSummary _toSummary(_FakeRfqRecord record) {
    return RfqSummary(
      id: record.id,
      status: record.status,
      createdAt: record.createdAt,
      reference: null,
      itemCount: record.items.length,
      quoteCount: record.quotes.length,
      latestQuoteStatus:
          record.quotes.isEmpty ? null : record.quotes.last.status,
      needBy: null,
      updatedAt: record.createdAt,
      totalEstimate: record.quotes.isEmpty ? null : record.quotes.last.total,
    );
  }

  _FakeRfqRecord _requireRecord(String rfqId) {
    final _FakeRfqRecord? record = _records[rfqId];
    if (record == null) {
      throw StateError('Unknown rfqId: $rfqId');
    }
    return record;
  }
}

class _FakeRfqRecord {
  _FakeRfqRecord({
    required this.id,
    required this.createdAt,
    required this.items,
    this.terms,
    this.metadata,
  });

  final String id;
  final DateTime createdAt;
  final List<RfqItem> items;
  final Map<String, dynamic>? terms;
  final Map<String, dynamic>? metadata;
  String status = 'open';
  final List<RfqQuote> quotes = <RfqQuote>[];
  final List<RfqMessage> messages = <RfqMessage>[];
}
