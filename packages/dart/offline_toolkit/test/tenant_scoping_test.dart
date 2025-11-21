import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_toolkit/offline_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockSupabaseFunctionsClient extends Mock implements FunctionsClient {}

class _StubTenantResolver implements OTTenantResolver {
  _StubTenantResolver(this._tenant);

  String _tenant;

  set tenant(String value) => _tenant = value;

  @override
  Future<String> activeCompanyId() async => _tenant;
}

void main() {
  late Directory tempDir;
  late OfflineQueue queue;
  late _MockSupabaseClient client;
  late _MockSupabaseFunctionsClient functions;
  late _StubTenantResolver resolver;
  final List<String> invokedTenants = <String>[];

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_queue_scope');
    HiveInitializer.debugInitializerOverride = () async {
      Hive.init('${tempDir.path}/hive');
    };

    client = _MockSupabaseClient();
    functions = _MockSupabaseFunctionsClient();
    resolver = _StubTenantResolver('tenant_a');

    when(() => client.functions).thenReturn(functions);
    when(() => functions.invoke(any(), body: any(named: 'body'))).thenAnswer(
      (invocation) async {
        invokedTenants.add(
          (invocation.namedArguments[#body] as Map)['tenant'] as String,
        );
        return FunctionResponse(data: <String, dynamic>{}, status: 200);
      },
    );

    final OTDeps deps = OTDeps(
      tenant: resolver,
      logger: const OTNoopLogger(),
    );

    queue = OfflineQueue(client: client, deps: deps);
    await queue.initialize();
  });

  tearDown(() async {
    await queue.clearAllTenants();
    await Hive.close();
    HiveInitializer.debugInitializerOverride = null;
    invokedTenants.clear();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('flush only dispatches events scoped to active tenant resolver',
      () async {
    await queue.setActiveTenant(null);
    await queue.enqueue('sync', <String, dynamic>{'tenant': 'tenant_a'});

    resolver.tenant = 'tenant_b';
    await queue.setActiveTenant(null);
    await queue.enqueue('sync', <String, dynamic>{'tenant': 'tenant_b'});

    await queue.flush();

    expect(invokedTenants, equals(<String>['tenant_b']));

    resolver.tenant = 'tenant_a';
    await queue.setActiveTenant(null);
    await queue.flush();

    expect(invokedTenants, equals(<String>['tenant_b', 'tenant_a']));
  });
}
