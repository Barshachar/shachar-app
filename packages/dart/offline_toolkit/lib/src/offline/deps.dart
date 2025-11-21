import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart' show Override;

import 'package:offline_toolkit/src/ports/clock.dart';
import 'package:offline_toolkit/src/ports/logger.dart';
import 'package:offline_toolkit/src/ports/net_status.dart';
import 'package:offline_toolkit/src/ports/tenant_resolver.dart';

/// Aggregates the runtime dependencies injected into offline primitives.
class OTDeps {
  OTDeps({
    OTLogger? logger,
    OTClock? clock,
    OTNetStatus? net,
    OTTenantResolver? tenant,
  })  : logger = logger ?? const OTNoopLogger(),
        clock = clock ?? const SystemOTClock(),
        net = net ?? const StaticNetStatus(true),
        tenant = tenant ?? const ThrowingTenantResolver();

  final OTLogger logger;
  final OTClock clock;
  final OTNetStatus net;
  final OTTenantResolver tenant;
}

/// Provider that exposes [OTDeps] to Riverpod consumers.
final otDepsProvider = Provider<OTDeps>((ref) {
  throw StateError(
    'OfflineToolkit dependencies not configured. '
    'Wrap your ProviderScope with OfflineToolkit.configure(...) or '
    'OfflineToolkit.forApp(...).',
  );
});

/// Convenience container that maps application providers to toolkit deps.
class AppBridges {
  const AppBridges({
    required this.ref,
    required this.logger,
    required this.clock,
    required this.netStatus,
    required this.tenantResolver,
  });

  final Ref ref;
  final OTLoggerFactory logger;
  final OTClockFactory clock;
  final OTNetStatusFactory netStatus;
  final OTTenantResolverFactory tenantResolver;
}

typedef OTLoggerFactory = OTLogger Function(Ref ref);
typedef OTClockFactory = OTClock Function(Ref ref);
typedef OTNetStatusFactory = OTNetStatus Function(Ref ref);
typedef OTTenantResolverFactory = OTTenantResolver Function(Ref ref);

class OfflineToolkit {
  static OTDeps forApp(AppBridges bridges) {
    final Ref ref = bridges.ref;
    return OTDeps(
      logger: bridges.logger(ref),
      clock: bridges.clock(ref),
      net: bridges.netStatus(ref),
      tenant: bridges.tenantResolver(ref),
    );
  }
}
