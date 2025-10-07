import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/promotions/presentation/promotions_page.dart';

final promotionsRepositoryProvider = Provider<PromotionsRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabasePromotionsRepository(client: client);
});

abstract class PromotionsRepository {
  Future<List<PromotionUiModel>> fetchPromotions();
}

class SupabasePromotionsRepository implements PromotionsRepository {
  SupabasePromotionsRepository({required this.client});

  final SupabaseClient client;

  @override
  Future<List<PromotionUiModel>> fetchPromotions() async {
    final now = DateTime.now().toIso8601String();

    final response = await client
        .from('promotions')
        .select('*')
        .eq('active', true)
        .lte('valid_from', now)
        .gte('valid_to', now)
        .order('priority', ascending: true);

    final promotions = (response as List<dynamic>).map((row) {
      final data = row as Map<String, dynamic>;

      // Parse JSON fields
      final title = data['title'] as Map<String, dynamic>?;
      final badgeLabel = data['badge_label'] as Map<String, dynamic>?;
      final terms = data['terms'] as Map<String, dynamic>?;
      final tags = (data['tags'] as List<dynamic>?)?.cast<String>() ?? [];

      final titleHe = title?['he'] as String? ?? '';
      final badgeLabelHe = badgeLabel?['he'] as String? ?? '';
      final termsHe = terms?['he'] as String?;

      // Format valid_to date
      final validTo = DateTime.parse(data['valid_to'] as String);
      final validUntilText = '${validTo.day}/${validTo.month}/${validTo.year}';

      return PromotionUiModel(
        id: data['id'] as String,
        title: titleHe,
        badgeLabel: badgeLabelHe,
        validUntilText: validUntilText,
        termsText: termsHe,
        tags: tags,
        imageUrl: data['image_url'] as String?,
      );
    }).toList();

    return promotions;
  }
}
