import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/core/logger/app_logger.dart';
import 'package:ashachar_marketplace/src/offline/cache/offline_cache_manager.dart';
import 'package:ashachar_marketplace/src/offline/queue/offline_queue.dart';

final sessionControllerProvider =
    StateNotifierProvider<SessionController, AsyncValue<Session?>>((ref) {
  final client = Supabase.instance.client;
  final logger = ref.watch(appLoggerProvider);
  final OfflineCacheManager cacheManager =
      ref.watch(offlineCacheManagerProvider);
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  final SessionController controller = SessionController(
    client: client,
    logger: logger,
    cacheManager: cacheManager,
    queue: queue,
  ).._listenToAuthChanges();
  unawaited(controller.hydrate());
  return controller;
});

class SessionController extends StateNotifier<AsyncValue<Session?>> {
  SessionController({
    required this.client,
    required this.logger,
    required this.cacheManager,
    required this.queue,
  }) : super(const AsyncData(null));

  final SupabaseClient client;
  final dynamic logger;
  final OfflineCacheManager cacheManager;
  final OfflineQueue queue;
  StreamSubscription<AuthState>? _authSub;

  bool get isAuthenticated => state.value != null;

  Future<void> hydrate() async {
    final Session? session = client.auth.currentSession;
    await _handleSessionChange(session);
  }

  void _listenToAuthChanges() {
    _authSub?.cancel();
    _authSub = client.auth.onAuthStateChange.listen((event) {
      logger.info('Auth state changed: ${event.event}');
      unawaited(_handleSessionChange(event.session));
    });
  }

  Future<void> signOut() async {
    await client.auth.signOut();
    await Future.wait([
      queue.clearActiveTenant(),
      cacheManager.clearActiveTenant(),
    ]);
    await queue.setActiveTenant(null);
    await cacheManager.setActiveTenant(null);
    state = const AsyncData(null);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _handleSessionChange(Session? session) async {
    await cacheManager.initialize();
    await queue.initialize();
    final String? tenant = _companyIdFromSession(session);
    await Future.wait([
      cacheManager.setActiveTenant(tenant),
      queue.setActiveTenant(tenant),
    ]);
    state = AsyncData(session);
  }

  String? _companyIdFromSession(Session? session) {
    final Object? companyRaw = session?.user.appMetadata['company_id'];
    if (companyRaw is String && companyRaw.trim().isNotEmpty) {
      return companyRaw.trim();
    }
    return null;
  }
}
