import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_catalog_repository.dart';

void main() {
  testWidgets('Catalog renders a list with fake repo',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
          priceResolutionServiceProvider
              .overrideWithValue(_FakePriceResolutionService()),
        ],
        child: const MaterialApp(home: CatalogPage()),
      ),
    );

    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(AProductImage), findsWidgets);
    expect(find.text('תה נענע'), findsOneWidget);
    expect(find.text('מוצר בדיקה'), findsOneWidget);
  });
}

class _FakePriceResolutionService implements PriceResolutionService {
  const _FakePriceResolutionService();

  @override
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async {
    return const PriceResolution(
      price: 9.99,
      currency: '₪',
      vatIncluded: false,
      source: 'base',
    );
  }

  @override
  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  }) async {
    return {
      for (final num value in qtys)
        value: await resolve(
          companyId: companyId,
          variantId: variantId,
          qty: value,
          at: at,
        ),
    };
  }

  @override
  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  }) async {
    return null;
  }
}
