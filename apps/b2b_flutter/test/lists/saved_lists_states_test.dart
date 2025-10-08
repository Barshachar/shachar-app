import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/lists/presentation/saved_lists_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  MaterialApp buildApp(Widget home) {
    return MaterialApp(
      locale: const Locale('he'),
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

  Future<void> pumpWith(
    WidgetTester tester,
    AsyncValue<List<SavedListOverview>>? override,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: override == null
            ? const []
            : [savedListsControllerProvider.overrideWithValue(override)],
        child: buildApp(const SavedListsPage()),
      ),
    );
    await tester.pump();
  }

  testWidgets(
      'saved lists page renders loading, empty, error, and action states',
      (WidgetTester tester) async {
    await pumpWith(tester, null);
    expect(
      find.byKey(const ValueKey('saved_lists_loading_spinner')),
      findsOneWidget,
    );

    await pumpWith(tester, const AsyncValue.data(<SavedListOverview>[]));
    expect(
      find.byKey(const ValueKey('saved_lists_empty_state')),
      findsOneWidget,
    );

    await pumpWith(
      tester,
      const AsyncValue.error('boom', StackTrace.empty),
    );
    expect(
      find.byKey(const ValueKey('saved_lists_error_state')),
      findsOneWidget,
    );

    final SavedListOverview list = SavedListOverview(
      id: 'list-1',
      name: 'Weekly order',
      itemCount: 5,
      lastUpdated: DateTime(2025, 1, 10, 12, 0),
    );
    await pumpWith(tester, AsyncValue.data(<SavedListOverview>[list]));

    expect(
      find.byKey(const ValueKey('saved_list_root')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey('saved_list_card_list-1')),
      findsOneWidget,
    );

    final Finder buttonFinder =
        find.byKey(const ValueKey('saved_list_add_all_btn_list-1'));
    final FilledButton button = tester.widget<FilledButton>(buttonFinder);
    expect(button.onPressed, isNotNull);

    await tester.tap(buttonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    const String expectedMessage =
        'הוספנו את כל 5 הפריטים מהרשימה "Weekly order"';
    expect(
      find.byKey(const ValueKey('saved_list_add_all_result_snackbar')),
      findsOneWidget,
    );
    expect(find.text(expectedMessage), findsOneWidget);
  });
}
