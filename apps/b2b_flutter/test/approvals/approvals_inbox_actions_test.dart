import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_page.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('en');
  });

  const String stepId = 'STEP-1';
  final ApprovalRequest pendingRequest = ApprovalRequest(
    stepId: stepId,
    orderId: 'ORDER-1',
    orderNumber: '10001',
    total: 120.0,
    currency: '₪',
    requestedAt: DateTime.now(),
    requestedBy: 'QA Buyer',
    buyerName: 'QA Org',
    note: 'Need approval',
  );

  testWidgets('approvals inbox triggers approve action and updates list',
      (WidgetTester tester) async {
    final ValueNotifier<List<ApprovalRequest>> inboxNotifier =
        ValueNotifier<List<ApprovalRequest>>(<ApprovalRequest>[pendingRequest]);
    addTearDown(inboxNotifier.dispose);

    bool approveCalled = false;

    final Widget app = ProviderScope(
      overrides: [
        approvalsInboxProvider.overrideWith((ref) async {
          return inboxNotifier.value;
        }),
        approvalsDecisionSenderProvider.overrideWith((ref) {
          return ({
            required String stepId,
            required String orderId,
            required String decision,
            String? note,
          }) async {
            approveCalled = decision == 'approve';
            inboxNotifier.value = const <ApprovalRequest>[];
            ref.invalidate(approvalsInboxProvider);
          };
        }),
      ],
      child: const MaterialApp(
        home: ApprovalsInboxPage(),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final Finder approveFinder =
        find.byKey(const ValueKey('approvals_approve_btn_STEP-1'));
    expect(approveFinder, findsOneWidget);

    await tester.tap(approveFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(approveCalled, isTrue);
    expect(
      find.byKey(const ValueKey('approvals_approve_btn_STEP-1')),
      findsNothing,
    );
  });
}
