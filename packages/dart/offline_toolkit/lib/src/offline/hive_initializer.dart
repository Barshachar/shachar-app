import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Ensures Hive is initialized exactly once across the offline layer.
class HiveInitializer {
  HiveInitializer._();

  static bool _initialized = false;
  static Future<void> Function()? _override;

  /// Allows tests to override the default initialization behaviour.
  static set debugInitializerOverride(Future<void> Function()? override) {
    _override = override;
    _initialized = false;
  }

  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    if (_override != null) {
      await _override!();
      _initialized = true;
      return;
    }
    try {
      await Hive.initFlutter();
      _initialized = true;
    } on MissingPluginException {
      // Fallback for unit tests where platform channels are unavailable.
      Hive.init('.hive_cache');
      _initialized = true;
    }
  }
}
