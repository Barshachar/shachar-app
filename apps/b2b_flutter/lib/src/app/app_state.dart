import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

const String appLocalePreferenceKey = 'app_locale';
const String appThemeModePreferenceKey = 'app_theme_mode';

final localeProvider = StateProvider<Locale>((ref) => const Locale('he'));
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Locale localeFromPreference(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const Locale('he');
  }
  return Locale(value.trim());
}

String localeToPreference(Locale locale) => locale.languageCode;

ThemeMode themeModeFromPreference(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
  }
  return ThemeMode.system;
}

String themeModeToPreference(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}
