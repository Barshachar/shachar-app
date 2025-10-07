import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/pricing/domain/effective_price.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabasePricingRepository(client);
});

abstract class PricingRepository {
  Future<EffectivePrice> resolveEffectivePrice(
      {required String variantId, required int quantity});
}

class SupabasePricingRepository implements PricingRepository {
  SupabasePricingRepository(this.client);

  final SupabaseClient client;

  @override
  Future<EffectivePrice> resolveEffectivePrice(
      {required String variantId, required int quantity}) async {
    final session = client.auth.currentSession;
    final companyId = session?.user.appMetadata['company_id'] as String?;
    final List<dynamic> response =
        await client.rpc<List<dynamic>>('rpc_effective_price', params: {
      'p_customer': companyId,
      'p_variant': variantId,
      'p_qty': quantity,
    });

    if (response.isNotEmpty) {
      final row = response.first as Map<String, dynamic>;
      return EffectivePrice(
        vendorId: row['vendor_id'] as String,
        variantId: variantId,
        currency: row['currency'] as String,
        unitPrice: (row['unit_price'] as num).toDouble(),
        scope: row['price_list_scope'] as String,
      );
    }

    throw StateError('No price available for variant $variantId');
  }
}
