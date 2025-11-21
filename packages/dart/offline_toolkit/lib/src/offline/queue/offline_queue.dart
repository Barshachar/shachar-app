import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:offline_toolkit/src/offline/deps.dart';
import 'package:offline_toolkit/src/offline/hive_initializer.dart';

final offlineQueueProvider = Provider<OfflineQueue>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  final OTDeps deps = ref.watch(otDepsProvider);
  return OfflineQueue(client: client, deps: deps);
});

class OfflineQueue {
  OfflineQueue({required SupabaseClient client, required this.deps})
      : _client = client;

  static const String _boxPrefix = '_offline_queue';
  static const String _anonymousTenant = 'anonymous';
  static const int _maxAttempts = 3;
  static const int cacheVersion = 1;

  final SupabaseClient _client;
  final OTDeps deps;

  bool _initialized = false;
  String _activeTenant = _anonymousTenant;
  Box<String>? _box;
  final Set<String> _openedBoxes = <String>{};

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await HiveInitializer.ensureInitialized();

    _box = await Hive.openBox<String>(_currentBoxName);
    _openedBoxes.add(_currentBoxName);
    _initialized = true;
  }

  Future<void> setActiveTenant(String? tenantId) async {
    final String normalized = await _resolveTenant(tenantId);
    if (normalized == _activeTenant && _initialized) {
      return;
    }
    _activeTenant = normalized;
    if (_initialized) {
      await _box?.close();
      _box = await Hive.openBox<String>(_currentBoxName);
      _openedBoxes.add(_currentBoxName);
    }
  }

  Future<void> clearActiveTenant() async {
    if (!_initialized) {
      await initialize();
    }
    final Box<String> box = _box ?? await Hive.openBox<String>(_currentBoxName);
    await box.clear();
  }

  Future<void> clearAllTenants() async {
    for (final String name in _openedBoxes) {
      if (await Hive.boxExists(name)) {
        final Box<String> box = await Hive.openBox<String>(name);
        await box.clear();
        await box.close();
      }
    }
    _openedBoxes.clear();
    _initialized = false;
    _box = null;
  }

  Future<void> enqueue(String endpoint, Map<String, dynamic> payload,
      {String method = 'POST'}) async {
    await _ensureInitialized();
    final Box<String> box = _box ?? Hive.box<String>(_currentBoxName);
    final OfflineJob job = OfflineJob(
      endpoint: endpoint,
      payload: payload,
      method: method,
      tenantId: _activeTenant,
      queuedAt: deps.clock.now(),
      attempts: 0,
    );
    await box.add(jsonEncode(job.toJson()));
    deps.logger.debug(
      'offline.queue.enqueue',
      {'endpoint': endpoint, 'tenant': _activeTenant},
    );
  }

  Future<void> flush() async {
    await _ensureInitialized();
    final Box<String> box = _box ?? Hive.box<String>(_currentBoxName);
    if (box.isEmpty) {
      deps.logger.debug(
        'offline.queue.flush_skipped',
        {'tenant': _activeTenant, 'reason': 'empty'},
      );
      return;
    }
    final List<String> rawJobs = box.values.toList(growable: false);
    deps.logger.info(
      'offline.queue.flush_start',
      {'tenant': _activeTenant, 'jobs': rawJobs.length},
    );
    final List<String> retryQueue = <String>[];

    for (final String raw in rawJobs) {
      final OfflineJob job =
          OfflineJob.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (job.tenantId != _activeTenant) {
        deps.logger.debug(
          'offline.queue.job_deferred',
          {'tenant': job.tenantId, 'active': _activeTenant},
        );
        retryQueue.add(raw);
        continue;
      }

      try {
        await _client.functions.invoke(job.endpoint, body: job.payload);
        deps.logger.debug(
          'offline.queue.job_dispatched',
          {'endpoint': job.endpoint, 'tenant': job.tenantId},
        );
      } catch (error) {
        if (job.attempts + 1 >= _maxAttempts) {
          // Drop the job after exhausting retries to prevent infinite loops.
          deps.logger.error(
            'offline.queue.job_dropped',
            {
              'endpoint': job.endpoint,
              'tenant': job.tenantId,
              'attempts': job.attempts + 1,
              'error': error.toString(),
            },
          );
          continue;
        }
        deps.logger.warn(
          'offline.queue.job_retry',
          {
            'endpoint': job.endpoint,
            'tenant': job.tenantId,
            'attempts': job.attempts + 1,
            'error': error.toString(),
          },
        );
        retryQueue
            .add(jsonEncode(job.copyWith(attempts: job.attempts + 1).toJson()));
        break;
      }
    }

    await box.clear();
    for (final String encoded in retryQueue) {
      await box.add(encoded);
    }
    deps.logger.info(
      'offline.queue.flush_complete',
      {'tenant': _activeTenant, 'remaining': retryQueue.length},
    );
  }

  Stream<int> watchPendingCount({String? tenantId}) async* {
    await HiveInitializer.ensureInitialized();
    final String normalized = await _resolveTenant(tenantId);
    final Box<String> box =
        await Hive.openBox<String>('${_boxPrefix}_$normalized');
    yield _countTenantJobs(box, normalized);
    await for (final _ in box.watch()) {
      yield _countTenantJobs(box, normalized);
    }
  }

  int _countTenantJobs(Box<String> box, String tenantId) {
    int count = 0;
    for (final String raw in box.values) {
      try {
        final OfflineJob job =
            OfflineJob.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (job.tenantId == tenantId) {
          count++;
        }
      } catch (_) {
        // Ignore corrupted entries; they will be skipped on flush.
      }
    }
    return count;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized && _box != null && _box!.isOpen) {
      return;
    }
    await initialize();
  }

  String get _currentBoxName => '${_boxPrefix}_$_activeTenant';

  Future<String> _resolveTenant(String? tenantId) async {
    final String? trimmed = tenantId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    try {
      final String resolved = await deps.tenant.activeCompanyId();
      if (resolved.trim().isNotEmpty) {
        return resolved.trim();
      }
    } catch (error) {
      deps.logger.warn(
        'offline.queue.tenant_resolver_failed',
        {'error': error.toString()},
      );
    }
    return _anonymousTenant;
  }
}

class OfflineJob {
  OfflineJob({
    required this.endpoint,
    required this.payload,
    required this.method,
    required this.tenantId,
    required this.queuedAt,
    required this.attempts,
  });

  final String endpoint;
  final Map<String, dynamic> payload;
  final String method;
  final String tenantId;
  final DateTime queuedAt;
  final int attempts;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'endpoint': endpoint,
        'payload': payload,
        'method': method,
        'tenant_id': tenantId,
        'queued_at': queuedAt.toIso8601String(),
        'attempts': attempts,
      };

  OfflineJob copyWith({int? attempts}) => OfflineJob(
        endpoint: endpoint,
        payload: payload,
        method: method,
        tenantId: tenantId,
        queuedAt: queuedAt,
        attempts: attempts ?? this.attempts,
      );

  static OfflineJob fromJson(Map<String, dynamic> json) => OfflineJob(
        endpoint: json['endpoint'] as String,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
        method: (json['method'] as String?) ?? 'POST',
        tenantId: (json['tenant_id'] as String?) ?? _fallbackTenant,
        queuedAt: DateTime.tryParse(json['queued_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      );

  static const String _fallbackTenant = 'anonymous';
}
