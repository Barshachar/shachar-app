import 'package:ashachar_marketplace/src/features/admin/presentation/admin_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows tax configuration controls', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AdminSettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tax Settings'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
    expect(find.text('VAT'), findsOneWidget);
    expect(find.text('Add Rule'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
