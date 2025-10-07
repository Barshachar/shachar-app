import 'dart:async';

import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/open_debts_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('he');
  });

  testWidgets('invoices list surfaces loading, empty, and error states',
      (WidgetTester tester) async {
    final Completer<List<BillingInvoice>> pending =
        Completer<List<BillingInvoice>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openInvoicesProvider.overrideWith((ref) => pending.future),
        ],
        child: const _BillingHarness(),
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('invoices_loading_spinner')),
      findsOneWidget,
    );

    pending.complete(const <BillingInvoice>[]);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openInvoicesProvider
              .overrideWith((ref) async => const <BillingInvoice>[]),
        ],
        child: const _BillingHarness(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('invoices_empty_state')),
      findsOneWidget,
    );
    expect(find.byType(AStateMessage), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          openInvoicesProvider.overrideWith(
            (ref) => Future<List<BillingInvoice>>.error(
              Exception('failed to load invoices'),
              StackTrace.current,
            ),
          ),
        ],
        child: const _BillingHarness(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('invoices_error_state')),
      findsOneWidget,
    );
    expect(find.byType(AStateMessage), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
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
