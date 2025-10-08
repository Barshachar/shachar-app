import 'dart:io';

import 'package:offline_toolkit/offline_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late OfflineCacheManager manager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_cache_test');
    HiveInitializer.debugInitializerOverride = () async {
      Hive.init('${tempDir.path}/hive');
    };
    manager = OfflineCacheManager();
    await manager.initialize();
  });

  tearDown(() async {
    await manager.clearAllTenants();
    await Hive.close();
    HiveInitializer.debugInitializerOverride = null;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('scopes cache entries per tenant', () async {
    await manager.setActiveTenant('tenant_a');
    await manager.write('catalog', {'value': 1});

    await manager.setActiveTenant('tenant_b');
    expect(manager.read('catalog'), isNull);

    await manager.write('catalog', {'value': 2});

    await manager.setActiveTenant('tenant_a');
    expect(manager.read('catalog')?['value'], 1);

    await manager.setActiveTenant('tenant_b');
    expect(manager.read('catalog')?['value'], 2);
  });

  test('clearActiveTenant clears only scoped entries', () async {
    await manager.setActiveTenant('tenant_a');
    await manager.write('catalog', {'value': 1});
    await manager.write('prices', {'value': 10});

    await manager.setActiveTenant('tenant_b');
    await manager.write('catalog', {'value': 2});

    await manager.setActiveTenant('tenant_a');
    await manager.clearActiveTenant();

    expect(manager.read('catalog'), isNull);
    expect(manager.read('prices'), isNull);

    await manager.setActiveTenant('tenant_b');
    expect(manager.read('catalog')?['value'], 2);
  });
}
