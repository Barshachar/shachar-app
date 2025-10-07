import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/vendor_rfq_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../test_utils/tester_view_compat.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('he_IL');
  });

  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  testWidgets('vendor reject surfaces success and error feedback',
      (WidgetTester tester) async {
    Future<void> pumpScenario(
      String rfqId,
      VendorQuoteRejectAction action,
      void Function() verify,
    ) async {
      await tester.setDevicePixelRatio(1.0);
      await tester.setSurfaceSize(const Size(1200, 2400));
      final RfqDetail detail = _buildDetail(rfqId);
      final ProviderContainer container = ProviderContainer(
        overrides: [
          rfqDetailProvider.overrideWith((ref, id) async {
            if (id != rfqId) {
              throw StateError('unexpected rfqId: $id');
            }
            return detail;
          }),
          vendorQuoteRejectActionProvider.overrideWithValue(action),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _buildApp(VendorQuotePage(rfqId: rfqId)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('vendor_quote_reject_btn')));
      await tester.pump();
      await tester.pumpAndSettle();

      verify();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      container.dispose();
    }

    String? capturedId;
    await pumpScenario(
      'RFQ-REJECT-1',
      ({required String rfqId}) async {
        capturedId = rfqId;
      },
      () {
        expect(capturedId, 'RFQ-REJECT-1');
        expect(find.byKey(const ValueKey('vendor_quote_rejected_state')),
            findsOneWidget);
      },
    );

    await pumpScenario(
      'RFQ-REJECT-ERR',
      ({required String rfqId}) async {
        throw StateError('reject failed');
      },
      () {
        expect(find.byKey(const ValueKey('vendor_quote_action_error')),
            findsOneWidget);
      },
    );
  });
}

RfqDetail _buildDetail(String rfqId) {
  return RfqDetail(
    id: rfqId,
    status: 'open',
    createdAt: DateTime(2024, 5, 1, 10, 0),
    needBy: null,
    reference: 'RFQ-$rfqId',
    terms: const {},
    metadata: const {},
    items: [
      RfqItem(
        id: 'item-1',
        rfqId: rfqId,
        qty: 10,
        description: 'מסך תעשייתי',
      ),
    ],
    quotes: const <RfqQuote>[],
    messages: const <RfqMessage>[],
  );
}

MaterialApp _buildApp(Widget home) {
  return MaterialApp(
    supportedLocales: const [Locale('en'), Locale('he')],
    localizationsDelegates: const [
      MarketplaceLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}
