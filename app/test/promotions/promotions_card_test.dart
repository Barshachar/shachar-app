import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/promotions/presentation/promotions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders promotions list and triggers CTA', (tester) async {
    bool firstTapped = false;
    bool secondTapped = false;

    final List<PromotionUiModel> promotions = <PromotionUiModel>[
      PromotionUiModel(
        id: 'promo-1',
        title: '1+1 on gourmet spices',
        badgeLabel: '1+1',
        validUntilText: '31/12/2024',
        termsText: 'Valid on SKUs 100-120',
        tags: const <String>['Gourmet', 'Spices'],
        onViewProducts: () {
          firstTapped = true;
        },
      ),
      PromotionUiModel(
        id: 'promo-2',
        title: 'Coupon for organic teas',
        badgeLabel: 'Coupon',
        validUntilText: '15/11/2024',
        termsText: 'Apply at checkout',
        tags: const <String>['Organic', 'Tea'],
        onViewProducts: () {
          secondTapped = true;
        },
      ),
    ];

    await tester.binding.setSurfaceSize(const Size(640, 1024));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          promotionsProvider.overrideWith((ref) async => promotions),
        ],
        child: const _PromotionsHarness(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('promotion_card_promo-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('promotion_card_promo-2')),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey('promotion_card_badge_promo-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('promotion_card_badge_promo-2')),
      findsOneWidget,
    );

    final Finder viewButton =
        find.byKey(const ValueKey('promotion_card_cta_promo-1'));
    expect(viewButton, findsOneWidget);

    await tester.tap(viewButton);
    await tester.pump();

    expect(firstTapped, isTrue);
    expect(secondTapped, isFalse);
  });
}

class _PromotionsHarness extends StatelessWidget {
  const _PromotionsHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('en'), Locale('he')],
      locale: const Locale('he'),
      localizationsDelegates: const [
        _FakeMarketplaceLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const PromotionsPage(),
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
