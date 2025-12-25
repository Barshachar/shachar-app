import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ashachar_marketplace/src/app/app_state.dart';
import 'package:ashachar_marketplace/src/core/onboarding/onboarding_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('app_state', () {
    test('localeFromPreference defaults to he', () {
      final Locale locale = localeFromPreference(null);
      expect(locale.languageCode, 'he');
    });

    test('localeFromPreference trims input', () {
      final Locale locale = localeFromPreference('  en ');
      expect(locale.languageCode, 'en');
    });

    test('themeModeFromPreference maps values', () {
      expect(themeModeFromPreference('light'), ThemeMode.light);
      expect(themeModeFromPreference('dark'), ThemeMode.dark);
      expect(themeModeFromPreference('system'), ThemeMode.system);
      expect(themeModeFromPreference('unknown'), ThemeMode.system);
    });

    test('themeModeToPreference serializes values', () {
      expect(themeModeToPreference(ThemeMode.light), 'light');
      expect(themeModeToPreference(ThemeMode.dark), 'dark');
      expect(themeModeToPreference(ThemeMode.system), 'system');
    });
  });

  testWidgets('OnboardingGate renders child when onboarding completed',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboarding_completed': true,
      'onboarding_version': 1,
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingGate(child: Text('home')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
