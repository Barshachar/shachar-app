import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/auth/auth_resilience.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/logger/app_logger.dart';
import 'package:offline_toolkit/offline_toolkit.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';

class AppBootstrap {
  AppBootstrap({required this.container});

  final ProviderContainer container;

  Future<void> initialize() async {
    final config = await container.read(appConfigProvider.future);
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
      debug: config.isDebug,
    );
    final bool devOrDebug = kDebugMode || config.isDebug;
    if (devOrDebug) {
      await _ensureDemoSession(config);
    }
    container.read(appLoggerProvider).info('Supabase initialized');
    await container.read(offlineCacheManagerProvider).initialize();
    await container.read(syncSchedulerProvider).initialize();
    await container.read(sessionControllerProvider.notifier).hydrate();
  }

  Future<void> _ensureDemoSession(AppConfig config) async {
    final auth = Supabase.instance.client.auth;
    if (_hasCompany(auth.currentSession)) {
      return;
    }

    final String demoEmail = (config.demoEmail ?? '').isNotEmpty
        ? config.demoEmail!.trim()
        : 'buyer1@demo.local';
    final String demoPassword = (config.demoPassword ?? '').isNotEmpty
        ? config.demoPassword!
        : 'Demo123!';

    final ResilientAuthSignIn resilientSignIn = ResilientAuthSignIn(
      authClient: auth,
      maxAttempts: 3,
      onLog: (message) =>
          debugPrint('[AUTH_FLOW] $message source=bootstrap_resilience'),
    );

    const int maxAttempts = 3;
    Duration delay = const Duration(milliseconds: 400);
    bool signedIn = false;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      debugPrint(
        '[AUTH_FLOW] login=attempt source=bootstrap number=$attempt email=$demoEmail',
      );

      try {
        await auth.signOut();
        debugPrint(
          '[AUTH_FLOW] login=info action=bootstrap_signout_ok attempt=$attempt',
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[AUTH_FLOW] login=bootstrap_signout_failed attempt=$attempt error=$error',
        );
        debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      }

      try {
        final AuthResponse response = await resilientSignIn.signInWithPassword(
          email: demoEmail,
          password: demoPassword,
        );
        final User? user = response.user ?? response.session?.user;
        final String companyId = _companyIdFromUser(user);
        final String identifier = _userIdentifier(user);

        if (companyId.isEmpty) {
          debugPrint(
            '[AUTH_FLOW] login=warn reason=missing_company_id attempt=$attempt user=$identifier source=bootstrap',
          );
          if (attempt == maxAttempts) {
            debugPrint(
              '[AUTH_FLOW] login=fail reason=missing_company_id_persisted user=$identifier source=bootstrap',
            );
          }
        } else {
          debugPrint(
            '[AUTH_FLOW] login=ok company_id=$companyId user=$identifier attempt=$attempt source=bootstrap',
          );
          container.read(appLoggerProvider).info(
                'Demo sign-in result: ${response.session != null}, company_id=$companyId',
              );
          signedIn = true;
          break;
        }
      } on AuthException catch (error, stackTrace) {
        debugPrint(
          '[AUTH_FLOW] login=fail type=auth status=${error.statusCode ?? 'n/a'} message=${error.message} attempt=$attempt source=bootstrap',
        );
        debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      } catch (error, stackTrace) {
        debugPrint(
          '[AUTH_FLOW] login=fail type=unexpected error=$error attempt=$attempt source=bootstrap',
        );
        debugPrintStack(stackTrace: stackTrace, label: '[AUTH_FLOW]');
      }

      if (signedIn) {
        break;
      }

      if (attempt < maxAttempts) {
        await Future<void>.delayed(delay);
        final int nextDelayMs =
            delay.inMilliseconds >= 1600 ? 1600 : delay.inMilliseconds * 2;
        delay = Duration(milliseconds: nextDelayMs);
      }
    }

    if (!signedIn) {
      debugPrint('[AUTH_FLOW] login=fail reason=bootstrap_exhausted');
      container
          .read(appLoggerProvider)
          .warning('Demo sign-in exhausted attempts', null, null);
    }
  }

  bool _hasCompany(Session? session) {
    if (session == null || session.user.appMetadata.isEmpty) {
      return false;
    }
    final Object? raw = session.user.appMetadata['company_id'];
    if (raw is String) {
      return raw.trim().isNotEmpty;
    }
    return false;
  }

  String _companyIdFromUser(User? user) {
    final Map<String, dynamic> metadata = <String, dynamic>{
      ...?user?.appMetadata,
      if (user?.userMetadata != null)
        ...Map<String, dynamic>.from(user!.userMetadata!),
    };
    final Object? raw = metadata['company_id'];
    if (raw is String) {
      return raw.trim();
    }
    return '${raw ?? ''}'.trim();
  }

  String _userIdentifier(User? user) {
    return user?.email ?? user?.id ?? 'bootstrap-user';
  }
}
