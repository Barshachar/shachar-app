import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:offline_toolkit/src/offline/queue/offline_queue.dart';

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  final SessionController session =
      ref.watch(sessionControllerProvider.notifier);
  return SyncScheduler(queue: queue, sessionController: session, ref: ref);
});

class SyncScheduler {
  SyncScheduler({
    required this.queue,
    required this.sessionController,
    required this.ref,
  });

  final OfflineQueue queue;
  final SessionController sessionController;
  final Ref ref;

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
    if (!sessionController.isAuthenticated) {
      return;
    }
    try {
      await queue.flush();
    } catch (error, stackTrace) {
      debugPrint('[OFFLINE] queue_flush_failed error=$error');
      debugPrintStack(stackTrace: stackTrace);
    }

    try {
      await _refreshCaches();
    } catch (error, stackTrace) {
      debugPrint('[OFFLINE] cache_refresh_failed error=$error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _refreshCaches() async {
    final CatalogRepository catalog = ref.read(catalogRepositoryProvider);
    await Future.wait([
      catalog.fetchCategories(refresh: true),
      catalog.fetchProducts(refresh: true),
    ]);
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
