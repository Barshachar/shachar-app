import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:offline_toolkit/src/offline/deps.dart';
import 'package:offline_toolkit/src/offline/queue/offline_queue.dart';

final offlineQueuePendingCountProvider =
    StreamProvider.autoDispose<int>((ref) async* {
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  final OTDeps deps = ref.watch(otDepsProvider);
  try {
    final String tenantId = await deps.tenant.activeCompanyId();
    yield* queue.watchPendingCount(tenantId: tenantId);
  } catch (error) {
    deps.logger.warn(
      'offline.queue.pending_count_unavailable',
      {'error': error.toString()},
    );
    yield 0;
  }
});
