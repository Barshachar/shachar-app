import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';

Product _buildProduct({
  String id = 'p-1',
  String uom = 'unit',
  int packSize = 0,
  int moq = 0,
  List<ProductVariant> variants = const <ProductVariant>[],
}) {
  return Product(
    id: id,
    vendorCompanyId: 'vendor',
    sku: 'SKU-$id',
    nameHe: 'מוצר $id',
    nameEn: 'Product $id',
    active: true,
    uom: uom,
    packSize: packSize,
    moq: moq,
    leadTime: 0,
    variants: variants,
  );
}

ProductVariant _buildVariant({
  String id = 'v-1',
  Map<String, dynamic> attributes = const <String, dynamic>{},
  bool active = true,
  String uom = '',
}) {
  return ProductVariant(
    id: id,
    productId: 'p-1',
    attributes: attributes,
    barcode: null,
    active: active,
    uom: uom,
  );
}

void main() {
  group('catalogStepQuantity', () {
    test('uses explicit variant step when provided', () {
      final ProductVariant variant = _buildVariant(
        attributes: const <String, dynamic>{'step': 5},
        uom: 'unit',
      );
      final Product product = _buildProduct(
        packSize: 24,
        uom: 'carton',
        variants: <ProductVariant>[variant],
      );

      expect(catalogStepQuantity(product, variant), 5);
    });

    test('falls back to single unit for each-like uom', () {
      final Product product = _buildProduct(
        packSize: 24,
        uom: 'unit',
      );

      expect(catalogStepQuantity(product, null), 1);
    });

    test('uses pack size when uom is not each-like', () {
      final Product product = _buildProduct(
        packSize: 24,
        uom: 'carton',
      );

      expect(catalogStepQuantity(product, null), 24);
    });
  });

  group('catalogMetadataLabel', () {
    test('includes MOQ, uom, and pack size for unit products', () {
      final Product product = _buildProduct(
        uom: 'unit',
        packSize: 24,
        moq: 1,
      );

      expect(catalogMetadataLabel(product), 'MOQ 1 • unit • Pack 24');
    });

    test('prefers variant uom when available', () {
      final ProductVariant variant = _buildVariant(uom: 'Unit');
      final Product product = _buildProduct(
        uom: 'carton',
        packSize: 12,
        variants: <ProductVariant>[variant],
      );

      expect(
        catalogMetadataLabel(product, variant: variant),
        'Unit • Pack 12',
      );
    });
  });
}
