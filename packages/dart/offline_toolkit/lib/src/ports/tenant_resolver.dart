/// Resolves the active tenant scope for offline operations.
abstract class OTTenantResolver {
  /// Returns the active company id to scope caches/queues.
  /// Implementations should throw if there is no authenticated tenant.
  Future<String> activeCompanyId();
}

/// Convenience resolver that always returns a fixed tenant id.
class StaticTenantResolver implements OTTenantResolver {
  const StaticTenantResolver(this.tenantId);

  final String tenantId;

  @override
  Future<String> activeCompanyId() async => tenantId;
}

/// Resolver that throws if a tenant id is not available.
class ThrowingTenantResolver implements OTTenantResolver {
  const ThrowingTenantResolver({this.currentCompanyId});

  final String? Function()? currentCompanyId;

  @override
  Future<String> activeCompanyId() async {
    final String? tenant = currentCompanyId?.call();
    if (tenant != null && tenant.trim().isNotEmpty) {
      return tenant.trim();
    }
    throw StateError(
      'Tenant not initialized: call AppBootstrap.initialize() first.',
    );
  }
}
