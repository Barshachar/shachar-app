import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_utils/offline_supabase.dart';

SupabasePriceResolutionService _buildService({
  required Future<Map<String, dynamic>?> Function(
          String functionName, Map<String, dynamic> params)
      rpc,
  bool fallback = false,
}) {
  return SupabasePriceResolutionService(
    Supabase.instance.client,
    rpcOverride: rpc,
    offlineFallbackResolver: () => fallback,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ensureSupabaseForTests();
  });

  group('loadCompanyCatalog', () {
    test('returns set from list of strings', () async {
      final service = _buildService(
        rpc: (fn, params) async {
          if (fn == 'rpc_company_catalog') {
            return <String, dynamic>{
              'data': <dynamic>['VAR-1', 'VAR-2'],
            };
          }
          return <String, dynamic>{};
        },
      );

      final Set<String>? variants =
          await service.loadCompanyCatalog(companyId: 'COMP-1');

      expect(variants, isNotNull);
      expect(variants, equals(<String>{'VAR-1', 'VAR-2'}));
    });

    test('returns set from list of maps', () async {
      final service = _buildService(
        rpc: (fn, params) async {
          if (fn == 'rpc_company_catalog') {
            return <String, dynamic>{
              'rows': <dynamic>[
                <String, dynamic>{'variant_id': 'VAR-1'},
                <String, dynamic>{'id': 'VAR-3'},
                <String, dynamic>{'variant_id': null},
              ],
            };
          }
          return <String, dynamic>{};
        },
      );

      final Set<String>? variants =
          await service.loadCompanyCatalog(companyId: 'COMP-1');

      expect(variants, isNotNull);
      expect(variants, equals(<String>{'VAR-1', 'VAR-3'}));
    });

    test('throws when rpc throws without fallback', () async {
      final service = _buildService(
        rpc: (fn, params) {
          if (fn == 'rpc_company_catalog') {
            return Future<Map<String, dynamic>?>.error(Exception('network'));
          }
          return Future<Map<String, dynamic>?>.value(<String, dynamic>{});
        },
      );

      await expectLater(
        service.loadCompanyCatalog(companyId: 'COMP-1'),
        throwsA(isA<Exception>()),
      );
    });

    test('returns null when rpc throws with offline fallback', () async {
      final service = _buildService(
        rpc: (fn, params) {
          if (fn == 'rpc_company_catalog') {
            return Future<Map<String, dynamic>?>.error(Exception('network'));
          }
          return Future<Map<String, dynamic>?>.value(<String, dynamic>{});
        },
        fallback: true,
      );

      final Set<String>? variants =
          await service.loadCompanyCatalog(companyId: 'COMP-1');

      expect(variants, isNull);
    });
  });
}
