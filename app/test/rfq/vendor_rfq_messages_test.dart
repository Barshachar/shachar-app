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

  testWidgets('vendor RFQ thread renders and allows sending new message',
      (WidgetTester tester) async {
    await tester.setDevicePixelRatio(1.0);
    await tester.setSurfaceSize(const Size(1200, 2200));
    const String rfqId = 'RFQ-VENDOR-1';
    final List<RfqMessage> messages = <RfqMessage>[
      _message(rfqId, 'msg-1', 'לקוח: נשמח להצעת מחיר', authorRole: 'buyer'),
      _message(rfqId, 'msg-2', 'ספק: מפרט התקבל', authorRole: 'vendor'),
    ];

    final ProviderContainer container = ProviderContainer(
      overrides: [
        rfqDetailProvider
            .overrideWith((ref, id) async => _detail(rfqId, messages)),
        vendorRfqSendMessageActionProvider.overrideWithValue(
          ({required String rfqId, required String text}) async {
            messages.add(
              _message(
                rfqId,
                'msg-${messages.length + 1}',
                text,
                authorRole: 'vendor',
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(VendorQuotePage(rfqId: rfqId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('vendor_rfq_messages_list')), findsOneWidget);
    expect(find.byKey(const ValueKey('vendor_rfq_message_item_msg-1')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('vendor_rfq_message_item_msg-2')),
        findsOneWidget);

    final Finder inputFinder =
        find.byKey(const ValueKey('vendor_rfq_message_input'));
    expect(inputFinder, findsOneWidget);
    await tester.ensureVisible(inputFinder);
    await tester.enterText(
      inputFinder,
      'נשלחה הצעת מחיר מעודכנת',
    );
    final Finder sendButton =
        find.byKey(const ValueKey('vendor_rfq_message_send_btn'));
    await tester.ensureVisible(sendButton);
    await tester.tap(sendButton);
    await tester.pump();

    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('vendor_rfq_message_item_msg-${messages.length}')),
      findsOneWidget,
    );
    final TextField input = tester.widget<TextField>(
      find.byKey(const ValueKey('vendor_rfq_message_input')),
    );
    expect(input.controller?.text, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
  });

  testWidgets('vendor RFQ send failure surfaces error indicator',
      (WidgetTester tester) async {
    await tester.setDevicePixelRatio(1.0);
    await tester.setSurfaceSize(const Size(1200, 2200));
    const String rfqId = 'RFQ-VENDOR-ERR';
    final List<RfqMessage> messages = <RfqMessage>[
      _message(rfqId, 'msg-1', 'יש צורך בפרטים נוספים', authorRole: 'buyer'),
    ];

    final ProviderContainer container = ProviderContainer(
      overrides: [
        rfqDetailProvider
            .overrideWith((ref, id) async => _detail(rfqId, messages)),
        vendorRfqSendMessageActionProvider.overrideWithValue(
          ({required String rfqId, required String text}) async {
            throw Exception('send failed');
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(VendorQuotePage(rfqId: rfqId)),
      ),
    );
    await tester.pumpAndSettle();

    final Finder inputFinder =
        find.byKey(const ValueKey('vendor_rfq_message_input'));
    expect(inputFinder, findsOneWidget);
    await tester.ensureVisible(inputFinder);
    await tester.enterText(
      inputFinder,
      'בדיקת שגיאה',
    );
    final Finder sendButton =
        find.byKey(const ValueKey('vendor_rfq_message_send_btn'));
    await tester.ensureVisible(sendButton);
    await tester.tap(sendButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('vendor_rfq_message_send_error')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    container.dispose();
  });
}

RfqDetail _detail(String rfqId, List<RfqMessage> messages) {
  return RfqDetail(
    id: rfqId,
    status: 'open',
    reference: 'RFQ-$rfqId',
    createdAt: DateTime(2024, 5, 1, 14, 0),
    needBy: null,
    terms: const <String, dynamic>{},
    metadata: const <String, dynamic>{},
    items: <RfqItem>[
      RfqItem(
        id: 'item-1',
        rfqId: rfqId,
        qty: 20,
        description: 'לוח בקרה',
      ),
    ],
    quotes: const <RfqQuote>[],
    messages: List<RfqMessage>.unmodifiable(messages),
  );
}

RfqMessage _message(
  String rfqId,
  String id,
  String body, {
  String? authorRole,
}) {
  return RfqMessage(
    id: id,
    rfqId: rfqId,
    body: body,
    authorRole: authorRole,
    createdAt: DateTime(2024, 5, 1, 15, id.hashCode % 24),
  );
}

MaterialApp _buildApp(Widget home) {
  return MaterialApp(
    supportedLocales: const [Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}
