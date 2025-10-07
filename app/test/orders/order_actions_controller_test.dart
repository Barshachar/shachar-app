import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';

class _MockOrdersRepository extends Mock implements OrdersRepository {}

class _MockCatalogRepository extends Mock implements CatalogRepository {}

void main() {
  late _MockOrdersRepository ordersRepository;
  late _MockCatalogRepository catalogRepository;
  late ProviderContainer container;

  const orderId = 'order-123';
  final sampleDetail = OrderDetail(
    id: orderId,
    orderNumber: '1001',
    status: 'submitted',
    subtotal: 100,
    tax: 17,
    total: 117,
    createdAt: DateTime(2024, 1, 1),
    items: [
      OrderItem(
        variantId: 'variant-a',
        vendorCompanyId: 'vendor-1',
        qty: 2,
        unitPrice: 10,
        lineTotal: 20,
        productName: 'Product A',
        variantSku: 'SKU-A',
      ),
      OrderItem(
        variantId: 'variant-b',
        vendorCompanyId: 'vendor-2',
        qty: 1,
        unitPrice: 50,
        lineTotal: 50,
        productName: 'Product B',
        variantSku: 'SKU-B',
      ),
    ],
    shipments: const [],
  );

  Product productWithVariants({
    required String productId,
    required List<ProductVariant> variants,
    bool active = true,
  }) {
    return Product(
      id: productId,
      vendorCompanyId: 'vendor-$productId',
      sku: 'SKU-$productId',
      nameHe: 'שם',
      nameEn: 'Name',
      active: active,
      uom: 'EA',
      packSize: 1,
      moq: 1,
      leadTime: 1,
      variants: variants,
    );
  }

  ProductVariant buildVariant(String id, {bool active = true}) {
    return ProductVariant(
      id: id,
      productId: 'product-$id',
      attributes: const <String, dynamic>{},
      active: active,
      uom: 'EA',
    );
  }

  setUp(() {
    ordersRepository = _MockOrdersRepository();
    catalogRepository = _MockCatalogRepository();
    container = ProviderContainer(overrides: [
      ordersRepositoryProvider.overrideWithValue(ordersRepository),
      catalogRepositoryProvider.overrideWithValue(catalogRepository),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  test('reorderOrder copies all eligible lines and submits draft', () async {
    when(() => ordersRepository.getOrder(orderId))
        .thenAnswer((_) async => sampleDetail);
    when(() => catalogRepository.fetchProducts()).thenAnswer((_) async => [
          productWithVariants(
            productId: 'product-1',
            variants: [
              buildVariant('variant-a'),
              buildVariant('variant-b'),
            ],
          ),
        ]);
    when(() => ordersRepository.createDraftIfMissing())
        .thenAnswer((_) async => 'draft-1');
    when(() => ordersRepository.addLineToOrder(
        orderId: any(named: 'orderId'),
        variantId: any(named: 'variantId'),
        qty: any(named: 'qty'))).thenAnswer((_) async {});
    when(() => ordersRepository.submitDraftOrder('draft-1'))
        .thenAnswer((_) async => 'new-order');

    final controller = container.read(orderActionsControllerProvider);
    final result = await controller.reorderOrder(orderId);

    expect(result, 'new-order');
    verify(() => ordersRepository.createDraftIfMissing()).called(1);
    verify(() => ordersRepository.addLineToOrder(
          orderId: 'draft-1',
          variantId: 'variant-a',
          qty: 2,
        )).called(1);
    verify(() => ordersRepository.addLineToOrder(
          orderId: 'draft-1',
          variantId: 'variant-b',
          qty: 1,
        )).called(1);
    verify(() => ordersRepository.submitDraftOrder('draft-1')).called(1);
  });

  test('reorderOrder skips inactive variants but still submits', () async {
    when(() => ordersRepository.getOrder(orderId))
        .thenAnswer((_) async => sampleDetail);
    when(() => catalogRepository.fetchProducts()).thenAnswer((_) async => [
          productWithVariants(
            productId: 'product-1',
            variants: [
              buildVariant('variant-a'),
              buildVariant('variant-b', active: false),
            ],
          ),
        ]);
    when(() => ordersRepository.createDraftIfMissing())
        .thenAnswer((_) async => 'draft-1');
    final capturedVariants = <String>[];
    when(() => ordersRepository.addLineToOrder(
          orderId: any(named: 'orderId'),
          variantId: any(named: 'variantId'),
          qty: any(named: 'qty'),
        )).thenAnswer((invocation) async {
      final variant = invocation.namedArguments[#variantId] as String;
      capturedVariants.add(variant);
    });
    when(() => ordersRepository.submitDraftOrder('draft-1'))
        .thenAnswer((_) async => 'new-order');

    final controller = container.read(orderActionsControllerProvider);
    final result = await controller.reorderOrder(orderId);

    expect(result, 'new-order');
    expect(capturedVariants, ['variant-a']);
  });

  test('reorderOrder skips items with non-positive qty', () async {
    final detailWithZeroQty = OrderDetail(
      id: orderId,
      orderNumber: '1001',
      status: 'submitted',
      subtotal: 170,
      tax: 17,
      total: 187,
      createdAt: DateTime(2024, 1, 1),
      items: [
        OrderItem(
          variantId: 'variant-a',
          vendorCompanyId: 'vendor-1',
          qty: 0,
          unitPrice: 10,
          lineTotal: 0,
          productName: 'Product A',
          variantSku: 'SKU-A',
        ),
        OrderItem(
          variantId: 'variant-b',
          vendorCompanyId: 'vendor-2',
          qty: 3,
          unitPrice: 50,
          lineTotal: 150,
          productName: 'Product B',
          variantSku: 'SKU-B',
        ),
      ],
      shipments: const [],
    );

    when(() => ordersRepository.getOrder(orderId))
        .thenAnswer((_) async => detailWithZeroQty);
    when(() => catalogRepository.fetchProducts()).thenAnswer((_) async => [
          productWithVariants(
            productId: 'product-1',
            variants: [
              buildVariant('variant-a'),
              buildVariant('variant-b'),
            ],
          ),
        ]);
    when(() => ordersRepository.createDraftIfMissing())
        .thenAnswer((_) async => 'draft-1');
    when(() => ordersRepository.addLineToOrder(
          orderId: any(named: 'orderId'),
          variantId: any(named: 'variantId'),
          qty: any(named: 'qty'),
        )).thenAnswer((_) async {});
    when(() => ordersRepository.submitDraftOrder('draft-1'))
        .thenAnswer((_) async => 'new-order');

    final controller = container.read(orderActionsControllerProvider);
    final result = await controller.reorderOrder(orderId);

    expect(result, 'new-order');
    verifyNever(() => ordersRepository.addLineToOrder(
          orderId: any(named: 'orderId'),
          variantId: 'variant-a',
          qty: any(named: 'qty'),
        ));
    verify(() => ordersRepository.addLineToOrder(
          orderId: 'draft-1',
          variantId: 'variant-b',
          qty: 3,
        )).called(1);
  });

  test('reorderOrder throws when no variants are active', () async {
    when(() => ordersRepository.getOrder(orderId))
        .thenAnswer((_) async => sampleDetail);
    when(() => catalogRepository.fetchProducts())
        .thenAnswer((_) async => const <Product>[]);

    final controller = container.read(orderActionsControllerProvider);

    await expectLater(
      () => controller.reorderOrder(orderId),
      throwsA(isA<StateError>()),
    );

    verify(() => catalogRepository.fetchProducts()).called(1);
    verifyNever(() => ordersRepository.createDraftIfMissing());
    verifyNever(() => ordersRepository.submitDraftOrder(any()));
  });
}
