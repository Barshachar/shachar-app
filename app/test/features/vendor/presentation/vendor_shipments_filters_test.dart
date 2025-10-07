import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_shipments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggleStatus adds and removes statuses', () {
    final notifier = ShipmentsFiltersNotifier();
    expect(notifier.state.statuses, isEmpty);

    notifier.toggleStatus('pending');
    expect(notifier.state.statuses, contains('pending'));

    notifier.toggleStatus('ready');
    expect(notifier.state.statuses, containsAll(<String>{'pending', 'ready'}));

    notifier.toggleStatus('pending');
    expect(notifier.state.statuses, equals(<String>{'ready'}));
  });

  test('setQuery updates search text and reset clears it', () {
    final notifier = ShipmentsFiltersNotifier();
    notifier.setQuery('foo');
    expect(notifier.state.query, 'foo');

    notifier.reset();
    expect(notifier.state.query, isEmpty);
    expect(notifier.state.statuses, isEmpty);
    expect(notifier.state.dateRange, isNull);
  });

  test('setDateRange stores range', () {
    final notifier = ShipmentsFiltersNotifier();
    final DateTime now = DateTime.now();
    final range =
        DateTimeRange(start: now, end: now.add(const Duration(days: 1)));

    notifier.setDateRange(range);
    expect(notifier.state.dateRange, equals(range));

    notifier.setDateRange(null);
    expect(notifier.state.dateRange, isNull);
  });
}
