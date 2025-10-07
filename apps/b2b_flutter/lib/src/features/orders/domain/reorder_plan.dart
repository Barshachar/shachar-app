import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';

class ReorderLine {
  const ReorderLine({
    required this.variantId,
    required this.qty,
  });

  final String variantId;
  final double qty;
}

class ReorderPlan {
  ReorderPlan({
    required List<ReorderLine> lines,
    required this.skippedCount,
    required this.requestedCount,
  }) : lines = List<ReorderLine>.unmodifiable(lines);

  final List<ReorderLine> lines;
  final int skippedCount;
  final int requestedCount;

  int get addedCount => lines.length;

  bool get hasEligibleLines => lines.isNotEmpty;
}

ReorderPlan buildReorderPlan({
  required Iterable<OrderItem> items,
  required Iterable<Product> catalog,
}) {
  final List<OrderItem> materializedItems = items.toList(growable: false);
  if (materializedItems.isEmpty) {
    return ReorderPlan(
      lines: const <ReorderLine>[],
      skippedCount: 0,
      requestedCount: 0,
    );
  }

  final Set<String> requestedVariantIds = materializedItems
      .map((OrderItem item) => item.variantId)
      .where((String id) => id.isNotEmpty)
      .toSet();

  if (requestedVariantIds.isEmpty) {
    return ReorderPlan(
      lines: const <ReorderLine>[],
      skippedCount: materializedItems.length,
      requestedCount: materializedItems.length,
    );
  }

  final Set<String> activeVariants = <String>{};
  for (final Product product in catalog) {
    if (!product.active) {
      continue;
    }
    for (final ProductVariant variant in product.variants) {
      if (!variant.active) {
        continue;
      }
      final String variantId = variant.id;
      if (requestedVariantIds.contains(variantId)) {
        activeVariants.add(variantId);
        if (activeVariants.length == requestedVariantIds.length) {
          break;
        }
      }
    }
    if (activeVariants.length == requestedVariantIds.length) {
      break;
    }
  }

  final List<ReorderLine> eligibleLines = <ReorderLine>[];
  int skippedCount = 0;
  for (final OrderItem item in materializedItems) {
    final double qty = item.qty;
    final bool isActive = activeVariants.contains(item.variantId);
    if (qty <= 0 || !isActive) {
      skippedCount += 1;
      continue;
    }
    eligibleLines.add(ReorderLine(variantId: item.variantId, qty: qty));
  }

  return ReorderPlan(
    lines: eligibleLines,
    skippedCount: skippedCount,
    requestedCount: materializedItems.length,
  );
}
