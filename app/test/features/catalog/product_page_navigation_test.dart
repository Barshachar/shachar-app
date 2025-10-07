import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_controller.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_page.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import '../../test_utils/tester_view_compat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('product page shows back button and pops when tapped',
      (WidgetTester tester) async {
    await tester.setSurfaceSize(const Size(1280, 2280));
    await tester.setDevicePixelRatio(1.0);

    final ProductVariant variant = ProductVariant(
      id: 'variant-1',
      productId: 'product-1',
      attributes: const <String, dynamic>{
        'image': 'https://example.com/sample.png',
        'name': 'Variant A',
      },
      barcode: '1234567890',
      active: true,
      uom: 'unit',
    );
    final Product product = Product(
      id: 'product-1',
      vendorCompanyId: 'vendor-1',
      sku: 'SKU-1',
      nameHe: 'מוצר לדוגמה',
      nameEn: 'Sample Product',
      active: true,
      uom: 'unit',
      packSize: 1,
      moq: 1,
      leadTime: 2,
      variants: <ProductVariant>[variant],
    );

    final _TestNavigatorObserver navigatorObserver = _TestNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productByIdProvider.overrideWith(
            (ref, String id) => id == product.id ? product : null,
          ),
          priceResolutionServiceProvider
              .overrideWithValue(_FakePriceResolutionService()),
        ],
        child: MaterialApp(
          navigatorObservers: <NavigatorObserver>[navigatorObserver],
          home: _PushOnInit(
            page: ProductPage(productId: product.id),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(ProductPage), findsOneWidget);
    final Finder backIconFinder = find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.icon is BackButtonIcon,
    );
    expect(backIconFinder, findsOneWidget);

    await tester.tap(backIconFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(navigatorObserver.didPopRoute, isTrue);
    expect(find.byType(ProductPage), findsNothing);
  });

  testWidgets('product page quantity stepper allows going below MOQ',
      (WidgetTester tester) async {
    await tester.setSurfaceSize(const Size(1280, 2280));
    await tester.setDevicePixelRatio(1.0);

    final ProductVariant variant = ProductVariant(
      id: 'variant-1',
      productId: 'product-1',
      attributes: const <String, dynamic>{},
      barcode: '1234567890',
      active: true,
      uom: 'unit',
    );
    final Product product = Product(
      id: 'product-1',
      vendorCompanyId: 'vendor-1',
      sku: 'SKU-1',
      nameHe: 'מוצר לדוגמה',
      nameEn: 'Sample Product',
      active: true,
      uom: 'unit',
      packSize: 1,
      moq: 24,
      leadTime: 2,
      variants: <ProductVariant>[variant],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productByIdProvider.overrideWith(
            (ref, String id) => id == product.id ? product : null,
          ),
          priceResolutionServiceProvider
              .overrideWithValue(_FakePriceResolutionService()),
        ],
        child: MaterialApp(
          home: ProductPage(productId: product.id),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final Finder valueFinder =
        find.byKey(const ValueKey<String>('a_qty_stepper_value'));
    Text qtyText = tester.widget<Text>(valueFinder);
    expect(qtyText.data, '24');

    final Finder decrementFinder = find.byTooltip('productQtyStepperDecrease');
    expect(decrementFinder, findsOneWidget);

    for (int i = 0; i < 24; i++) {
      await tester.tap(decrementFinder);
      await tester.pump();
    }

    qtyText = tester.widget<Text>(valueFinder);
    expect(qtyText.data, '1');
    expect(find.text('productQtyErrorBelowMoq'), findsWidgets);
  });
}

class _PushOnInit extends StatefulWidget {
  const _PushOnInit({required this.page});

  final Widget page;

  @override
  State<_PushOnInit> createState() => _PushOnInitState();
}

class _PushOnInitState extends State<_PushOnInit> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => widget.page),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold();
}

class _TestNavigatorObserver extends NavigatorObserver {
  bool didPopRoute = false;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPopRoute = true;
    super.didPop(route, previousRoute);
  }
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
      price: 12.5,
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
  }) async =>
      null;
}
