import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MarketplaceLocalizations {
  MarketplaceLocalizations(this.locale);

  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  Future<void> load() async {
    final jsonString = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.arb');
    _localizedStrings = jsonDecode(jsonString) as Map<String, dynamic>;
  }

  String translate(String key) => _localizedStrings[key] as String? ?? key;

  static const LocalizationsDelegate<MarketplaceLocalizations> delegate =
      _MarketplaceLocalizationsDelegate();
}

class _MarketplaceLocalizationsDelegate
    extends LocalizationsDelegate<MarketplaceLocalizations> {
  const _MarketplaceLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'he'].contains(locale.languageCode);

  @override
  Future<MarketplaceLocalizations> load(Locale locale) async {
    final localizations = MarketplaceLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MarketplaceLocalizations> old,
  ) =>
      false;
}
