import 'package:ashachar_marketplace/src/features/pricing/data/pricing_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  group('SupabasePricingRepository', () {
    late _MockSupabaseClient mockClient;
    late _MockGoTrueClient mockAuth;

    setUpAll(() {
      registerFallbackValue(<String, dynamic>{});
    });

    setUp(() {
      mockClient = _MockSupabaseClient();
      mockAuth = _MockGoTrueClient();
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentSession).thenReturn(null);
      SupabasePricingRepository(mockClient);
    });

    test('effective price precedence (skipped – mock rework needed)',
        () async {},
        skip: true);
  });
}
