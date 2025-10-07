import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_catalog_repository.dart';

void main() {
  group('FakeCatalogRepository.searchProducts', () {
    final repository = FakeCatalogRepository();

    test('returns mint product when querying mint', () async {
      final results = await repository.searchProducts(q: 'mint');

      expect(results, isNotEmpty);
      expect(
        results.any(
            (result) => result.product.nameEn.toLowerCase().contains('mint')),
        isTrue,
      );
    });

    test('applies limit and offset for pagination', () async {
      final firstBatch = await repository.searchProducts(limit: 1);
      final paged = await repository.searchProducts(limit: 1, offset: 1);

      expect(firstBatch.length, 1);
      expect(paged.length, 1);
      expect(paged.first.product.id, isNot(firstBatch.first.product.id));
    });
  });
}
