import 'package:flutter_test/flutter_test.dart';

import 'package:offline_toolkit/offline_toolkit.dart';

void main() {
  test('sync scheduler skips flush when offline', () async {
    final _RecordingLogger logger = _RecordingLogger();
    final _MutableNetStatus net = _MutableNetStatus(false);
    final SyncScheduler scheduler = SyncScheduler.test(
      flushQueue: () async => logger.events.add('flushed'),
      deps: OTDeps(
        logger: logger,
        net: net,
        tenant: const StaticTenantResolver('tenant_a'),
      ),
    );

    await scheduler.syncNow();

    expect(logger.events.where((e) => e.contains('flushed')), isEmpty);
    expect(
      logger.events.any((e) => e.contains('offline.sync.skip_offline')),
      isTrue,
    );
  });

  test('sync scheduler flushes queue when online and logs breadcrumbs',
      () async {
    final _RecordingLogger logger = _RecordingLogger();
    final _MutableNetStatus net = _MutableNetStatus(true);
    bool flushed = false;
    final List<String> hooks = <String>[];

    final SyncScheduler scheduler = SyncScheduler.test(
      flushQueue: () async {
        flushed = true;
        logger.events.add('queue_flushed');
      },
      deps: OTDeps(
        logger: logger,
        net: net,
        tenant: const StaticTenantResolver('tenant_a'),
      ),
      hooks: <OTSyncHook>[
        () async => hooks.add('hook_1'),
        () async => hooks.add('hook_2'),
      ],
    );

    await scheduler.syncNow();

    expect(flushed, isTrue);
    expect(hooks, equals(<String>['hook_1', 'hook_2']));
    expect(
      logger.events.where((e) => e.contains('offline.sync.start')),
      isNotEmpty,
    );
    expect(
      logger.events.where((e) => e.contains('offline.sync.complete')),
      isNotEmpty,
    );
  });
}

class _RecordingLogger implements OTLogger {
  final List<String> events = <String>[];

  @override
  void debug(String message, [Object? context]) {
    events.add('debug:$message');
  }

  @override
  void info(String message, [Object? context]) {
    events.add('info:$message');
  }

  @override
  void warn(String message, [Object? context]) {
    events.add('warn:$message');
  }

  @override
  void error(String message, [Object? context]) {
    events.add('error:$message');
  }
}

class _MutableNetStatus implements OTNetStatus {
  _MutableNetStatus(this.online);

  bool online;

  @override
  Future<bool> isOnline() async => online;
}
