import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/paged_products.dart';

final catalogControllerProvider =
    AsyncNotifierProvider<CatalogController, CatalogState>(
  CatalogController.new,
);

final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  final CatalogState? state =
      ref.watch(catalogControllerProvider).asData?.value;
  return state?.items.firstWhereOrNull((Product element) => element.id == id);
});

class CatalogState {
  const CatalogState({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
    this.isLoadingMore = false,
  });

  final List<Product> items;
  final bool hasMore;
  final int nextOffset;
  final bool isLoadingMore;

  CatalogState copyWith({
    List<Product>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoadingMore,
  }) {
    return CatalogState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CatalogController extends AsyncNotifier<CatalogState> {
  static const int _defaultPageSize = 20;

  CatalogRepository get _repository => ref.watch(catalogRepositoryProvider);

  @override
  Future<CatalogState> build() async {
    final PagedProducts page = await _repository.fetchProductsPage(
      limit: _defaultPageSize,
      offset: 0,
    );
    return CatalogState(
      items: page.items,
      hasMore: page.hasMore,
      nextOffset: page.nextOffset,
    );
  }

  Future<void> refresh() async {
    final CatalogState? current = state.asData?.value;
    if (current == null) {
      state = const AsyncValue.loading();
    } else {
      state = AsyncValue.data(
        current.copyWith(isLoadingMore: false),
      );
    }

    try {
      final PagedProducts page = await _repository.fetchProductsPage(
        limit: _defaultPageSize,
        offset: 0,
        refresh: true,
      );
      state = AsyncValue.data(
        CatalogState(
          items: page.items,
          hasMore: page.hasMore,
          nextOffset: page.nextOffset,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    final CatalogState? current = state.asData?.value;
    if (current == null) {
      return;
    }
    if (!current.hasMore || current.isLoadingMore) {
      return;
    }
    state = AsyncValue.data(
      current.copyWith(isLoadingMore: true),
    );

    try {
      final PagedProducts page = await _repository.fetchProductsPage(
        limit: _defaultPageSize,
        offset: current.nextOffset,
      );
      final List<Product> merged = <Product>[...current.items, ...page.items];
      state = AsyncValue.data(
        CatalogState(
          items: merged,
          hasMore: page.hasMore,
          nextOffset: page.nextOffset,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.data(
        current.copyWith(isLoadingMore: false),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
