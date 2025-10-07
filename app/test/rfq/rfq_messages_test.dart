import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
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

  testWidgets('customer message thread renders and allows sending new message',
      (WidgetTester tester) async {
    await tester.setDevicePixelRatio(1.0);
    await tester.setSurfaceSize(const Size(1200, 2200));
    const String rfqId = 'RFQ-THREAD-1';
    final List<RfqMessage> messages = <RfqMessage>[
      _message(rfqId, 'msg-1', 'לקוח: האם יש מלאי?'),
      _message(rfqId, 'msg-2', 'ספק: יש משלוח בעוד שבוע', authorRole: 'vendor'),
    ];

    await tester.pumpWidget(
      _buildApp(
        ProviderScope(
          overrides: [
            rfqDetailProvider.overrideWith((ref, id) async {
              if (id != rfqId) {
                throw StateError('unexpected rfqId: $id');
              }
              return _detail(rfqId, messages);
            }),
            rfqSendMessageActionProvider.overrideWithValue(
              ({required String rfqId, required String text}) async {
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
          child: _CustomerMessageHarness(rfqId: rfqId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder messageListFinder =
        find.byKey(const ValueKey('rfq_messages_list'));
    await _ensureVisible(tester, messageListFinder);
    expect(messageListFinder, findsOneWidget);
    await _ensureVisible(
        tester, find.byKey(const ValueKey('rfq_message_item_msg-1')));
    await _ensureVisible(
        tester, find.byKey(const ValueKey('rfq_message_item_msg-2')));

    const String newText = 'נשמח לעדכון משלוח';
    final Finder inputFinder = find.byKey(const ValueKey('rfq_message_input'));
    await _ensureVisible(tester, inputFinder);
    expect(inputFinder, findsOneWidget);
    await tester.enterText(inputFinder, newText);

    final Finder sendButton =
        find.byKey(const ValueKey('rfq_message_send_btn'));
    await _ensureVisible(tester, sendButton);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('rfq_message_item_msg-${messages.length}')),
      findsOneWidget,
    );
    final TextField input = tester
        .widget<TextField>(find.byKey(const ValueKey('rfq_message_input')));
    expect(input.controller?.text, isEmpty);
  });

  testWidgets('customer message send failure shows error indicator',
      (WidgetTester tester) async {
    await tester.setDevicePixelRatio(1.0);
    await tester.setSurfaceSize(const Size(1200, 2200));
    const String rfqId = 'RFQ-THREAD-ERR';
    final List<RfqMessage> messages = <RfqMessage>[
      _message(rfqId, 'msg-1', 'פתחנו את הבקשה'),
    ];

    await tester.pumpWidget(
      _buildApp(
        ProviderScope(
          overrides: [
            rfqDetailProvider.overrideWith((ref, id) async {
              return _detail(rfqId, messages);
            }),
            rfqSendMessageActionProvider.overrideWithValue(
              ({required String rfqId, required String text}) async {
                throw Exception('send failed');
              },
            ),
          ],
          child: _CustomerMessageHarness(rfqId: rfqId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    debugDumpApp();

    final Finder inputFinder = find.byKey(const ValueKey('rfq_message_input'));
    await _ensureVisible(tester, inputFinder);
    expect(inputFinder, findsOneWidget);
    await tester.enterText(inputFinder, 'ניסיון שליחה');

    final Finder sendButton =
        find.byKey(const ValueKey('rfq_message_send_btn'));
    await _ensureVisible(tester, sendButton);
    await tester.tap(sendButton);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('rfq_message_send_error')), findsOneWidget);
  });
}

class _CustomerMessageHarness extends ConsumerWidget {
  const _CustomerMessageHarness({required this.rfqId});

  final String rfqId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RfqDetail> detail = ref.watch(rfqDetailProvider(rfqId));
    return detail.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, _) => Scaffold(
        body: Center(child: Text('error: $error')),
      ),
      data: (RfqDetail value) => _CustomerMessageBody(detail: value),
    );
  }
}

class _CustomerMessageBody extends ConsumerStatefulWidget {
  const _CustomerMessageBody({required this.detail});

  final RfqDetail detail;

  @override
  ConsumerState<_CustomerMessageBody> createState() =>
      _CustomerMessageBodyState();
}

class _CustomerMessageBodyState extends ConsumerState<_CustomerMessageBody> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void didUpdateWidget(covariant _CustomerMessageBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.detail.messages, widget.detail.messages) &&
        !_sending) {
      // ensure latest state reflects new detail payload
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<RfqMessage> messages = widget.detail.messages;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeyedSubtree(
                    key: const ValueKey('rfq_messages_list'),
                    child: messages.isEmpty
                        ? const Text('טרם נשלחו הודעות')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final RfqMessage message in messages)
                                KeyedSubtree(
                                  key: ValueKey(
                                      'rfq_message_item_${message.id}'),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _authorLabel(message.authorRole),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(message.body),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat.yMMMMd('he_IL')
                                              .add_Hm()
                                              .format(
                                                  message.createdAt.toLocal()),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  const Divider(),
                  TextField(
                    key: const ValueKey('rfq_message_input'),
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'שאלה או עדכון חדש',
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      key: const ValueKey('rfq_message_send_btn'),
                      onPressed: _sending ? null : _sendMessage,
                      icon: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                key: ValueKey('rfq_message_sending'),
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_outlined),
                      label: const Text('שליחה לספק'),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      key: const ValueKey('rfq_message_send_error'),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _error = 'נא להזין הודעה';
      });
      return;
    }
    setState(() {
      _error = null;
      _sending = true;
    });
    final RfqSendMessageAction action = ref.read(rfqSendMessageActionProvider);
    try {
      await action(rfqId: widget.detail.id, text: text);
      _controller.clear();
      ref.invalidate(rfqDetailProvider(widget.detail.id));
    } on Object catch (error) {
      setState(() {
        _error = 'שליחת ההודעה נכשלה: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }
}

String _authorLabel(String? role) {
  switch (role) {
    case 'vendor':
      return 'מענה ספק';
    case 'admin':
      return 'מערכת';
    default:
      return 'הודעת לקוח';
  }
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
    supportedLocales: const [Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Builder(builder: (BuildContext context) => home),
  );
}

Future<void> _ensureVisible(WidgetTester tester, Finder target) async {
  Finder scrollableFinder = find.byType(ListView);
  if (scrollableFinder.evaluate().isEmpty) {
    scrollableFinder = find.byType(Scrollable);
  }
  if (scrollableFinder.evaluate().isEmpty) {
    return;
  }
  final Finder scrollable = scrollableFinder.first;
  for (int i = 0; i < 6 && target.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();
  }
}
