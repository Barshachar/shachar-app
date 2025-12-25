import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';

@immutable
class CatalogRecommendationRequest {
  const CatalogRecommendationRequest({
    required this.excludedVariantIds,
    this.allowedVariantIds,
    this.limit = 6,
    this.seed,
  });

  final Set<String> excludedVariantIds;
  final Set<String>? allowedVariantIds;
  final int limit;
  final String? seed;

  static const SetEquality<String> _setEquality = SetEquality<String>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CatalogRecommendationRequest &&
        limit == other.limit &&
        seed == other.seed &&
        _setEquality.equals(excludedVariantIds, other.excludedVariantIds) &&
        _setEquality.equals(
          allowedVariantIds ?? const <String>{},
          other.allowedVariantIds ?? const <String>{},
        );
  }

  @override
  int get hashCode => Object.hash(
        limit,
        seed,
        _setEquality.hash(excludedVariantIds),
        _setEquality.hash(allowedVariantIds ?? const <String>{}),
      );
}

enum CatalogRecommendationReason {
  fastDelivery('recommendationFastDelivery'),
  lowMoq('recommendationLowMoq'),
  smallPack('recommendationSmallPack'),
  defaultReason('recommendationDefault');

  const CatalogRecommendationReason(this.l10nKey);

  final String l10nKey;
}

@immutable
class CatalogRecommendation {
  const CatalogRecommendation({
    required this.product,
    required this.variant,
    required this.reason,
  });

  final Product product;
  final ProductVariant variant;
  final CatalogRecommendationReason reason;
}

final catalogRecommendationsProvider = FutureProvider.autoDispose
    .family<List<CatalogRecommendation>, CatalogRecommendationRequest>(
  (ref, request) async {
    final CatalogRepository repository = ref.watch(catalogRepositoryProvider);
    final int targetCount = request.limit <= 0 ? 6 : request.limit;
    final int pageSize = targetCount < 6 ? 18 : targetCount * 3;
    final PagedProducts page = await repository.fetchProductsPage(
      limit: pageSize,
      offset: 0,
    );

    final Set<String> excluded = request.excludedVariantIds;
    final Set<String>? allowed = (request.allowedVariantIds == null ||
            request.allowedVariantIds!.isEmpty)
        ? null
        : request.allowedVariantIds;
    final List<CatalogRecommendation> candidates = <CatalogRecommendation>[];

    for (final Product product in page.items) {
      final ProductVariant? variant = _pickVariant(
        product,
        allowedVariantIds: allowed,
      );
      if (variant == null) {
        continue;
      }
      if (excluded.contains(variant.id)) {
        continue;
      }
      candidates.add(
        CatalogRecommendation(
          product: product,
          variant: variant,
          reason: _resolveReason(product),
        ),
      );
    }

    candidates
        .sort((a, b) => _sortKey(a.product).compareTo(_sortKey(b.product)));
    if (candidates.length <= targetCount) {
      return candidates;
    }
    return candidates.take(targetCount).toList();
  },
);

CatalogRecommendationReason _resolveReason(Product product) {
  if (product.leadTime > 0 && product.leadTime <= 2) {
    return CatalogRecommendationReason.fastDelivery;
  }
  if (product.moq > 0 && product.moq <= 5) {
    return CatalogRecommendationReason.lowMoq;
  }
  if (product.packSize > 0 && product.packSize <= 5) {
    return CatalogRecommendationReason.smallPack;
  }
  return CatalogRecommendationReason.defaultReason;
}

ProductVariant? _pickVariant(
  Product product, {
  required Set<String>? allowedVariantIds,
}) {
  for (final ProductVariant variant in product.variants) {
    if (!variant.active) {
      continue;
    }
    if (allowedVariantIds != null && !allowedVariantIds.contains(variant.id)) {
      continue;
    }
    return variant;
  }
  return null;
}

String _sortKey(Product product) {
  final String primary =
      product.nameEn.isNotEmpty ? product.nameEn : product.nameHe;
  if (primary.isNotEmpty) {
    return primary.toLowerCase();
  }
  return product.sku.toLowerCase();
}
