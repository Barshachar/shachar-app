import 'dart:io';

import 'package:ashachar_marketplace/src/offline/hive_initializer.dart';
import 'package:ashachar_marketplace/src/offline/queue/offline_queue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockSupabaseFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late Directory tempDir;
  late OfflineQueue queue;
  late _MockSupabaseClient client;
  late _MockSupabaseFunctionsClient functions;
  late List<Map<String, dynamic>> invocations;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_queue_test');
    HiveInitializer.debugInitializerOverride = () async {
      Hive.init('${tempDir.path}/hive');
    };

    client = _MockSupabaseClient();
    functions = _MockSupabaseFunctionsClient();

    invocations = <Map<String, dynamic>>[];

    when(() => client.functions).thenReturn(functions);
    when(() => functions.invoke(any(), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final String endpoint = invocation.positionalArguments.first as String;
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(invocation.namedArguments[#body] as Map);
      invocations.add(<String, dynamic>{'endpoint': endpoint, 'body': body});
      return FunctionResponse(data: <String, dynamic>{}, status: 200);
    });

    queue = OfflineQueue(client: client);
    await queue.initialize();
    await queue.setActiveTenant('tenant_a');
  });

  tearDown(() async {
    await queue.clearAllTenants();
    await Hive.close();
    HiveInitializer.debugInitializerOverride = null;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('flush sends queued jobs for active tenant', () async {
    await queue.enqueue('sync-order', {'id': 1});

    await queue.flush();

    expect(invocations.length, 1);
    expect(
        invocations.single,
        equals({
          'endpoint': 'sync-order',
          'body': {'id': 1}
        }));

    await queue.flush();
    expect(invocations.length, 1);
  });

  test('flush skips jobs belonging to other tenants until switched', () async {
    await queue.enqueue('sync-order', {'id': 1});

    await queue.setActiveTenant('tenant_b');
    await queue.enqueue('sync-order', {'id': 2});

    await queue.flush();

    expect(invocations.length, 1);
    expect(
        invocations.first,
        equals({
          'endpoint': 'sync-order',
          'body': {'id': 2}
        }));

    await queue.setActiveTenant('tenant_a');
    await queue.flush();

    expect(invocations.length, 2);
    expect(
        invocations.last,
        equals({
          'endpoint': 'sync-order',
          'body': {'id': 1}
        }));
  });

  test('flush retries failed jobs up to max attempts', () async {
    int invokeCount = 0;
    when(() => functions.invoke('sync-order', body: any(named: 'body')))
        .thenAnswer((invocation) async {
      invokeCount += 1;
      if (invokeCount < 2) {
        throw Exception('network');
      }
      return FunctionResponse(data: <String, dynamic>{}, status: 200);
    });

    await queue.enqueue('sync-order', {'id': 1});

    await queue.flush();
    await queue.flush();

    expect(invokeCount, 2);
  });
}
