import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:offline_toolkit/src/offline/queue/offline_queue.dart';

final offlineQueuePendingCountProvider = StreamProvider.autoDispose<int>((ref) {
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  final AsyncValue<Session?> session = ref.watch(sessionControllerProvider);
  final String? tenantId =
      session.asData?.value?.user.appMetadata['company_id'] as String?;
  return queue.watchPendingCount(tenantId: tenantId);
});
