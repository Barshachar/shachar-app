import 'package:ashachar_marketplace/src/features/admin/presentation/admin_audit_log_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders filter form and entries', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AdminAuditLogPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Audit Log'), findsOneWidget);
    expect(find.text('Apply filters'), findsOneWidget);
    expect(find.textContaining('Lucas Nguyen'), findsOneWidget);
    expect(find.textContaining('Rolling Scaffold'), findsOneWidget);
  });
}
