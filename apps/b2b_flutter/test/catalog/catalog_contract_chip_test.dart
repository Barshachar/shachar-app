import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/presentation/contract_price_badge.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePriceResolutionService implements PriceResolutionService {
  const _FakePriceResolutionService(this.result);

  final PriceResolution result;

  @override
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async =>
      result;

  @override
  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  }) async =>
      {
        for (final num quantity in qtys) quantity: result,
      };

  @override
  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  }) async =>
      {'variant-1'};
}

void main() {
  testWidgets('Catalog price section shows contract chip when price below base',
      (tester) async {
    const price = PriceResolution(
      price: 8.0,
      currency: '₪',
      vatIncluded: false,
      source: 'contract',
      basePrice: 10.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          priceResolutionServiceProvider.overrideWithValue(
            const _FakePriceResolutionService(price),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CatalogPriceSection(
              companyId: 'comp',
              variantId: 'variant-1',
              quantity: 1,
              label: 'Effective price',
              loadingLabel: '…',
              unavailableLabel: '—',
              contractTagLabel: 'Contract price',
              dashLabel: '—',
              atQtyLabel: 'at',
              sourceFormatter: (source) => source,
              isEnabled: true,
              priceOverride: const AsyncValue.data(price),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(ContractPriceBadge), findsOneWidget);
    expect(
      find.byKey(const ValueKey('catalog_contract_chip_variant-1')),
      findsOneWidget,
    );
  });
}
