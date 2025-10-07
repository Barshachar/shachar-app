import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_controller.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:ashachar_marketplace/src/features/pricing/presentation/price_quote_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Product page renders price break rows with provided data',
      (tester) async {
    const productId = 'product-1';
    final product = Product(
      id: productId,
      vendorCompanyId: 'vendor-1',
      sku: 'SKU-1',
      nameHe: 'מוצר בדיקה',
      nameEn: 'Sample Product',
      active: true,
      uom: 'unit',
      packSize: 1,
      moq: 2,
      leadTime: 3,
      variants: [
        ProductVariant(
          id: 'variant-1',
          productId: productId,
          attributes: const <String, dynamic>{},
          barcode: '123',
          active: true,
          uom: 'unit',
        ),
      ],
    );

    final Map<int, PriceResolution?> fakeBreaks = <int, PriceResolution?>{
      2: const PriceResolution(
        price: 12,
        currency: '₪',
        vatIncluded: false,
        source: 'base',
      ),
      4: const PriceResolution(
        price: 22,
        currency: '₪',
        vatIncluded: false,
        source: 'base',
      ),
      10: const PriceResolution(
        price: 50,
        currency: '₪',
        vatIncluded: false,
        source: 'contract',
        basePrice: 60,
      ),
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productByIdProvider.overrideWith(
            (ref, id) => product,
          ),
          priceBreaksProvider.overrideWith(
            (ref, request) async => fakeBreaks,
          ),
          priceResolutionProvider.overrideWith(
            (ref, request) async => const PriceResolution(
              price: 19.5,
              currency: '₪',
              vatIncluded: false,
              source: 'contract',
              basePrice: 25,
            ),
          ),
        ],
        child: MaterialApp(
          home: const ProductPage(productId: productId),
        ),
      ),
    );

    await tester.pump();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const ValueKey('price_breaks_table')), findsOneWidget);
    expect(find.byKey(const ValueKey('price_break_qty_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('price_break_price_2')), findsOneWidget);
    expect(find.byKey(const ValueKey('price_break_price_10')), findsOneWidget);
  });
}
