import 'dart:async';

import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_page.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('approvals inbox surfaces loading, empty, and error states',
      (WidgetTester tester) async {
    // Loading state: pending future keeps skeletons visible.
    final Completer<List<ApprovalRequest>> pending =
        Completer<List<ApprovalRequest>>();
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          approvalsInboxProvider.overrideWith((ref) => pending.future),
        ],
        child: const _ApprovalsInboxHarness(),
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('approvals_inbox_skeleton_list')),
      findsOneWidget,
    );

    // Empty state: resolved future with no approvals.
    pending.complete(const <ApprovalRequest>[]);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          approvalsInboxProvider.overrideWith(
            (ref) async => const <ApprovalRequest>[],
          ),
        ],
        child: const _ApprovalsInboxHarness(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('approvals_inbox_empty_state')),
      findsOneWidget,
    );
    expect(find.byType(AStateMessage), findsOneWidget);

    // Error state: provider throws.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          approvalsInboxProvider.overrideWithValue(
            AsyncError<List<ApprovalRequest>>(
              Exception('failed to load approvals'),
              StackTrace.current,
            ),
          ),
        ],
        child: const _ApprovalsInboxHarness(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('approvals_inbox_error_state')),
      findsOneWidget,
    );
    expect(find.byType(AStateMessage), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _ApprovalsInboxHarness extends StatelessWidget {
  const _ApprovalsInboxHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en'), Locale('he')],
      localizationsDelegates: const [
        MarketplaceLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ApprovalsInboxPage(),
    );
  }
}
