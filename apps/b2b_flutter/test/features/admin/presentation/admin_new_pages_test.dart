import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashachar_marketplace/src/features/admin/presentation/admin_contact_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_dock_scheduling_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_payables_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_export_scheduler_page.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_order_approval_page.dart';

void main() {
  testWidgets('admin contact page renders form fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminContactPage()));
    await tester.pumpAndSettle();

    expect(find.text('Get in touch'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Send message'), findsOneWidget);
  });

  testWidgets('dock scheduling page shows calendar and panel', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDockSchedulingPage()));
    await tester.pumpAndSettle();

    expect(find.text('Dock scheduling'), findsOneWidget);
    expect(find.text('Reserve slot'), findsOneWidget);
  });

  testWidgets('payables page shows invoice checklist', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminPayablesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Accounts payable run'), findsOneWidget);
    expect(find.text('Schedule payments'), findsOneWidget);
  });

  testWidgets('export scheduler page exposes toggles', (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: AdminExportSchedulerPage()));
    await tester.pumpAndSettle();

    expect(find.text('Data export'), findsOneWidget);
    expect(find.text('Include filters'), findsOneWidget);
  });

  testWidgets('order approval page highlights warnings', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminOrderApprovalPage()));
    await tester.pumpAndSettle();

    expect(find.text('Order approval'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });
}
