import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/logger/app_logger.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:offline_toolkit/offline_toolkit.dart';

List<dynamic> buildOfflineToolkitOverrides() {
  return [
    otDepsProvider.overrideWith((ref) {
      return OfflineToolkit.forApp(
        AppBridges(
          ref: ref,
          logger: (innerRef) =>
              AppLoggerAdapter(innerRef.watch(appLoggerProvider)),
          clock: (_) => const SystemOTClock(),
          netStatus: (_) => ConnectivityNetStatus(Connectivity()),
          tenantResolver: (innerRef) => SessionTenantResolver(innerRef),
        ),
      );
    }),
    offlineSyncHooksProvider.overrideWith((ref) {
      final CatalogRepository catalog = ref.read(catalogRepositoryProvider);
      return <OTSyncHook>[
        () => catalog.fetchCategories(refresh: true),
        () => catalog.fetchProducts(refresh: true),
      ];
    }),
  ];
}

class AppLoggerAdapter implements OTLogger {
  AppLoggerAdapter(this._logger);

  final Logger _logger;

  @override
  void debug(String message, [Object? context]) {
    _logger.fine(_format(message, context));
  }

  @override
  void info(String message, [Object? context]) {
    _logger.info(_format(message, context));
  }

  @override
  void warn(String message, [Object? context]) {
    _logger.warning(_format(message, context));
  }

  @override
  void error(String message, [Object? context]) {
    _logger.severe(_format(message, context));
  }

  String _format(String message, Object? context) {
    if (context == null) {
      return message;
    }
    return '$message :: $context';
  }
}

class ConnectivityNetStatus implements OTNetStatus {
  ConnectivityNetStatus(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> isOnline() async {
    final dynamic result = await _connectivity.checkConnectivity();
    if (result is List<ConnectivityResult>) {
      return result.any((ConnectivityResult r) => r != ConnectivityResult.none);
    }
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return false;
  }
}

class SessionTenantResolver implements OTTenantResolver {
  SessionTenantResolver(this._ref);

  final Ref _ref;

  @override
  Future<String> activeCompanyId() async {
    final AsyncValue<Session?> sessionValue =
        _ref.read(sessionControllerProvider);
    final Session? session = sessionValue.value;
    final String? companyId = _companyIdFromSession(session);
    if (companyId != null && companyId.isNotEmpty) {
      return companyId;
    }
    throw StateError('Missing active tenant');
  }

  String? _companyIdFromSession(Session? session) {
    final Object? companyRaw = session?.user.appMetadata['company_id'];
    if (companyRaw is String && companyRaw.trim().isNotEmpty) {
      return companyRaw.trim();
    }
    return null;
  }
}
