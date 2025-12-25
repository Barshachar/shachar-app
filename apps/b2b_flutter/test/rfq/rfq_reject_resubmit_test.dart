import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart'
    show CustomerRfqDetailPage, rfqResubmitActionProvider;
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  testWidgets(
      'rejected RFQ exposes resubmit CTA and pending status after action',
      (WidgetTester tester) async {
    const String testRfqId = 'rfq-resubmit-1';
    final _TestRfqStore store = _TestRfqStore(
      RfqDetail(
        id: testRfqId,
        status: 'open',
        createdAt: DateTime(2024, 4, 1, 11, 30),
        needBy: DateTime(2024, 4, 20, 9, 0),
        reference: 'PO-4401',
        terms: const {'memo': 'הספקה תוך שבוע'},
        metadata: const {},
        items: const [
          RfqItem(
            id: 'item-1',
            rfqId: testRfqId,
            qty: 5,
            uom: 'EA',
            description: 'מחשב נייד',
            sku: 'SKU-11',
            variantId: 'VAR-11',
          ),
        ],
        quotes: const <RfqQuote>[],
        messages: const <RfqMessage>[],
      ),
    );

    final ProviderContainer container = ProviderContainer(
      overrides: [
        rfqDetailProvider.overrideWith((ref, id) async {
          if (id != testRfqId) {
            throw StateError('unexpected rfqId: $id');
          }
          return store.detail;
        }),
        rfqResubmitActionProvider.overrideWith((ref) {
          return ({required String rfqId}) async {
            if (rfqId != testRfqId) {
              throw StateError('unexpected rfqId: $rfqId');
            }
            store.update(status: 'awaiting_quotes');
          };
        }),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildMaterialApp(
          const CustomerRfqDetailPage(rfqId: testRfqId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext detailContext = tester.element(
      find.byKey(const ValueKey('rfq_detail_root')),
    );
    final MarketplaceLocalizations l10n =
        Localizations.of<MarketplaceLocalizations>(
      detailContext,
      MarketplaceLocalizations,
    )!;
    final String awaitingQuotesLabel =
        l10n.translate('rfqStatusAwaitingQuotes');
    expect(find.textContaining(awaitingQuotesLabel), findsOneWidget);

    store.update(status: 'rejected');
    container.invalidate(rfqDetailProvider(testRfqId));
    await tester.pump();
    await tester.pumpAndSettle();

    final Finder resubmitFinder =
        find.byKey(const ValueKey('rfq_resubmit_btn'));
    expect(resubmitFinder, findsOneWidget);

    await tester.tap(resubmitFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining(awaitingQuotesLabel), findsOneWidget);
  });
}

MaterialApp _buildMaterialApp(Widget home) {
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

class _TestRfqStore {
  _TestRfqStore(this._detail);

  RfqDetail _detail;

  RfqDetail get detail => _detail;

  void update({String? status, List<RfqQuote>? quotes}) {
    _detail = RfqDetail(
      id: _detail.id,
      status: status ?? _detail.status,
      createdAt: _detail.createdAt,
      needBy: _detail.needBy,
      reference: _detail.reference,
      terms: _detail.terms,
      metadata: _detail.metadata,
      items: _detail.items,
      quotes: quotes ?? _detail.quotes,
      messages: _detail.messages,
    );
  }
}
