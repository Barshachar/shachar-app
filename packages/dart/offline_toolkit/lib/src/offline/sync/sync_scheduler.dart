import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'package:offline_toolkit/src/offline/deps.dart';
import 'package:offline_toolkit/src/offline/queue/offline_queue.dart';

typedef OTSyncHook = Future<void> Function();

final offlineSyncHooksProvider = Provider<List<OTSyncHook>>((ref) {
  return const <OTSyncHook>[];
});

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  final OTDeps deps = ref.watch(otDepsProvider);
  final List<OTSyncHook> hooks = ref.watch(offlineSyncHooksProvider);
  return SyncScheduler(queue: queue, deps: deps, hooks: hooks);
});

class SyncScheduler {
  SyncScheduler({
    required OfflineQueue queue,
    required this.deps,
    this.hooks = const <OTSyncHook>[],
  }) : _flushQueue = queue.flush;

  @visibleForTesting
  SyncScheduler.test({
    required Future<void> Function() flushQueue,
    required this.deps,
    this.hooks = const <OTSyncHook>[],
  }) : _flushQueue = flushQueue;

  final OTDeps deps;
  final List<OTSyncHook> hooks;
  final Future<void> Function() _flushQueue;

  Future<void> initialize() async {
    if (!_supportsBackgroundTasks) {
      return;
    }
    try {
      await Workmanager().initialize(callbackDispatcher);
      await Workmanager().registerPeriodicTask(
        'offline-sync',
        'offline-sync-task',
        frequency: const Duration(minutes: 30),
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (error) {
      debugPrint('[OFFLINE] workmanager_init_failed error=$error');
    }
  }

  Future<void> syncNow() async {
    String tenantId;
    try {
      tenantId = await deps.tenant.activeCompanyId();
    } catch (error) {
      deps.logger.warn(
        'offline.sync.skip_no_tenant',
        {'error': error.toString()},
      );
      return;
    }
    final bool isOnline = await deps.net.isOnline();
    if (!isOnline) {
      deps.logger.info(
        'offline.sync.skip_offline',
        {'tenant': tenantId},
      );
      return;
    }
    deps.logger.info('offline.sync.start', {'tenant': tenantId});
    try {
      await _flushQueue();
    } catch (error, stackTrace) {
      deps.logger.error(
        'offline.sync.queue_failed',
        {'error': error.toString(), 'tenant': tenantId},
      );
      debugPrintStack(stackTrace: stackTrace, label: '[OFFLINE]');
    }

    try {
      await _runHooks();
    } catch (error, stackTrace) {
      deps.logger.warn(
        'offline.sync.hooks_failed',
        {'error': error.toString(), 'tenant': tenantId},
      );
      debugPrintStack(stackTrace: stackTrace, label: '[OFFLINE]');
    }
    deps.logger.info('offline.sync.complete', {'tenant': tenantId});
  }

  Future<void> _runHooks() async {
    for (final OTSyncHook hook in hooks) {
      await hook();
    }
  }

  bool get _supportsBackgroundTasks {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android;
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // A no-op placeholder; the foreground app handles syncing when resumed or scheduled.
    return true;
  });
}
