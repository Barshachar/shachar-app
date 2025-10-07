import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'offline_stubs.dart';

class FakeSessionController extends SessionController {
  FakeSessionController(Session session)
      : super(
          client: Supabase.instance.client,
          logger: _StubLogger(),
          cacheManager: TestOfflineCacheManager(),
          queue: TestOfflineQueue(),
        ) {
    state = AsyncData(session);
  }
}

class _StubLogger {
  void info(Object? _) {}
  void warning(Object? _, [Object? __, Object? ___]) {}
}
