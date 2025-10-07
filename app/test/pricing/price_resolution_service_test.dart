import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabasePriceResolutionService _buildService({
  required Future<Map<String, dynamic>?> Function(
          String functionName, Map<String, dynamic> params)
      rpc,
  DateTime Function()? clock,
  bool fallback = false,
}) {
  return SupabasePriceResolutionService(
    SupabaseClient('https://example.supabase.co', 'anon-key'),
    rpcOverride: rpc,
    clock: clock,
    offlineFallbackResolver: () => fallback,
  );
}

void main() {
  group('SupabasePriceResolutionService', () {
    test('returns parsed value on success', () async {
      final service = _buildService(
        rpc: (fn, params) async => <String, dynamic>{
          'unit_price': 19.5,
          'currency': 'USD',
          'vat_included': true,
          'pricing_source': 'contract',
        },
      );

      final PriceResolution? result = await service.resolve(
        companyId: 'comp-1',
        variantId: 'variant-1',
        qty: 3,
      );

      expect(result, isNotNull);
      expect(result!.price, closeTo(19.5, 0.0001));
      expect(result.currency, 'USD');
      expect(result.vatIncluded, isTrue);
      expect(result.source, 'contract');
    });

    test('caches subsequent identical resolve calls', () async {
      int callCount = 0;
      final service = _buildService(
        rpc: (fn, params) async {
          callCount += 1;
          return <String, dynamic>{
            'price': 12,
            'currency': 'EUR',
            'vat_included': false,
            'pricing_source': 'base',
          };
        },
        clock: () => DateTime.utc(2024, 1, 1, 12, 0, 0),
      );

      final first = await service.resolve(
        companyId: 'comp',
        variantId: 'variant',
        qty: 5,
      );
      final second = await service.resolve(
        companyId: 'comp',
        variantId: 'variant',
        qty: 5,
      );

      expect(first?.price, 12);
      expect(second?.price, 12);
      expect(callCount, 1);
    });

    test('throws when rpc throws without fallback', () async {
      final service = _buildService(
        rpc: (fn, params) =>
            Future<Map<String, dynamic>?>.error(Exception('network')),
      );

      await expectLater(
        service.resolve(
          companyId: 'comp',
          variantId: 'variant',
          qty: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('returns null when rpc throws with offline fallback', () async {
      final service = _buildService(
        rpc: (fn, params) =>
            Future<Map<String, dynamic>?>.error(Exception('network')),
        fallback: true,
      );

      final result = await service.resolve(
        companyId: 'comp',
        variantId: 'variant',
        qty: 1,
      );

      expect(result, isNull);
    });
  });
}
