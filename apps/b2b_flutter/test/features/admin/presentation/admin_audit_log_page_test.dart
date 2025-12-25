import 'package:ashachar_marketplace/src/features/admin/data/audit_log_providers.dart';
import 'package:ashachar_marketplace/src/features/admin/data/fake_audit_log_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_audit_log_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders filter form and entries', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          auditLogRepositoryProvider
              .overrideWithValue(const FakeAuditLogRepository()),
        ],
        child: const MaterialApp(home: AdminAuditLogPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Audit Log'), findsOneWidget);
    expect(find.text('Apply filters'), findsOneWidget);
    expect(find.textContaining('Lucas Nguyen'), findsOneWidget);
    expect(find.textContaining('Rolling Scaffold'), findsOneWidget);
  });
}
