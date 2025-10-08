import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';

typedef FakePriceResolver = PriceResolution? Function({
  required String companyId,
  required String variantId,
  required num qty,
  DateTime? at,
});

class FakePriceResolutionService implements PriceResolutionService {
  FakePriceResolutionService({Set<String>? catalog, this.onResolve})
      : _catalog = catalog ?? const <String>{};

  final Set<String> _catalog;
  final FakePriceResolver? onResolve;

  @override
  Future<PriceResolution?> resolve({
    required String companyId,
    required String variantId,
    required num qty,
    DateTime? at,
  }) async {
    if (onResolve != null) {
      final PriceResolution? custom = onResolve!(
        companyId: companyId,
        variantId: variantId,
        qty: qty,
        at: at,
      );
      if (custom != null) {
        return custom;
      }
    }
    return PriceResolution(
      price: 12.34,
      currency: 'ILS',
      vatIncluded: true,
      source: 'contract',
      basePrice: 12.34,
    );
  }

  @override
  Future<Map<num, PriceResolution?>> resolveBreaks({
    required String companyId,
    required String variantId,
    required List<num> qtys,
    DateTime? at,
  }) async {
    final Map<num, PriceResolution?> results = <num, PriceResolution?>{};
    for (final num quantity in qtys) {
      results[quantity] = await resolve(
        companyId: companyId,
        variantId: variantId,
        qty: quantity,
        at: at,
      );
    }
    return results;
  }

  @override
  Future<Set<String>?> loadCompanyCatalog({
    required String companyId,
    DateTime? at,
  }) async {
    if (companyId.isEmpty) {
      return const <String>{};
    }
    return _catalog;
  }
}
