import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_action_keys.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_actions_widgets.dart';

void main() {
  testWidgets('AdminImportActionButton shows processed rows',
      (WidgetTester tester) async {
    final List<String> capturedMessages = <String>[];
    String? capturedSuccess;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminImportActionButton(
            callImport: () async => 5,
            onMessage: capturedMessages.add,
            onSuccess: (String message) => capturedSuccess = message,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(adminImportPickButtonKey));
    await tester.pump();
    await tester.tap(find.byKey(adminImportUploadButtonKey));
    await tester.pumpAndSettle();

    final finder = find.byKey(adminImportResultKey);
    expect(finder, findsOneWidget);
    final Text resultWidget = tester.widget<Text>(finder);
    expect(resultWidget.data, 'Rows processed: 5');
    expect(capturedMessages, <String>['CSV selected', 'Rows processed: 5']);
    expect(capturedSuccess, 'Rows processed: 5');
  });
}
