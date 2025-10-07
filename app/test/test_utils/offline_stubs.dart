import 'package:ashachar_marketplace/src/offline/cache/offline_cache_manager.dart';
import 'package:ashachar_marketplace/src/offline/queue/offline_queue.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestOfflineCacheManager extends OfflineCacheManager {
  final Map<String, Map<String, Map<String, dynamic>>> _store =
      <String, Map<String, Map<String, dynamic>>>{};
  String _tenant = 'anonymous';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> setActiveTenant(String? tenantId) async {
    _tenant =
        (tenantId?.trim().isNotEmpty ?? false) ? tenantId!.trim() : 'anonymous';
  }

  @override
  Future<void> clearActiveTenant() async {
    _store.remove(_tenant);
  }

  @override
  Future<void> clearAllTenants() async {
    _store.clear();
  }

  @override
  Future<void> write(String key, Map<String, dynamic> value) async {
    final Map<String, Map<String, dynamic>> scoped =
        _store.putIfAbsent(_tenant, () => <String, Map<String, dynamic>>{});
    scoped[key] = value;
  }

  @override
  Map<String, dynamic>? read(String key) {
    return _store[_tenant]?[key];
  }
}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class TestOfflineQueue extends OfflineQueue {
  TestOfflineQueue() : super(client: _stubClient);

  static final _MockSupabaseClient _stubClient = _MockSupabaseClient();

  final List<Map<String, dynamic>> jobs = <Map<String, dynamic>>[];
  String _tenant = 'anonymous';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> setActiveTenant(String? tenantId) async {
    _tenant =
        (tenantId?.trim().isNotEmpty ?? false) ? tenantId!.trim() : 'anonymous';
  }

  @override
  Future<void> clearActiveTenant() async {
    jobs.removeWhere((Map<String, dynamic> job) => job['tenant'] == _tenant);
  }

  @override
  Future<void> clearAllTenants() async {
    jobs.clear();
  }

  @override
  Future<void> enqueue(String endpoint, Map<String, dynamic> payload,
      {String method = 'POST'}) async {
    jobs.add(<String, dynamic>{
      'endpoint': endpoint,
      'payload': payload,
      'method': method,
      'tenant': _tenant,
    });
  }

  @override
  Future<void> flush() async {}
}
