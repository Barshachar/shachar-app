import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/support/data/supabase_support_ai_repository.dart';
import 'package:ashachar_marketplace/src/features/support/domain/support_ai_models.dart';
import 'package:ashachar_marketplace/src/features/support/domain/support_ai_repository.dart';
import 'package:ashachar_marketplace/src/features/support/presentation/support_ai_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_harness.dart';

void main() {
  testWidgets('AI chat sends message and shows reply', (tester) async {
    final SupportAiRepository repository = _FakeSupportAiRepository();

    await tester.pumpWidget(
      makeTestApp(
        const SupportAiChatPage(),
        overrides: [
          supportAiRepositoryProvider.overrideWithValue(repository),
        ],
        extraDelegates: const [_FakeMarketplaceLocalizationsDelegate()],
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('support_ai_input')),
      'Track my order',
    );
    await tester.tap(find.byKey(const ValueKey('support_ai_send')));
    await tester.pumpAndSettle();

    expect(find.text('Here is your help'), findsOneWidget);
  });
}

class _FakeSupportAiRepository implements SupportAiRepository {
  @override
  Future<SupportAiReply> sendMessage({
    required String message,
    List<SupportAiMessage> history = const <SupportAiMessage>[],
  }) async {
    return const SupportAiReply(
      reply: 'Here is your help',
      suggestions: <String>['Track order'],
    );
  }
}

class _FakeMarketplaceLocalizations extends MarketplaceLocalizations {
  _FakeMarketplaceLocalizations(super.locale);

  @override
  Future<void> load() async {}

  @override
  String translate(String key) => key;
}

class _FakeMarketplaceLocalizationsDelegate
    extends LocalizationsDelegate<MarketplaceLocalizations> {
  const _FakeMarketplaceLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MarketplaceLocalizations> load(Locale locale) async {
    final localization = _FakeMarketplaceLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MarketplaceLocalizations> old,
  ) =>
      false;
}
