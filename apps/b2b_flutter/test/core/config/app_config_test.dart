import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveSupabaseUrlForPlatform', () {
    test('maps IPv4 localhost to Android emulator loopback', () {
      const String original = 'http://127.0.0.1:54321';
      final String resolved = resolveSupabaseUrlForPlatform(
        original,
        platformOverride: TargetPlatform.android,
        isWebOverride: false,
      );
      expect(resolved, 'http://10.0.2.2:54321');
    });

    test('preserves non-loopback hosts', () {
      const String original = 'https://demo.supa.shahar.local';
      final String resolved = resolveSupabaseUrlForPlatform(
        original,
        platformOverride: TargetPlatform.android,
        isWebOverride: false,
      );
      expect(resolved, original);
    });

    test('keeps localhost unchanged on web', () {
      const String original = 'http://localhost:54321';
      final String resolved = resolveSupabaseUrlForPlatform(
        original,
        platformOverride: TargetPlatform.android,
        isWebOverride: true,
      );
      expect(resolved, original);
    });

    test('handles IPv6 loopback on Android', () {
      const String original = 'http://[::1]:54321/rest/v1';
      final String resolved = resolveSupabaseUrlForPlatform(
        original,
        platformOverride: TargetPlatform.android,
        isWebOverride: false,
      );
      expect(resolved, 'http://10.0.2.2:54321/rest/v1');
    });
  });
}
