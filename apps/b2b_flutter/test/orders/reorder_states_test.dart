import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/reorder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialApp _buildApp() {
  return MaterialApp(
    locale: const Locale('he'),
    supportedLocales: const [Locale('en'), Locale('he')],
    localizationsDelegates: const [
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const ReorderPage(),
  );
}

Future<void> _pumpWith(
  WidgetTester tester,
  AsyncValue<List<ReorderLineItem>>? override,
) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: override == null
          ? const []
          : [reorderLinesProvider.overrideWithValue(override)],
      child: _buildApp(),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('reorder page renders loading, empty, error, and action states',
      (WidgetTester tester) async {
    await _pumpWith(tester, null);
    expect(
      find.byKey(const ValueKey('reorder_loading_spinner')),
      findsOneWidget,
    );

    await _pumpWith(tester, const AsyncValue.data(<ReorderLineItem>[]));
    expect(
      find.byKey(const ValueKey('reorder_empty_state')),
      findsOneWidget,
    );

    await _pumpWith(tester, const AsyncValue.error('boom', StackTrace.empty));
    expect(
      find.byKey(const ValueKey('reorder_error_state')),
      findsOneWidget,
    );

    const ReorderLineItem line1 = ReorderLineItem(
      id: 'line-1',
      name: 'Premium olive oil',
      sku: 'SKU-100',
      quantity: 4,
    );
    const ReorderLineItem line2 = ReorderLineItem(
      id: 'line-2',
      name: "Za'atar blend",
      sku: 'SKU-200',
      quantity: 2,
    );
    await _pumpWith(
      tester,
      const AsyncValue.data(<ReorderLineItem>[line1, line2]),
    );

    expect(find.byKey(const ValueKey('reorder_root')), findsOneWidget);

    final Finder stepperFinder =
        find.byKey(const ValueKey('reorder_qty_stepper_line-1'));
    final AQtyStepper stepper = tester.widget<AQtyStepper>(stepperFinder);
    expect(stepper.onChanged, isNotNull);
    expect(stepper.qty, equals(4));

    expect(find.text('סה"כ כמות: 6'), findsOneWidget);

    final Finder incrementButton = find.descendant(
      of: stepperFinder,
      matching: find.byIcon(Icons.add_circle_outline),
    );
    await tester.tap(incrementButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final AQtyStepper updatedStepper =
        tester.widget<AQtyStepper>(stepperFinder);
    expect(updatedStepper.qty, equals(5));
    expect(find.text('סה"כ כמות: 7'), findsOneWidget);

    final Finder addAllButtonFinder =
        find.byKey(const ValueKey('reorder_add_all_btn'));
    final FilledButton addAllButton =
        tester.widget<FilledButton>(addAllButtonFinder);
    expect(addAllButton.onPressed, isNotNull);

    await tester.tap(addAllButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('reorder_add_all_result_snackbar')),
      findsOneWidget,
    );
  });
}
