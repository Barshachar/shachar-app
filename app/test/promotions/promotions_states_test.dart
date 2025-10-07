import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/promotions/presentation/promotions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows loading spinner while promotions load', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promotionsProvider.overrideWithValue(
            const AsyncValue<List<PromotionUiModel>>.loading(),
          ),
        ],
        child: const _PromotionsHarness(),
      ),
    );

    await tester.pump();

    expect(
      find.byKey(const ValueKey('promotions_loading_spinner')),
      findsOneWidget,
    );
  });

  testWidgets('shows empty placeholder when there are no promotions',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promotionsProvider.overrideWithValue(
            const AsyncValue<List<PromotionUiModel>>.data(<PromotionUiModel>[]),
          ),
        ],
        child: const _PromotionsHarness(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('promotions_empty_state')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('promotions_list_root')),
      findsOneWidget,
    );
  });

  testWidgets('shows error placeholder when loading promotions fails',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promotionsProvider.overrideWith(
            (ref) => Future<List<PromotionUiModel>>.error(
              Exception('boom'),
              StackTrace.current,
            ),
          ),
        ],
        child: const _PromotionsHarness(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('promotions_error_state')),
      findsOneWidget,
    );
  });
}

class _PromotionsHarness extends StatelessWidget {
  const _PromotionsHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en'), Locale('he')],
      locale: const Locale('en'),
      localizationsDelegates: const [
        _FakeMarketplaceLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => const PromotionsPage(),
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
