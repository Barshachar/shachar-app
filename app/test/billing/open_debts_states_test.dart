import 'dart:async';

import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/open_debts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('he');
  });

  const OpenDebtsSummary emptySummary = OpenDebtsSummary(
    totalDue: 0,
    buckets: <OpenDebtBucket>[
      OpenDebtBucket(keySuffix: '0_30', label: '0-30', amount: 0),
      OpenDebtBucket(keySuffix: '31_60', label: '31-60', amount: 0),
      OpenDebtBucket(keySuffix: '61_90', label: '61-90', amount: 0),
      OpenDebtBucket(keySuffix: '90_plus', label: '90+', amount: 0),
    ],
  );

  final OpenDebtsSummary nonEmptySummary = OpenDebtsSummary(
    totalDue: 12850,
    buckets: const <OpenDebtBucket>[
      OpenDebtBucket(keySuffix: '0_30', label: '0-30', amount: 4820),
      OpenDebtBucket(keySuffix: '31_60', label: '31-60', amount: 3460),
      OpenDebtBucket(keySuffix: '61_90', label: '61-90', amount: 2710),
      OpenDebtBucket(keySuffix: '90_plus', label: '90+', amount: 2860),
    ],
  );

  final List<BillingInvoice> sampleInvoices = <BillingInvoice>[
    BillingInvoice(
      id: 'inv_a',
      number: 'INV-A',
      dueDate: DateTime(2024, 7, 10),
      amount: 1200,
    ),
    BillingInvoice(
      id: 'inv_b',
      number: 'INV-B',
      dueDate: DateTime(2024, 7, 20),
      amount: 640,
    ),
  ];

  testWidgets('open debts summary surfaces loading, empty, and error states',
      (WidgetTester tester) async {
    final Completer<OpenDebtsSummary> pending = Completer<OpenDebtsSummary>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openDebtsSummaryProvider.overrideWith((ref) => pending.future),
          openInvoicesProvider.overrideWith((ref) async => <BillingInvoice>[]),
        ],
        child: const _BillingHarness(),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const ValueKey('open_debts_loading_spinner')),
      findsOneWidget,
    );

    pending.complete(emptySummary);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('open_debts_empty_state')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openDebtsSummaryProvider.overrideWith(
            (ref) => Future<OpenDebtsSummary>.error(
              Exception('failed'),
              StackTrace.current,
            ),
          ),
          openInvoicesProvider.overrideWith((ref) async => <BillingInvoice>[]),
        ],
        child: const _BillingHarness(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('open_debts_error_state')),
      findsOneWidget,
    );
  });

  testWidgets('summary data renders export CTA and aging buckets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openDebtsSummaryProvider.overrideWith((ref) async => nonEmptySummary),
          openInvoicesProvider.overrideWith((ref) async => <BillingInvoice>[]),
        ],
        child: const _BillingHarness(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('open_debts_export_btn')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('open_debts_aging_buckets')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('open_debts_bucket_0_30')),
      findsOneWidget,
    );
  });

  testWidgets('invoices show download CTA keys', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openDebtsSummaryProvider.overrideWith((ref) async => nonEmptySummary),
          openInvoicesProvider.overrideWith((ref) async => sampleInvoices),
        ],
        child: const _BillingHarness(),
      ),
    );

    await tester.pumpAndSettle();

    for (final BillingInvoice invoice in sampleInvoices) {
      expect(
        find.byKey(ValueKey('open_debts_invoice_${invoice.id}')),
        findsOneWidget,
      );
    }
  });
}

class _BillingHarness extends StatelessWidget {
  const _BillingHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en'), Locale('he')],
      locale: const Locale('he'),
      localizationsDelegates: const [
        _FakeMarketplaceLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const OpenDebtsPage(),
    );
  }
}

class _FakeMarketplaceLocalizations extends MarketplaceLocalizations {
  _FakeMarketplaceLocalizations(super.locale);

  @override
  Future<void> load() async {}

  @override
  String translate(String key) => key;
}

class _FakeMarketplaceLocalizationsDelegate
    extends LocalizationsDelegate<MarketplaceLocalizations> {
  const _FakeMarketplaceLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MarketplaceLocalizations> load(Locale locale) async {
    final localization = _FakeMarketplaceLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MarketplaceLocalizations> old,
  ) =>
      false;
}
