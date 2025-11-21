import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_toolkit/offline_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockSupabaseFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late Directory tempDir;
  late OfflineQueue queue;
  late _MockSupabaseClient client;
  late _MockSupabaseFunctionsClient functions;
  late List<Map<String, dynamic>> invocations;
  late OTDeps deps;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_queue_isolation');
    HiveInitializer.debugInitializerOverride = () async {
      Hive.init('${tempDir.path}/hive');
    };

    client = _MockSupabaseClient();
    functions = _MockSupabaseFunctionsClient();
    invocations = <Map<String, dynamic>>[];

    when(() => client.functions).thenReturn(functions);
    when(() => functions.invoke(any(), body: any(named: 'body'))).thenAnswer(
      (invocation) async {
        final String endpoint = invocation.positionalArguments.first as String;
        final Map<String, dynamic> body =
            Map<String, dynamic>.from(invocation.namedArguments[#body] as Map);
        invocations.add(<String, dynamic>{'endpoint': endpoint, 'body': body});
        return FunctionResponse(data: <String, dynamic>{}, status: 200);
      },
    );

    deps = OTDeps(
      logger: const OTNoopLogger(),
      clock: const SystemOTClock(),
      net: const StaticNetStatus(true),
      tenant: const StaticTenantResolver('tenant_a'),
    );
    queue = OfflineQueue(client: client, deps: deps);
    await queue.initialize();
  });

  tearDown(() async {
    await queue.clearAllTenants();
    await Hive.close();
    HiveInitializer.debugInitializerOverride = null;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('queue flushes only for active tenant', () async {
    await queue.setActiveTenant('tenant_a');
    await queue.enqueue('sync-user', {'tenant': 'A'});

    await queue.setActiveTenant('tenant_b');
    await queue.enqueue('sync-user', {'tenant': 'B'});

    await queue.flush();

    expect(invocations.length, 1);
    expect(invocations.single['body'], equals({'tenant': 'B'}));

    await queue.setActiveTenant('tenant_a');
    await queue.flush();

    expect(invocations.length, 2);
    expect(invocations.last['body'], equals({'tenant': 'A'}));
  });
}
