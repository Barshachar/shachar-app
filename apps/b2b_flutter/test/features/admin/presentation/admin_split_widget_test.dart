import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_action_keys.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_actions_widgets.dart';

void main() {
  testWidgets('AdminSplitActionButton shows result message',
      (WidgetTester tester) async {
    String? capturedMessage;
    String? capturedSuccess;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminSplitActionButton(
            orderId: 'order-1',
            callSplit: () async => 'Vendors queued: 2',
            onMessage: (String value) => capturedMessage = value,
            onSuccess: (String value) => capturedSuccess = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(adminSplitButtonKey));
    await tester.pumpAndSettle();

    final finder = find.byKey(adminSplitResultKey);
    expect(finder, findsOneWidget);
    final Text resultWidget = tester.widget<Text>(finder);
    expect(resultWidget.data, 'Vendors queued: 2');
    expect(capturedMessage, 'Vendors queued: 2');
    expect(capturedSuccess, 'Vendors queued: 2');
  });
}
