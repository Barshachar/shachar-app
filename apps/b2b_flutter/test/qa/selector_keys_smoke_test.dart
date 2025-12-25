import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/open_debts_page.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/lists/presentation/saved_lists_page.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/reorder_page.dart';
import 'package:ashachar_marketplace/src/features/promotions/presentation/promotions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../quick_order/quick_order_test_utils.dart'
    show FakeCatalogRepository, FakeOrdersRepository;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildApp(Widget home) {
    return MaterialApp(
      supportedLocales: const [Locale('en'), Locale('he')],
      locale: const Locale('he'),
      localizationsDelegates: const [
        MarketplaceLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }

  Future<void> pumpAndExpectNoErrors(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(widget);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
  }

  testWidgets('critical selectors stay stable', (WidgetTester tester) async {
    final SavedListOverview savedList = SavedListOverview(
      id: 'list-1',
      name: 'Weekly order',
      itemCount: 3,
      lastUpdated: DateTime(2025, 1, 12, 8, 30),
    );

    await pumpAndExpectNoErrors(
      tester,
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          savedListsControllerProvider.overrideWithValue(
            AsyncValue.data(<SavedListOverview>[savedList]),
          ),
        ],
        child: buildApp(const SavedListsPage()),
      ),
    );

    expect(find.byKey(const ValueKey('saved_list_root')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('saved_list_add_all_btn')), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey('saved_list_add_all_btn_list-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('saved_list_add_all_result_snackbar')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    const ReorderLineItem line = ReorderLineItem(
      id: 'line-1',
      name: 'Bulk tahini',
      sku: 'SKU-500',
      quantity: 4,
    );

    await pumpAndExpectNoErrors(
      tester,
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          reorderLinesProvider.overrideWithValue(
            const AsyncValue.data(<ReorderLineItem>[line]),
          ),
        ],
        child: buildApp(const ReorderPage()),
      ),
    );

    expect(find.byKey(const ValueKey('reorder_root')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('reorder_add_all_btn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('reorder_add_all_result_snackbar')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    const PromotionUiModel promotion = PromotionUiModel(
      id: 'promo-1',
      title: 'חבילת ארוחת בוקר',
      badgeLabel: 'חדש',
      validUntilText: '30.11.2025',
      termsText: 'בתוקף להזמנות מעל ₪500',
      tags: <String>['Bulk', 'Seasonal'],
    );

    await pumpAndExpectNoErrors(
      tester,
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          promotionsProvider.overrideWith(
            (ref) async => <PromotionUiModel>[promotion],
          ),
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
          ordersRepositoryProvider.overrideWithValue(FakeOrdersRepository()),
        ],
        child: buildApp(const PromotionsPage()),
      ),
    );

    expect(find.byKey(const ValueKey('promotions_list_root')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    const OpenDebtsSummary summary = OpenDebtsSummary(
      totalDue: 6400,
      buckets: <OpenDebtBucket>[
        OpenDebtBucket(keySuffix: '0_30', label: '0-30', amount: 2400),
        OpenDebtBucket(keySuffix: '31_60', label: '31-60', amount: 2000),
        OpenDebtBucket(keySuffix: '61_90', label: '61-90', amount: 1600),
        OpenDebtBucket(keySuffix: '90_plus', label: '90+', amount: 400),
      ],
    );

    final BillingInvoice invoice = BillingInvoice(
      id: 'inv_a',
      number: 'INV-A',
      dueDate: DateTime(2025, 2, 10),
      amount: 2400,
    );

    await pumpAndExpectNoErrors(
      tester,
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          openDebtsSummaryProvider.overrideWith((ref) async => summary),
          openInvoicesProvider
              .overrideWith((ref) async => <BillingInvoice>[invoice]),
        ],
        child: buildApp(const OpenDebtsPage()),
      ),
    );

    expect(find.byKey(const ValueKey('open_debts_export_btn')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('open_debts_invoice_inv_a')), findsOneWidget);
  });
}
