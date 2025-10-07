import 'package:flutter/foundation.dart';

import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';

@immutable
class PagedProducts {
  const PagedProducts({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<Product> items;
  final bool hasMore;
  final int nextOffset;

  PagedProducts copyWith({
    List<Product>? items,
    bool? hasMore,
    int? nextOffset,
  }) {
    return PagedProducts(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
    );
  }
}
