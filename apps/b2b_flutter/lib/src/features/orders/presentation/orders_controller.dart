import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/reorder_plan.dart';

final ordersControllerProvider =
    FutureProvider.autoDispose<List<OrderSummary>>((ref) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.fetchOrders();
});

final orderDetailProvider =
    FutureProvider.autoDispose.family<OrderDetail, String>((ref, id) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.getOrder(id);
});

final orderActionsControllerProvider = Provider<OrderActionsController>((ref) {
  final ordersRepository = ref.read(ordersRepositoryProvider);
  final catalogRepository = ref.read(catalogRepositoryProvider);
  return OrderActionsController(
    ref,
    ordersRepository: ordersRepository,
    catalogRepository: catalogRepository,
  );
});

class OrderActionsController {
  OrderActionsController(
    this._ref, {
    required OrdersRepository ordersRepository,
    required CatalogRepository catalogRepository,
  })  : _ordersRepository = ordersRepository,
        _catalogRepository = catalogRepository;

  final Ref _ref;
  final OrdersRepository _ordersRepository;
  final CatalogRepository _catalogRepository;

  Future<String> reorderOrder(
    String orderId, {
    BuildContext? context,
  }) async {
    final BuildContext? ctx = context;
    final ScaffoldMessengerState? messenger =
        ctx != null ? ScaffoldMessenger.maybeOf(ctx) : null;
    final GoRouter? router = ctx != null ? GoRouter.maybeOf(ctx) : null;

    final OrderDetail detail = await _ordersRepository.getOrder(orderId);
    if (detail.items.isEmpty) {
      throw StateError('Order has no items to reorder');
    }

    final products = await _catalogRepository.fetchProducts();
    final ReorderPlan plan = buildReorderPlan(
      items: detail.items,
      catalog: products,
    );

    if (!plan.hasEligibleLines) {
      throw StateError('No active items available to reorder');
    }

    final String draftId = await _ordersRepository.createDraftIfMissing();
    for (final ReorderLine line in plan.lines) {
      await _ordersRepository.addLineToOrder(
        orderId: draftId,
        variantId: line.variantId,
        qty: line.qty,
      );
    }

    final String newOrderId = await _ordersRepository.submitDraftOrder(draftId);

    _ref.invalidate(ordersControllerProvider);
    _ref.invalidate(orderDetailProvider(newOrderId));

    if (ctx != null && ctx.mounted) {
      final int added = plan.addedCount;
      final int skipped = plan.skippedCount;
      final String message = 'Reordered $added items ($skipped skipped)';
      messenger?.showSnackBar(SnackBar(content: Text(message)));
      router?.go('/customer/orders/$newOrderId');
    }

    return newOrderId;
  }
}
