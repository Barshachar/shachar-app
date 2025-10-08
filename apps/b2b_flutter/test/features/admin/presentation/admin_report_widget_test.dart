import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashachar_marketplace/src/features/admin/presentation/admin_ui_actions.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_action_keys.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_actions_widgets.dart';

void main() {
  testWidgets('AdminReportActionButton surfaces signed URL',
      (WidgetTester tester) async {
    String? capturedMessage;
    ReportRecord? capturedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminReportActionButton(
            callReport: () async =>
                (url: 'https://example.com/report.csv', filename: 'report.csv'),
            onMessage: (String value) => capturedMessage = value,
            onSuccess: (ReportRecord record) async {
              capturedRecord = record;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(adminReportButtonKey));
    await tester.pumpAndSettle();

    final finder = find.byKey(adminReportUrlKey);
    expect(finder, findsOneWidget);
    final SelectableText urlWidget = tester.widget<SelectableText>(finder);
    expect(urlWidget.data, 'https://example.com/report.csv');
    expect(capturedMessage, 'Report ready: report.csv');
    expect(capturedRecord?.filename, 'report.csv');
    expect(capturedRecord?.url, 'https://example.com/report.csv');
  });
}
