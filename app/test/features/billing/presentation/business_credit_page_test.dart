import 'package:ashachar_marketplace/src/features/billing/presentation/business_credit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders credit overview and payment sections', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: BusinessCreditPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Business Credit'), findsWidgets);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('Payment Terms & Options'), findsOneWidget);
    expect(find.text('Add payment method'), findsWidgets);
    expect(find.text('Save'), findsOneWidget);
  });
}
