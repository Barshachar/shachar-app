import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Catalog card shows effective price and contract chip',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          priceResolutionServiceProvider.overrideWithValue(
            _FakePriceResolutionService(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: _TestCatalogCard(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const ValueKey('catalog_price_VAR-1')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('catalog_contract_chip_VAR-1')),
      findsOneWidget,
    );
  });
}

class _TestCatalogCard extends ConsumerStatefulWidget {
  const _TestCatalogCard();

  @override
  ConsumerState<_TestCatalogCard> createState() => _TestCatalogCardState();
}

class _TestCatalogCardState extends ConsumerState<_TestCatalogCard> {
  double _qty = 2;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ACard(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: ASpacing.xl,
          vertical: ASpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatalogPriceSection(
              companyId: 'COMP-1',
              variantId: 'VAR-1',
              quantity: _qty,
              label: 'price',
              loadingLabel: 'loading',
              unavailableLabel: 'n/a',
              contractTagLabel: 'contract',
              dashLabel: '—',
              sourceFormatter: (source) => source,
              atQtyLabel: 'at',
              isEnabled: true,
            ),
            const SizedBox(height: ASpacing.md),
            AQtyStepper(
              qty: _qty,
              min: 2,
              step: 1,
              enabled: true,
              onChanged: (next) {
                setState(() {
                  _qty = next.toDouble();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FakePriceResolutionService implements PriceResolutionService {
  @override
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async {
    if (variantId == 'VAR-1' && qty == 2) {
      return const PriceResolution(
        price: 19.5,
        currency: 'USD',
        vatIncluded: true,
        source: 'contract',
      );
    }
    return null;
  }

  @override
  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  }) async {
    return <num, PriceResolution?>{};
  }

  @override
  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  }) async {
    return {'VAR-1'};
  }
}
