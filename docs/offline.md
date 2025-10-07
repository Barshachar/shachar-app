# Offline Strategy (Phase-1)

- **Cache**: Product and category lists cached via `OfflineCacheManager` (Hive box). TTL handled by manual refresh.
- **Delta Sync**: Workmanager job (`SyncScheduler`) flushes queued mutations and refreshes caches every 30 minutes or user-initiated.
- **Queue**: `OfflineQueue` persists POST payloads (`endpoint`, `payload`, `queued_at`) and flushes when online.
- **Conflict Resolution**: server-authoritative for catalog/pricing; last-writer-wins for draft order quantities.
- **Fallback**: if Supabase unreachable, UI surfaces stale catalog with `SnackBar` warnings; submit button disabled until `syncSchedulerProvider.syncNow()` succeeds.
