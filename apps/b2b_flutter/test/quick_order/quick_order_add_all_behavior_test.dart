import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'quick_order_test_utils.dart';

void main() {
  testWidgets('Add all summary ignores forbidden rows',
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

    final AQtyStepper stepper = tester.widget(
      find.descendant(
        of: reviewTable,
        matching: find.byKey(
          const ValueKey('qo_bulk_qty_stepper_VAR-1'),
        ),
      ),
    );
    expect(stepper.enabled, isFalse);

    final AButton addAllBtn = tester.widget(
      find.byKey(const ValueKey('qo_add_all_btn')),
    );
    expect(addAllBtn.onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('qo_add_all_btn')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('qo_add_all_result_snackbar')),
      findsOneWidget,
    );
  });

  testWidgets('Add all disabled when all rows are forbidden',
      (WidgetTester tester) async {
    final ProductSearchResult forbiddenOne = buildQuickOrderResult('VAR-1');
    final ProductSearchResult forbiddenTwo = buildQuickOrderResult('VAR-2');
    final List<dynamic> rows = <dynamic>[
      quickOrderCreateBulkReviewRow(
        code: 'VAR-1',
        match: forbiddenOne,
        requestedQuantity: 1,
        quantity: 1,
        suggestions: <ProductSearchResult>[forbiddenOne],
      ),
      quickOrderCreateBulkReviewRow(
        code: 'VAR-2',
        match: forbiddenTwo,
        requestedQuantity: 1,
        quantity: 1,
        suggestions: <ProductSearchResult>[forbiddenTwo],
      ),
    ];

    await pumpQuickOrderWithRows(
      tester,
      allowedCatalog: <String>{},
      rows: rows,
      results: <ProductSearchResult>[forbiddenOne, forbiddenTwo],
    );

    final AButton addAllBtn = tester.widget(
      find.byKey(const ValueKey('qo_add_all_btn')),
    );
    expect(addAllBtn.onPressed, isNull);
  });
}
