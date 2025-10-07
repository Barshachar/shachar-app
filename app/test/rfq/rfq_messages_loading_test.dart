import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('he_IL');
  });

  setUp(() {
    Intl.defaultLocale = 'he_IL';
  });

  testWidgets('customer thread supports empty state and loading indicator',
      (WidgetTester tester) async {
    const String rfqId = 'RFQ-THREAD-EMPTY';
    final List<RfqMessage> messages = <RfqMessage>[];

    final ProviderContainer container = ProviderContainer(
      overrides: [
        rfqDetailProvider
            .overrideWith((ref, id) async => _detail(rfqId, messages)),
        rfqSendMessageActionProvider.overrideWithValue(
          ({required String rfqId, required String text}) async {
            await Future<void>.delayed(const Duration(milliseconds: 150));
            messages.add(
              _message(
                rfqId,
                'msg-${messages.length + 1}',
                text,
                authorRole: 'buyer',
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _buildApp(CustomerRfqDetailPage(rfqId: rfqId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('rfq_messages_list')), findsOneWidget);
    expect(find.byWidgetPredicate((Widget widget) {
      return widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>)
              .value
              .startsWith('rfq_message_item_');
    }), findsNothing);

    final Finder inputFinder = find.byKey(const ValueKey('rfq_message_input'));
    expect(inputFinder, findsOneWidget);
    await tester.ensureVisible(inputFinder);
    await tester.enterText(
      inputFinder,
      'תודה',
    );
    final Finder sendButton =
        find.byKey(const ValueKey('rfq_message_send_btn'));
    await tester.ensureVisible(sendButton);
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.byKey(const ValueKey('rfq_message_sending')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('rfq_message_item_msg-${messages.length}')),
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
    createdAt: DateTime(2024, 5, 1, 10, 0),
    needBy: null,
    reference: 'RFQ-$rfqId',
    terms: const <String, dynamic>{},
    metadata: const <String, dynamic>{},
    items: <RfqItem>[
      RfqItem(
        id: 'item-1',
        rfqId: rfqId,
        qty: 5,
        description: 'רכיב בדיקה',
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
    createdAt: DateTime(2024, 5, 1, 11, id.hashCode % 24),
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
