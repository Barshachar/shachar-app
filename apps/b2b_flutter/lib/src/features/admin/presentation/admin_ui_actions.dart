import 'dart:async';

typedef ReportRecord = ({String url, String filename});

Future<String> splitOrderUI({
  required String orderId,
  required Future<String> Function() callSplit,
  required void Function(String) showMessage,
}) async {
  try {
    final res = await callSplit(); // e.g., "Vendors queued: 2"
    showMessage(res);
    return res;
  } catch (e) {
    final msg = 'Split failed: $e';
    showMessage(msg);
    return msg;
  }
}

Future<String> generateReportUI({
  required Future<ReportRecord> Function() callReport,
  required void Function(String) showMessage,
}) async {
  try {
    final r = await callReport();
    final msg = 'Report ready: ${r.filename}';
    showMessage(msg);
    return r.url;
  } catch (e) {
    final msg = 'Report failed: $e';
    showMessage(msg);
    return '';
  }
}

Future<String> importPricesUI({
  required Future<int> Function() callImport,
  required void Function(String) showMessage,
}) async {
  try {
    final count = await callImport();
    final msg = 'Rows processed: $count';
    showMessage(msg);
    return msg;
  } catch (e) {
    final msg = 'Import failed: $e';
    showMessage(msg);
    return msg;
  }
}
