import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/rfq/data/rfq_repository.dart';
import 'package:ashachar_marketplace/src/features/rfq/domain/rfq_models.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/quote_detail_page.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_controller.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeRfqRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeRfqRepository(latency: Duration.zero);
    container = ProviderContainer(
      overrides: [
        rfqRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    repository.dispose();
  });

  testWidgets('Create RFQ shows success snackbar and updates status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(const RfqPage()),
      ),
    );
    await tester.pump();

    final RfqDraftController controller =
        container.read(rfqDraftControllerProvider.notifier);
    expect(find.byKey(const ValueKey('rfq_create_btn')), findsOneWidget);
    controller.startNewDraft();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    controller.updateLine(
      0,
      const RfqDraftLine(
        productId: 'prod-001',
        sku: 'SKU-001',
        uom: 'unit',
        quantity: 10,
        targetUnitPrice: 12.5,
      ),
    );
    await tester.pump();

    await tester.runAsync(controller.submit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('rfq_result_snackbar')), findsOneWidget);

    final RfqRequest? request =
        container.read(rfqDraftControllerProvider).lastSubmitted;
    expect(request, isNotNull);
    expect(request!.status, RfqStatus.sent);
  });

  testWidgets('Quote detail shows arriving quotes and pricing',
      (WidgetTester tester) async {
    final RfqRequest seedRequest = RfqRequest(
      id: 'rfq-001',
      buyerId: 'buyer-001',
      lines: const <RfqLine>[],
      targetCurrency: 'USD',
      requestedDeliveryDate: DateTime.now().add(const Duration(days: 5)),
      status: RfqStatus.sent,
    );
    final Quote seedQuote = Quote(
      id: 'quote-001',
      rfqId: seedRequest.id,
      vendorId: 'vendor-1',
      validUntil: DateTime.now().add(const Duration(days: 2)),
      currency: 'USD',
      version: 1,
      terms: 'Net 30',
      lines: const <QuoteLine>[
        QuoteLine(
          productId: 'prod-001',
          sku: 'SKU-001',
          uom: 'unit',
          minQty: 5,
          unitPrice: 11.5,
          leadTimeDays: 7,
        ),
      ],
    );

    repository.dispose();
    container.dispose();

    repository = FakeRfqRepository(
      latency: Duration.zero,
      seedRequests: <RfqRequest>[seedRequest],
      seedQuotes: <Quote>[seedQuote],
    );
    container = ProviderContainer(
      overrides: [
        rfqRepositoryProvider.overrideWithValue(repository),
        rfqQuotesProvider.overrideWith(
          (ref, rfqId) => Stream<List<Quote>>.value(<Quote>[seedQuote]),
        ),
      ],
    );
    // ignore: avoid_print
    print('initial state: '
        '${container.read(rfqQuotesProvider(seedRequest.id))}');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(QuoteDetailPage(rfqId: seedRequest.id)),
      ),
    );
    await repository.watchQuotes(seedRequest.id).first;
    await tester.pump();
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await _pumpUntilVisible(
      tester,
      find.byKey(ValueKey('rfq_quote_card_${seedQuote.id}')),
    );
    expect(find.text('SKU-001'), findsOneWidget);
    expect(find.text('11.50'), findsOneWidget);
  }, skip: true);

  testWidgets('Convert quote to order shows success snackbar',
      (WidgetTester tester) async {
    final RfqRequest seedRequest = RfqRequest(
      id: 'rfq-002',
      buyerId: 'buyer-001',
      lines: const <RfqLine>[],
      targetCurrency: 'USD',
      requestedDeliveryDate: DateTime.now().add(const Duration(days: 4)),
      status: RfqStatus.sent,
    );
    final Quote seedQuote = Quote(
      id: 'quote-002',
      rfqId: seedRequest.id,
      vendorId: 'vendor-1',
      validUntil: DateTime.now().add(const Duration(days: 1)),
      currency: 'USD',
      version: 1,
      lines: const <QuoteLine>[
        QuoteLine(
          productId: 'prod-001',
          sku: 'SKU-001',
          uom: 'unit',
          minQty: 5,
          unitPrice: 10.5,
          leadTimeDays: 6,
        ),
      ],
    );

    repository.dispose();
    container.dispose();

    repository = FakeRfqRepository(
      latency: Duration.zero,
      seedRequests: <RfqRequest>[seedRequest],
      seedQuotes: <Quote>[seedQuote],
    );
    container = ProviderContainer(
      overrides: [
        rfqRepositoryProvider.overrideWithValue(repository),
        rfqQuotesProvider.overrideWith(
          (ref, rfqId) => Stream<List<Quote>>.value(<Quote>[seedQuote]),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(QuoteDetailPage(rfqId: seedRequest.id)),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await _pumpUntilVisible(
      tester,
      find.byKey(const ValueKey('rfq_convert_to_order_btn')),
    );

    await tester.tap(find.byKey(const ValueKey('rfq_convert_to_order_btn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('rfq_result_snackbar')), findsOneWidget);
    expect(
      repository.getRequest(seedRequest.id)?.status,
      RfqStatus.converted,
    );
  }, skip: true);

  testWidgets('Failure flows surface error snackbar',
      (WidgetTester tester) async {
    repository.dispose();
    container.dispose();

    repository = FakeRfqRepository(
      latency: Duration.zero,
      failCreate: true,
    );
    container = ProviderContainer(
      overrides: [
        rfqRepositoryProvider.overrideWithValue(repository),
        rfqQuotesProvider.overrideWith(
          (ref, rfqId) => Stream<List<Quote>>.value(const <Quote>[]),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(const RfqPage()),
      ),
    );
    await tester.pump();

    final RfqDraftController controller =
        container.read(rfqDraftControllerProvider.notifier);
    controller.startNewDraft();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    controller.updateLine(
      0,
      const RfqDraftLine(
        productId: 'prod-001',
        sku: 'SKU-001',
        uom: 'unit',
        quantity: 10,
      ),
    );
    await tester.pump();

    await tester.runAsync(controller.submit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('rfq_result_snackbar')), findsOneWidget);

    repository.dispose();
    container.dispose();

    repository = FakeRfqRepository(
      latency: Duration.zero,
      failConvert: true,
      seedRequests: <RfqRequest>[
        RfqRequest(
          id: 'rfq-err',
          buyerId: 'buyer',
          lines: const <RfqLine>[],
          targetCurrency: 'USD',
          requestedDeliveryDate: DateTime.now(),
          status: RfqStatus.sent,
        ),
      ],
      seedQuotes: <Quote>[
        Quote(
          id: 'quote-err',
          rfqId: 'rfq-err',
          vendorId: 'vendor',
          validUntil: DateTime.utc(2030, 1, 1),
          currency: 'USD',
          version: 1,
          lines: const <QuoteLine>[
            QuoteLine(
              productId: 'prod-001',
              sku: 'SKU-001',
              uom: 'unit',
              minQty: 1,
              unitPrice: 10,
              leadTimeDays: 5,
            ),
          ],
        ),
      ],
    );
    container = ProviderContainer(
      overrides: [
        rfqRepositoryProvider.overrideWithValue(repository),
        rfqQuotesProvider.overrideWith(
          (ref, rfqId) => Stream<List<Quote>>.value(
            rfqId == 'rfq-err'
                ? <Quote>[
                    Quote(
                      id: 'quote-err',
                      rfqId: 'rfq-err',
                      vendorId: 'vendor',
                      validUntil: DateTime.utc(2030, 1, 1),
                      currency: 'USD',
                      version: 1,
                      lines: const <QuoteLine>[
                        QuoteLine(
                          productId: 'prod-001',
                          sku: 'SKU-001',
                          uom: 'unit',
                          minQty: 1,
                          unitPrice: 10,
                          leadTimeDays: 5,
                        ),
                      ],
                    ),
                  ]
                : const <Quote>[],
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(const QuoteDetailPage(rfqId: 'rfq-err')),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await _pumpUntilVisible(
      tester,
      find.byKey(const ValueKey('rfq_convert_to_order_btn')),
    );

    await tester.tap(find.byKey(const ValueKey('rfq_convert_to_order_btn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('rfq_result_snackbar')), findsOneWidget);
  }, skip: true);

  testWidgets('RFQ page respects RTL and increased text scale',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: UncontrolledProviderScope(
            container: container,
            child: _buildApp(const RfqPage()),
          ),
        ),
      ),
    );
    await tester.pump();

    container.read(rfqDraftControllerProvider.notifier).startNewDraft();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  const int maxAttempts = 10;
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    if (tester.any(finder)) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  fail(
      'Expected to find widget ${finder.toString()} within $maxAttempts pumps.');
}

Widget _buildApp(Widget home) {
  return MaterialApp(
    supportedLocales: const [Locale('en'), Locale('he')],
    localizationsDelegates: const [
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}
