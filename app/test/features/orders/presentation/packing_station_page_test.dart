import 'package:ashachar_marketplace/src/features/orders/presentation/packing_station_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays packing lines and actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PackingStationPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Order #012345'), findsOneWidget);
    expect(find.text('Print Packing Slip'), findsOneWidget);
    expect(find.text('Mark as Packed'), findsOneWidget);
    expect(find.textContaining('Paint Brush'), findsOneWidget);
  });
}
