import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AButton.primary renders as ElevatedButton', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AButton.primary(
              label: 'CTA',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final Finder elevatedFinder = find.byType(ElevatedButton);
    expect(elevatedFinder, findsOneWidget);

    final ElevatedButton elevatedButton =
        tester.widget<ElevatedButton>(elevatedFinder);
    expect(elevatedButton.onPressed, isNotNull);
    expect(find.text('CTA'), findsOneWidget);
  });
}
