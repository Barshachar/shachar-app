import 'package:flutter_test/flutter_test.dart';

import 'package:ashachar_marketplace/src/features/admin/presentation/admin_ui_actions.dart';

void main() {
  group('AdminUiActions.splitOrderUI', () {
    test('returns vendor message', () async {
      String? lastMessage;
      final result = await splitOrderUI(
        orderId: 'order-1',
        callSplit: () async => 'Vendors queued: 2',
        showMessage: (message) => lastMessage = message,
      );
      expect(result, 'Vendors queued: 2');
      expect(lastMessage, 'Vendors queued: 2');
    });

    test('propagates failure message', () async {
      String? lastMessage;
      final result = await splitOrderUI(
        orderId: 'order-2',
        callSplit: () async => throw Exception('failure'),
        showMessage: (message) => lastMessage = message,
      );
      expect(result, contains('failure'));
      expect(lastMessage, contains('failure'));
    });
  });

  group('AdminUiActions.generateReportUI', () {
    test('returns report URL', () async {
      String? lastMessage;
      final result = await generateReportUI(
        callReport: () async =>
            (url: 'https://example.com/report.csv', filename: 'report.csv'),
        showMessage: (message) => lastMessage = message,
      );
      expect(result, 'https://example.com/report.csv');
      expect(lastMessage, contains('report.csv'));
    });

    test('handles failure', () async {
      String? lastMessage;
      final result = await generateReportUI(
        callReport: () async => throw Exception('no link'),
        showMessage: (message) => lastMessage = message,
      );
      expect(result, isEmpty);
      expect(lastMessage, contains('no link'));
    });
  });

  group('AdminUiActions.importPricesUI', () {
    test('returns success message', () async {
      String? lastMessage;
      final result = await importPricesUI(
        callImport: () async => 5,
        showMessage: (message) => lastMessage = message,
      );
      expect(result, 'Rows processed: 5');
      expect(lastMessage, 'Rows processed: 5');
    });

    test('handles failure message', () async {
      String? lastMessage;
      final result = await importPricesUI(
        callImport: () async => throw Exception('bad csv'),
        showMessage: (message) => lastMessage = message,
      );
      expect(result, contains('bad csv'));
      expect(lastMessage, contains('bad csv'));
    });
  });
}
