import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'quick_order_test_utils.dart';

void main() {
  testWidgets('Quick Order review rows respect catalog gating',
      (WidgetTester tester) async {
    final ProductSearchResult forbidden = buildQuickOrderResult('VAR-1');
    final ProductSearchResult allowed = buildQuickOrderResult('VAR-2');
    final List<dynamic> rows = <dynamic>[
      quickOrderCreateBulkReviewRow(
        code: 'VAR-1',
        match: forbidden,
        requestedQuantity: 1,
        quantity: 1,
        suggestions: <ProductSearchResult>[forbidden],
      ),
      quickOrderCreateBulkReviewRow(
        code: 'VAR-2',
        match: allowed,
        requestedQuantity: 1,
        quantity: 1,
        suggestions: <ProductSearchResult>[allowed],
      ),
    ];

    await pumpQuickOrderWithRows(
      tester,
      allowedCatalog: <String>{'VAR-2'},
      rows: rows,
      results: <ProductSearchResult>[forbidden, allowed],
    );

    final Finder reviewTable = findQuickOrderReviewTable();
    expect(
      find.descendant(
        of: reviewTable,
        matching: find.byKey(
          const ValueKey('qo_row_not_in_catalog_VAR-1'),
        ),
      ),
      findsOneWidget,
    );

    final AQtyStepper gatedStepper = tester.widget(
      find.descendant(
        of: reviewTable,
        matching: find.byKey(
          const ValueKey('qo_bulk_qty_stepper_VAR-1'),
        ),
      ),
    );
    expect(gatedStepper.enabled, isFalse);

    final AQtyStepper allowedStepper = tester.widget(
      find.descendant(
        of: reviewTable,
        matching: find.byKey(
          const ValueKey('qo_bulk_qty_stepper_VAR-2'),
        ),
      ),
    );
    expect(allowedStepper.enabled, isTrue);

    final AButton addAll = tester.widget(
      find.byKey(const ValueKey('qo_add_all_btn')),
    );
    expect(addAll.onPressed, isNotNull);
  });
}
