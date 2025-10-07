import 'package:ashachar_marketplace/src/features/support/presentation/support_tickets_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows support queues with tickets', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SupportTicketsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('#2034 Login Issue'), findsOneWidget);
    expect(find.text('New Ticket'), findsOneWidget);
  });
}
