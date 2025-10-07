// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:go_router/go_router.dart';
import 'package:postgrest/postgrest.dart';

import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';

final cartControllerProvider =
    legacy.StateNotifierProvider<CartController, CartState>((ref) {
  final OrdersRepository repository = ref.read(ordersRepositoryProvider);
  final CatalogRepository catalogRepository =
      ref.read(catalogRepositoryProvider);
  return CartController(
    ref,
    repository,
    catalogRepository: catalogRepository,
  );
});

final cartLinesProvider = FutureProvider.autoDispose
    .family<List<CartLine>, String>((ref, orderId) async {
  final OrdersRepository repository = ref.watch(ordersRepositoryProvider);
  final List<CartLine> lines = await repository.fetchCartLines(orderId);
  return lines;
});

class CartState {
  const CartState({this.draftOrderId, this.isLoading = false});

  final String? draftOrderId;
  final bool isLoading;

  CartState copyWith({String? draftOrderId, bool? isLoading}) {
    return CartState(
      draftOrderId: draftOrderId ?? this.draftOrderId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CartController extends legacy.StateNotifier<CartState> {
  CartController(
    this._ref,
    this._ordersRepository, {
    required CatalogRepository catalogRepository,
  })  : _catalogRepository = catalogRepository,
        super(const CartState());

  final Ref _ref;
  final OrdersRepository _ordersRepository;
  final CatalogRepository _catalogRepository;

  Future<String> _ensureDraftOrder({bool forceRefresh = false}) async {
    final String? existing = state.draftOrderId;
    if (!forceRefresh && existing != null && existing.isNotEmpty) {
      return existing;
    }
    return ensureOpenDraft();
  }

  Future<void> addVariant(
    ProductVariant variant, {
    double qty = 1,
  }) async {
    final double safeQty = qty <= 0 ? 1 : qty;
    final String orderId = await _ensureDraftOrder();
    await _ordersRepository.addLineToOrder(
      orderId: orderId,
      variantId: variant.id,
      qty: safeQty,
    );
    _ref.invalidate(cartLinesProvider(orderId));
  }

  Future<void> addBySkuOrBarcode(
    String code, {
    double qty = 1,
  }) async {
    final String trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(code, 'code', 'cannot be empty');
    }

    final ProductVariant? variant = await _findVariantByCode(trimmed);
    if (variant == null) {
      throw StateError('Variant not found for code $trimmed');
    }
    await addVariant(variant, qty: qty);
  }

  Future<ProductVariant?> _findVariantByCode(String input) async {
    final String query = input.trim();
    if (query.isEmpty) {
      return null;
    }
    final String normalized = query.toLowerCase();
    try {
      final List<ProductSearchResult> searchResults =
          await _catalogRepository.searchProducts(q: query, limit: 25);
      for (final ProductSearchResult result in searchResults) {
        final ProductVariant candidate = result.variant;
        final String? barcode = candidate.barcode?.toLowerCase();
        if (barcode != null && barcode == normalized) {
          return candidate;
        }
        final String sku = result.product.sku.toLowerCase();
        if (sku == normalized) {
          return candidate;
        }
      }

      final List<Product> products = await _catalogRepository.fetchProducts();
      for (final Product product in products) {
        if (product.sku.toLowerCase() == normalized) {
          return product.variants.isNotEmpty ? product.variants.first : null;
        }
        for (final ProductVariant variant in product.variants) {
          final String? barcode = variant.barcode?.toLowerCase();
          if (barcode != null && barcode == normalized) {
            return variant;
          }
        }
      }
    } catch (_) {
      // Swallow and return null to allow graceful error messaging upstream.
    }
    return null;
  }

  Future<void> addToCart(
    ProductVariant variant, {
    double qty = 1,
  }) async {
    await addVariant(variant, qty: qty);
  }

  Future<String> ensureDraftOrder() => _ensureDraftOrder();

  Future<String> ensureOpenDraft() async {
    state = state.copyWith(isLoading: true);
    try {
      final String draftId = await _ordersRepository.createDraftIfMissing();
      state = CartState(draftOrderId: draftId, isLoading: false);
      return draftId;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateLineQty(String lineId, double qty) async {
    final String? orderId = state.draftOrderId;
    if (orderId == null || orderId.isEmpty) {
      throw StateError('Draft order not ready');
    }
    if (qty <= 0) {
      await deleteLine(lineId);
      return;
    }
    await _ordersRepository.updateLineQty(orderItemId: lineId, qty: qty);
    _ref.invalidate(cartLinesProvider(orderId));
  }

  Future<void> deleteLine(String lineId) async {
    final String? orderId = state.draftOrderId;
    if (orderId == null || orderId.isEmpty) {
      return;
    }
    await _ordersRepository.deleteLine(orderItemId: lineId);
    _ref.invalidate(cartLinesProvider(orderId));
  }

  void clear() {
    state = const CartState();
  }

  Future<String> submitCurrentDraft() async {
    final String orderId = await _ensureDraftOrder();
    final String submittedId =
        await _ordersRepository.submitDraftOrder(orderId);
    _ref.invalidate(cartLinesProvider(orderId));
    clear();
    return submittedId;
  }

  Future<String> submitDraftAndNavigate(BuildContext context) async {
    final GoRouter? router = GoRouter.maybeOf(context);
    PostgrestException? lastPostgrest;

    for (int attempt = 0; attempt < 2; attempt++) {
      final bool isRetry = attempt > 0;
      final String? draftId = state.draftOrderId;

      print(
          '[CART] submit start draft=$draftId | retry=$isRetry | result=pending');

      try {
        final String submittedId = await submitCurrentDraft();
        print(
          '[CART] submit start draft=$draftId | retry=$isRetry | result=$submittedId',
        );
        try {
          router?.go('/customer/orders/$submittedId');
        } catch (_) {
          // No navigation available; ignore.
        }
        return submittedId;
      } on PostgrestException catch (error) {
        final String raw = <String?>[
          error.message,
          error.hint,
          error.details?.toString(),
          error.code,
        ].whereType<String>().join(' ').trim();
        final String message =
            (raw.isEmpty ? error.toString() : raw).replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
        print(
          '[CART] submit start draft=$draftId | retry=$isRetry | result=error:$message',
        );
        final String normalized = message.toLowerCase();
        if (!normalized.contains('not draft')) {
          rethrow;
        }
        if (isRetry) {
          rethrow;
        }
        lastPostgrest = error;
        await ensureOpenDraft();
        continue;
      }
    }

    throw lastPostgrest ?? StateError('Failed to submit draft order');
  }
}
