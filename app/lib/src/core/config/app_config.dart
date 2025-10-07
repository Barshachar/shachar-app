import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef JsonMap = Map<String, dynamic>;

@immutable
class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    required this.isDebug,
    this.demoEmail,
    this.demoPassword,
    this.features = const <String, dynamic>{},
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String sentryDsn;
  final bool isDebug;
  final String? demoEmail;
  final String? demoPassword;
  final Map<String, dynamic> features;

  bool featureEnabled(String flag) => features[flag] == true;

  factory AppConfig.fromJson(JsonMap json) {
    final String? supabaseUrlRaw = _readString(json, const <String>[
      'SUPABASE_URL',
      'supabaseUrl',
      'supabase_url',
    ]);
    final String? supabaseAnonKey = _readString(json, const <String>[
      'SUPABASE_ANON_KEY',
      'supabaseAnonKey',
      'supabase_anon_key',
    ]);
    if (supabaseUrlRaw == null || supabaseAnonKey == null) {
      throw StateError('Invalid configuration: missing Supabase credentials.');
    }

    final String supabaseUrl = resolveSupabaseUrlForPlatform(supabaseUrlRaw);

    final String sentryDsn = _readString(
            json, const <String>['SENTRY_DSN', 'sentryDsn', 'sentry_dsn']) ??
        '';
    final bool isDebug =
        _readBool(json, const <String>['DEBUG', 'debug']) ?? false;
    final String? demoEmail = _readString(
      json,
      const <String>['DEMO_EMAIL', 'demoEmail', 'demo_email'],
    );
    final String? demoPassword = _readString(
      json,
      const <String>['DEMO_PASSWORD', 'demoPassword', 'demo_password'],
    );
    final Map<String, dynamic> features =
        _normalizeFeatureMap(json['features']);

    return AppConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      sentryDsn: sentryDsn,
      isDebug: isDebug,
      demoEmail: demoEmail,
      demoPassword: demoPassword,
      features: features,
    );
  }
}

final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  final raw = await _loadConfig();
  return AppConfig.fromJson(raw);
});

final debugFeaturesEnabledProvider = Provider<bool>((ref) {
  final configAsync = ref.watch(appConfigProvider);
  final bool configDebug = configAsync.maybeWhen(
    data: (config) => config.isDebug,
    orElse: () => false,
  );
  return kDebugMode || configDebug;
});

Future<JsonMap> _loadConfig() async {
  const String env = String.fromEnvironment('ENV', defaultValue: '');

  Future<JsonMap?> loadAsset(String path) async {
    try {
      final String data = await rootBundle.loadString(path);
      return jsonDecode(data) as JsonMap;
    } catch (_) {
      return null;
    }
  }

  final List<String> assetCandidates = <String>[
    if (env.isNotEmpty) 'assets/config/app_config.$env.json',
    'assets/config/app_config.json',
    'assets/.env.json',
  ];
  for (final String path in assetCandidates) {
    final JsonMap? config = await loadAsset(path);
    if (config != null) {
      return config;
    }
  }

  if (kIsWeb) {
    throw StateError('Missing configuration asset for web build.');
  }

  final List<String> fileCandidates = <String>[
    if (env.isNotEmpty) '.env.$env.json',
    '.env.json',
  ];
  for (final String filePath in fileCandidates) {
    final File file = File(filePath);
    if (await file.exists()) {
      final String data = await file.readAsString();
      return jsonDecode(data) as JsonMap;
    }
  }

  throw StateError(
    'Missing configuration. Provide assets/config/app_config.$env.json or .env.json.',
  );
}

String? _readString(JsonMap json, List<String> keys) {
  for (final String key in keys) {
    final Object? value = json[key];
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
  }
  return null;
}

bool? _readBool(JsonMap json, List<String> keys) {
  for (final String key in keys) {
    final Object? value = json[key];
    final bool? parsed = _asBool(value);
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

bool? _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final String normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }
  return null;
}

Map<String, dynamic> _normalizeFeatureMap(Object? raw) {
  if (raw is Map) {
    final Map<String, dynamic> normalized = <String, dynamic>{};
    raw.forEach((key, value) {
      if (key == null) {
        return;
      }
      normalized[key.toString()] = value;
    });
    return Map<String, dynamic>.unmodifiable(normalized);
  }
  return const <String, dynamic>{};
}

@visibleForTesting
String resolveSupabaseUrlForPlatform(
  String url, {
  TargetPlatform? platformOverride,
  bool? isWebOverride,
}) {
  final Uri? parsed = Uri.tryParse(url.trim());
  if (parsed == null || parsed.host.isEmpty) {
    return url;
  }

  final bool isLoopback = _isLoopbackHost(parsed.host);
  if (!isLoopback) {
    return url;
  }

  final bool isWeb = isWebOverride ?? kIsWeb;
  if (isWeb) {
    return url;
  }

  final TargetPlatform platform = platformOverride ?? defaultTargetPlatform;
  switch (platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      return parsed.replace(host: '10.0.2.2').toString();
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return url;
  }
}

bool _isLoopbackHost(String host) {
  final String normalized = host.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }

  const Set<String> loopbackHosts = <String>{
    'localhost',
    '127.0.0.1',
    '0.0.0.0',
    '::1',
  };

  if (loopbackHosts.contains(normalized)) {
    return true;
  }

  // Handle IPv6 loopback notation like [::1]
  if (normalized.startsWith('[') && normalized.endsWith(']')) {
    final String withoutBrackets =
        normalized.substring(1, normalized.length - 1);
    return loopbackHosts.contains(withoutBrackets);
  }

  return false;
}
