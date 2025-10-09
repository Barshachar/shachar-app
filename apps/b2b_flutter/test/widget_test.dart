import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_catalog_repository.dart';
import 'fakes/fake_price_service.dart';
import 'test_harness.dart';

void main() {
  testWidgets('Catalog renders a list with fake repo',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      makeTestApp(
        const CatalogPage(),
        overrides: [
          catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
          priceResolutionServiceProvider.overrideWithValue(
            FakePriceResolutionService(
              onResolve: ({
                required String companyId,
                required String variantId,
                required num qty,
                DateTime? at,
              }) =>
                  const PriceResolution(
                price: 9.99,
                currency: '₪',
                vatIncluded: false,
                source: 'base',
              ),
            ),
          ),
        ],
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
