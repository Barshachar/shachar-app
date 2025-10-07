// ignore_for_file: use_build_context_synchronously

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_controller.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_media_utils.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/pricing/domain/resolved_price.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart'
    show PriceResolution, priceResolutionServiceProvider;
import 'package:ashachar_marketplace/src/features/pricing/presentation/contract_price_badge.dart';
import 'package:ashachar_marketplace/src/features/pricing/presentation/price_quote_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const List<String> _caseUnitAttributeKeys = <String>[
  'casesize',
  'caseqty',
  'casequantity',
  'casepack',
  'packsize',
  'packqty',
  'unitspercase',
  'unitspercarton',
  'piecespercase',
  'cartonqty',
  'innerpack',
];

const List<String> _palletUnitAttributeKeys = <String>[
  'palletsize',
  'palletqty',
  'palletquantity',
  'unitsperpallet',
  'unitperpallet',
  'piecesperpallet',
  'pcsperpallet',
  'eachesperpallet',
];

const List<String> _palletCaseAttributeKeys = <String>[
  'casesperpallet',
  'caseperpallet',
  'cartonsperpallet',
  'cartonperpallet',
  'boxesperpallet',
  'caseperplt',
];

String _qKey(num quantity) {
  final double value = quantity.toDouble();
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}

class PriceBreakRequest {
  const PriceBreakRequest({
    required this.companyId,
    required this.variantId,
    required this.quantities,
  });

  final String companyId;
  final String variantId;
  final List<int> quantities;
}

final companyCatalogProvider = FutureProvider.autoDispose
    .family<Set<String>?, String>((ref, companyId) async {
  final svc = ref.watch(priceResolutionServiceProvider);
  try {
    return await svc.loadCompanyCatalog(companyId: companyId);
  } catch (_) {
    return null; // כשל רשת/אין סשן → לא מציגים באנר
  }
});

final priceBreaksProvider = FutureProvider.autoDispose
    .family<Map<int, PriceResolution?>, PriceBreakRequest>(
        (ref, request) async {
  final service = ref.watch(priceResolutionServiceProvider);
  final Map<num, PriceResolution?> resolved = await service.resolveBreaks(
    companyId: request.companyId,
    variantId: request.variantId,
    qtys: request.quantities,
  );
  return {
    for (final int qty in request.quantities) qty: resolved[qty],
  };
});

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  String? _selectedVariantId;
  int _selectedImageIndex = 0;
  double _selectedQuantity = 1;
  String? _quantityProductId;
  bool _isAddingToCart = false;
  _OrderUom _selectedOrderUom = _OrderUom.unit;
  final Map<String, String> _selectedWarehouseByVariant = <String, String>{};

  String _currentCompanyId(WidgetRef ref) {
    bool supabaseReady = false;
    try {
      Supabase.instance;
      supabaseReady = true;
    } catch (_) {}
    if (!supabaseReady) {
      return 'mock-company';
    }
    try {
      final AsyncValue<Session?> sessionState =
          ref.read(sessionControllerProvider);
      final Session? session = sessionState.asData?.value;
      final Object? meta = session?.user.appMetadata['company_id'];
      if (meta is String && meta.isNotEmpty) {
        return meta;
      }
    } catch (_) {
      // Session provider may be absent in widget tests; treat as anonymous.
    }
    return '';
  }

  MarketplaceLocalizations? get _l10n =>
      Localizations.of<MarketplaceLocalizations>(
        context,
        MarketplaceLocalizations,
      );

  String _t(String key) => _l10n?.translate(key) ?? key;

  double _defaultQuantity(Product product, double step) {
    final double normalizedStep = step <= 0 ? 1 : step;
    final double base =
        product.moq > 0 ? product.moq.toDouble() : normalizedStep;
    return _ceilToStep(base, normalizedStep);
  }

  void _syncQuantitySeed(Product product, double step) {
    final double defaultQty = _defaultQuantity(product, step);
    if (_quantityProductId != product.id) {
      _selectedOrderUom = _OrderUom.unit;
      _selectedQuantity = defaultQty;
      _quantityProductId = product.id;
      return;
    }

    if (_selectedQuantity <= 0) {
      _selectedQuantity = step <= 0 ? 1 : step;
      return;
    }

    if (!_isMultipleOfStep(_selectedQuantity, step)) {
      _selectedQuantity = _ceilToStep(_selectedQuantity, step);
    }
  }

  String _quantityMeta(Product product) {
    final List<String> parts = <String>[];
    if (product.moq > 0) {
      parts.add('MOQ ${product.moq}');
    }
    if (product.packSize > 0) {
      parts.add('Pack ${product.packSize} ${product.uom}');
    } else if (product.uom.isNotEmpty) {
      parts.add(product.uom);
    }
    return parts.join(' • ');
  }

  Future<PriceResolution?> _tryResolvePrice(
    String companyId,
    String variantId,
    int quantity,
  ) async {
    try {
      return await ref.read(priceResolutionProvider(PriceQuoteRequest(
        companyId: companyId,
        variantId: variantId,
        quantity: quantity <= 0 ? 1 : quantity,
      )).future);
    } catch (_) {
      return null;
    }
  }

  String _pricingSourceLabel(String source) {
    final PriceSource mapped = priceSourceFromString(source);
    switch (source.toLowerCase()) {
      case 'contract':
      case 'contract_price':
      case 'contract_price_list':
      case 'contract_price_list_v2':
        return _t('pricingSourceContract');
      case 'price_list':
      case 'pricelist':
      case 'list':
        return _t('pricingSourcePriceList');
      case 'base':
      case 'base_price':
      case 'standard':
        return _t('pricingSourceBase');
      default:
        switch (mapped) {
          case PriceSource.contract:
            return _t('pricingSourceContract');
          case PriceSource.priceList:
            return _t('pricingSourcePriceList');
          case PriceSource.base:
            return _t('pricingSourceBase');
          case PriceSource.fallback:
            return _t('pricingSourceFallback');
        }
    }
  }

  String _formatAddToCartSuccess(PriceResolution? price) {
    final String base = _t('productAddedToDraft');
    if (price == null) {
      return base;
    }
    final String sourceLabel = _pricingSourceLabel(price.source).trim();
    if (sourceLabel.isEmpty) {
      return base;
    }
    return '$base • $sourceLabel';
  }

  Map<String, dynamic> _normalizeVariantAttributes(ProductVariant variant) {
    final Map<String, dynamic> normalized = <String, dynamic>{};
    variant.attributes.forEach((dynamic key, dynamic value) {
      final String raw = key.toString();
      if (raw.isEmpty) {
        return;
      }
      final String lower = raw.trim().toLowerCase();
      if (lower.isNotEmpty) {
        normalized[lower] = value;
        final String collapsed = lower.replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (collapsed.isNotEmpty) {
          normalized.putIfAbsent(collapsed, () => value);
        }
      }
    });
    return normalized;
  }

  int? _tryParsePositiveInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is num) {
      final int asInt = value.toInt();
      return asInt > 0 ? asInt : null;
    }
    final String? raw = _asString(value)?.replaceAll(',', '').trim();
    if (raw == null || raw.isEmpty) return null;
    final double? parsed = double.tryParse(raw);
    if (parsed == null) {
      return null;
    }
    if (parsed <= 0) {
      return null;
    }
    final int candidate = parsed.round();
    if ((parsed - candidate).abs() > 1e-3) {
      return null;
    }
    return candidate > 0 ? candidate : null;
  }

  int? _firstPositiveInt(
    Map<String, dynamic> attributes,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = attributes[key];
      final int? parsed = _tryParsePositiveInt(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }

  List<_OrderUomOption> _buildUomOptions(
    Product product,
    ProductVariant variant,
  ) {
    final Map<String, dynamic> attributes =
        _normalizeVariantAttributes(variant);
    final int? caseUnits =
        _firstPositiveInt(attributes, _caseUnitAttributeKeys) ??
            (product.packSize > 0 ? product.packSize : null);
    final int? casesPerPallet =
        _firstPositiveInt(attributes, _palletCaseAttributeKeys);
    int? palletUnits = _firstPositiveInt(attributes, _palletUnitAttributeKeys);
    if (palletUnits == null && casesPerPallet != null) {
      final int? resolvedCaseUnits =
          caseUnits ?? (product.packSize > 0 ? product.packSize : null);
      if (resolvedCaseUnits != null) {
        palletUnits = resolvedCaseUnits * casesPerPallet;
      }
    }

    return <_OrderUomOption>[
      const _OrderUomOption(type: _OrderUom.unit, unitsPerSelection: 1),
      _OrderUomOption(
        type: _OrderUom.casePack,
        unitsPerSelection: caseUnits,
      ),
      _OrderUomOption(
        type: _OrderUom.pallet,
        unitsPerSelection: palletUnits,
        casesPerSelection: casesPerPallet,
      ),
    ];
  }

  _OrderUomOption _resolveOptionSelection(
    List<_OrderUomOption> options, {
    _OrderUom? preferred,
  }) {
    final Iterable<_OrderUomOption> enabled =
        options.where((option) => option.isEnabled);
    if (enabled.isEmpty) {
      return options.first;
    }
    if (preferred != null) {
      for (final _OrderUomOption option in enabled) {
        if (option.type == preferred) {
          return option;
        }
      }
    }
    return enabled.first;
  }

  double _ceilToStep(double value, double step) {
    final double normalizedStep = step <= 0 ? 1 : step;
    if (value <= 0) {
      return normalizedStep;
    }
    final int stepInt = normalizedStep.round();
    if (stepInt <= 0) {
      return normalizedStep;
    }
    final int valueInt = value.ceil();
    final int remainder = valueInt % stepInt;
    if (remainder == 0) {
      return valueInt.toDouble();
    }
    return (valueInt + (stepInt - remainder)).toDouble();
  }

  bool _isMultipleOfStep(double value, double step) {
    final double normalizedStep = step <= 0 ? 1 : step;
    final int stepInt = normalizedStep.round();
    if (stepInt <= 0) {
      return true;
    }
    final int valueInt = value.round();
    return valueInt % stepInt == 0;
  }

  String _resolveBaseUom(Product product, ProductVariant variant) {
    if (product.uom.isNotEmpty) {
      return product.uom;
    }
    if (variant.uom.isNotEmpty) {
      return variant.uom;
    }
    return _t('productQtyUomUnit');
  }

  String _formatUnits(int? units, String baseUom, NumberFormat format) {
    if (units == null || units <= 0) {
      return '—';
    }
    return '${format.format(units)} $baseUom';
  }

  String _buildOptionDetail(
    _OrderUomOption option,
    NumberFormat qtyFormat,
    String baseUom,
  ) {
    switch (option.type) {
      case _OrderUom.unit:
        return _t('productQtyUomUnitDetail').replaceAll('{uom}', baseUom);
      case _OrderUom.casePack:
        final int? units = option.unitsPerSelection;
        if (units == null || units <= 0) {
          return _t('productQtyUomCaseUnavailable');
        }
        return _t('productQtyUomCaseDetail')
            .replaceAll('{count}', qtyFormat.format(units))
            .replaceAll('{uom}', baseUom);
      case _OrderUom.pallet:
        final int? units = option.unitsPerSelection;
        if (units == null || units <= 0) {
          return _t('productQtyUomPalletUnavailable');
        }
        final String base = _t('productQtyUomPalletDetail')
            .replaceAll('{count}', qtyFormat.format(units))
            .replaceAll('{uom}', baseUom);
        final int? cases = option.casesPerSelection;
        if (cases != null && cases > 0) {
          final String suffix = _t('productQtyUomPalletCasesSuffix')
              .replaceAll('{cases}', qtyFormat.format(cases));
          return '$base $suffix';
        }
        return base;
    }
  }

  List<int> _priceBreakQuantities(
    Product product,
    _OrderUomOption option,
  ) {
    final int multiplier = option.unitsPerSelection ?? 1;
    final Iterable<int> baseBreaks = product.moq > 0
        ? <int>[product.moq, product.moq * 2, product.moq * 5]
        : const <int>[1, 2, 5];
    final LinkedHashSet<int> quantities = LinkedHashSet<int>();
    for (final int base in baseBreaks) {
      final int scaled = (base * multiplier).clamp(1, 1 << 20);
      quantities.add(scaled);
    }
    return quantities.toList();
  }

  List<_WarehouseOption> _warehouseOptions(
    Product product,
    ProductVariant variant,
  ) {
    final List<_WarehouseOption> options = <_WarehouseOption>[];
    final dynamic rawWarehouses = variant.attributes['warehouses'] ??
        variant.attributes['warehouseAvailability'] ??
        variant.attributes['availability'] ??
        variant.attributes['inventory_sites'];

    if (rawWarehouses is List) {
      for (final dynamic entry in rawWarehouses) {
        final Map<String, dynamic> data = _asMap(entry);
        final String? id = _asString(data['id']) ?? _asString(data['code']);
        if (id == null || id.isEmpty) {
          continue;
        }
        final String name = _asString(data['name']) ??
            _asString(data['label']) ??
            _t('productWarehousePrimary');
        options.add(
          _WarehouseOption(
            id: id,
            name: name.isNotEmpty ? name : _t('productWarehousePrimary'),
            quantity: _asDouble(data['qty'] ?? data['quantity']),
            etaDays: _asInt(
              data['eta_days'] ??
                  data['etaDays'] ??
                  data['lead_time_days'] ??
                  data['leadTimeDays'],
            ),
          ),
        );
      }
    } else if (rawWarehouses is Map) {
      rawWarehouses.forEach((key, value) {
        final Map<String, dynamic> data = _asMap(value);
        final String resolvedId =
            _asString(data['id']) ?? _asString(key) ?? key.toString();
        final String name = _asString(data['name']) ??
            _asString(data['label']) ??
            _t('productWarehousePrimary');
        options.add(
          _WarehouseOption(
            id: resolvedId,
            name: name.isNotEmpty ? name : _t('productWarehousePrimary'),
            quantity: _asDouble(data['qty'] ?? data['quantity']),
            etaDays: _asInt(
              data['eta_days'] ??
                  data['etaDays'] ??
                  data['lead_time_days'] ??
                  data['leadTimeDays'],
            ),
          ),
        );
      });
    }

    if (options.isEmpty) {
      final double? aggregateQty = _asDouble(
        variant.attributes['aggregate_qty'] ??
            variant.attributes['aggregateQty'] ??
            variant.attributes['inventory_qty'] ??
            variant.attributes['inventoryQty'],
      );
      final int? aggregateEta = _asInt(
        variant.attributes['lead_time_days'] ??
            variant.attributes['leadTimeDays'],
      );
      final int? fallbackEta = (aggregateEta != null && aggregateEta > 0)
          ? aggregateEta
          : (product.leadTime > 0 ? product.leadTime : null);
      options.add(
        _WarehouseOption(
          id: _WarehouseOption.primaryId,
          name: _t('productWarehousePrimary'),
          quantity: aggregateQty,
          etaDays: fallbackEta,
        ),
      );
    } else {
      final int fallback = product.leadTime;
      if (fallback > 0) {
        for (int index = 0; index < options.length; index++) {
          final _WarehouseOption option = options[index];
          if (option.etaDays == null || option.etaDays! <= 0) {
            options[index] = option.copyWith(etaDays: fallback);
          }
        }
      }
    }

    return options;
  }

  List<_WarehouseDisplayData> _buildWarehouseDisplayData(
    List<_WarehouseOption> options,
  ) {
    return options
        .map(
          (option) => _WarehouseDisplayData(
            id: option.id,
            title: option.name,
            quantityLabel: _formatWarehouseQuantityLabel(option.quantity),
            leadTimeLabel: _formatLeadTimeLabel(option.etaDays),
          ),
        )
        .toList();
  }

  Future<void> _presentWarehouseSelector({
    required ProductVariant variant,
    required List<_WarehouseDisplayData> displayOptions,
    required String? selectedId,
  }) async {
    final Widget sheet = _WarehouseSelectionSheet(
      translate: _t,
      options: displayOptions,
      selectedId: selectedId,
    );
    final bool preferDialog =
        kIsWeb || MediaQuery.of(context).size.width >= 640;
    final String? result = preferDialog
        ? await showDialog<String>(
            context: context,
            builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(ASpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: sheet,
              ),
            ),
          )
        : await showModalBottomSheet<String>(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => sheet,
          );

    if (!mounted || result == null) {
      return;
    }
    final bool exists = displayOptions.any((option) => option.id == result);
    if (!exists) {
      return;
    }
    setState(() {
      _selectedWarehouseByVariant[variant.id] = result;
    });
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String _formatWarehouseQuantityValue(double? qty) {
    if (qty == null) {
      return _t('productWarehouseQtyUnknown');
    }
    final double abs = qty;
    if ((abs - abs.round()).abs() < 1e-6) {
      return abs.toStringAsFixed(0);
    }
    return abs.toStringAsFixed(2);
  }

  String _formatWarehouseQuantityLabel(double? qty) {
    final String label = _t('productWarehouseQtyLabel');
    final String value = _formatWarehouseQuantityValue(qty);
    return '$label: $value';
  }

  String _formatLeadTimeValue(int? days, {String? unknownValue}) {
    if (days == null || days <= 0) {
      return unknownValue ?? _t('productWarehouseLeadTimeUnknown');
    }
    final String unit = _t('productSpecsLeadTimeUnit');
    return '$days $unit';
  }

  String _formatLeadTimeLabel(int? days, {String? unknownValue}) {
    final String label = _t('productWarehouseLeadTimeLabel');
    final String value = _formatLeadTimeValue(days, unknownValue: unknownValue);
    return '$label: $value';
  }

  Future<void> _addVariantToCart(
    Product product,
    ProductVariant variant,
  ) async {
    if (_isAddingToCart) {
      return;
    }
    final List<_OrderUomOption> options = _buildUomOptions(product, variant);
    final _OrderUomOption selectedOption =
        _resolveOptionSelection(options, preferred: _selectedOrderUom);
    final double step = selectedOption.step;
    final double minQty = _defaultQuantity(product, step);
    final double alignedQty = _isMultipleOfStep(_selectedQuantity, step)
        ? _selectedQuantity
        : _ceilToStep(_selectedQuantity, step);
    final double qty = alignedQty < minQty ? minQty : alignedQty;
    final bool meetsMoq = product.moq <= 0 || qty >= product.moq;
    final bool matchesStep = _isMultipleOfStep(qty, step);
    if (!meetsMoq || !matchesStep) {
      return;
    }
    final cart = ref.read(cartControllerProvider.notifier);
    final int requestQty = qty <= 0 ? 1 : qty.round();
    final String companyId = _currentCompanyId(ref);
    PriceResolution? resolvedPrice;
    setState(() => _isAddingToCart = true);
    try {
      resolvedPrice = await _tryResolvePrice(companyId, variant.id, requestQty);
      await cart.addVariant(variant, qty: qty);
      if (!mounted) return;
      final cartState = ref.read(cartControllerProvider);
      final String? draftId = cartState.draftOrderId;
      ref.invalidate(cartControllerProvider);
      if (draftId != null) {
        ref.invalidate(cartLinesProvider(draftId));
      }
      final String successMessage = _formatAddToCartSuccess(resolvedPrice);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_t('productAddFailed')}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product? product = ref.watch(productByIdProvider(widget.productId));
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_t('productSpecsTitle'))),
        body: Center(child: Text(_t('productNotFound'))),
      );
    }
    final String companyId = _currentCompanyId(ref);
    final AsyncValue<Set<String>?> catalogAsync = (companyId.isEmpty)
        ? const AsyncValue<Set<String>?>.data(null)
        : ref.watch(companyCatalogProvider(companyId));

    final List<ProductVariant> allVariants =
        product.variants.where((v) => v.active).toList();
    final List<ProductVariant> displayVariants =
        allVariants.isNotEmpty ? allVariants : product.variants;
    if (displayVariants.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(product.nameHe)),
        body: Center(child: Text(_t('productNotFound'))),
      );
    }

    final ProductVariant selectedVariant = displayVariants.firstWhere(
      (variant) => variant.id == _selectedVariantId,
      orElse: () => displayVariants.first,
    );

    final bool productNotInCatalog = catalogAsync.maybeWhen(
      data: (set) =>
          companyId.isNotEmpty &&
          set != null &&
          selectedVariant.id.isNotEmpty &&
          !set.contains(selectedVariant.id),
      orElse: () => false,
    );
    final bool variantAllowed = !productNotInCatalog;
    final bool showNotInCatalogBanner = productNotInCatalog;

    final List<String> imageUrls = collectProductImages(
      product,
      primaryVariant: selectedVariant,
    );
    int heroImageIndex = _selectedImageIndex;
    if (imageUrls.isEmpty) {
      heroImageIndex = 0;
    } else if (heroImageIndex >= imageUrls.length || heroImageIndex < 0) {
      heroImageIndex = 0;
    }

    final Map<String, String> attributes =
        extractDisplayAttributes(selectedVariant);

    final String skuLabel = _t('productSkuLabel');
    final String galleryTitle = _t('productGalleryTitle');
    final String variantsTitle = _t('productVariantsTitle');
    final String specsTitle = _t('productSpecsTitle');
    final String attributesTitle = _t('productAttributesTitle');
    final String addToCartLabel = _t('catalogSearchAddToCart');
    final String uomLabel = _t('productSpecsUom');
    final String moqLabel = _t('productSpecsMoq');
    final String leadTimeLabel = _t('productSpecsLeadTime');
    final String leadTimeUnit = _t('productSpecsLeadTimeUnit');
    final String unknownValue = _t('productSpecsUnknown');

    final List<_WarehouseOption> warehouseOptions =
        _warehouseOptions(product, selectedVariant);
    final String? storedWarehouseId =
        _selectedWarehouseByVariant[selectedVariant.id];
    _WarehouseOption? selectedWarehouse;
    if (storedWarehouseId != null) {
      for (final _WarehouseOption option in warehouseOptions) {
        if (option.id == storedWarehouseId) {
          selectedWarehouse = option;
          break;
        }
      }
    }
    selectedWarehouse ??=
        warehouseOptions.isNotEmpty ? warehouseOptions.first : null;
    final bool storedWarehouseExists = storedWarehouseId != null &&
        warehouseOptions.any((option) => option.id == storedWarehouseId);
    final String? highlightedWarehouseId =
        storedWarehouseExists ? storedWarehouseId : selectedWarehouse?.id;
    final List<_WarehouseDisplayData> warehouseDisplayOptions =
        _buildWarehouseDisplayData(warehouseOptions);
    final int? resolvedLeadTimeDays = selectedWarehouse?.etaDays ??
        (product.leadTime > 0 ? product.leadTime : null);
    final String leadTimeValue = resolvedLeadTimeDays != null
        ? '$resolvedLeadTimeDays $leadTimeUnit'
        : unknownValue;
    final String warehouseName =
        selectedWarehouse?.name ?? _t('productWarehousePrimary');
    final String warehouseQtyLabel =
        _formatWarehouseQuantityLabel(selectedWarehouse?.quantity);
    final String warehouseLeadTimeLabel = _formatLeadTimeLabel(
      resolvedLeadTimeDays,
      unknownValue: unknownValue,
    );
    final String selectWarehouseLabel = _t('productSelectWarehouse');

    final String mainImageUrl = imageUrls.isNotEmpty
        ? imageUrls[heroImageIndex]
        : resolvePrimaryImage(
              product,
              variant: selectedVariant,
            ) ??
            '';

    final List<_OrderUomOption> uomOptions =
        _buildUomOptions(product, selectedVariant);
    final _OrderUomOption selectedUomOption =
        _resolveOptionSelection(uomOptions, preferred: _selectedOrderUom);
    _selectedOrderUom = selectedUomOption.type;

    final double stepValue = selectedUomOption.step;
    _syncQuantitySeed(product, stepValue);

    final double minStepperQuantity = stepValue > 0 ? stepValue : 1;
    if (_selectedQuantity < minStepperQuantity) {
      _selectedQuantity = minStepperQuantity;
    }

    final Locale locale = Localizations.localeOf(context);
    final NumberFormat qtyFormat =
        NumberFormat.decimalPattern(locale.toString());

    final String baseUomLabel = _resolveBaseUom(product, selectedVariant);
    final String quantityMeta = _quantityMeta(product);
    final String selectedUomDetail =
        _buildOptionDetail(selectedUomOption, qtyFormat, baseUomLabel);
    final String moqValueDisplay = product.moq > 0
        ? _formatUnits(product.moq, baseUomLabel, qtyFormat)
        : '—';
    final int unitsPerSelection = selectedUomOption.unitsPerSelection ?? 1;
    final int stepUnits = unitsPerSelection;
    final String stepValueDisplay =
        _formatUnits(stepUnits, baseUomLabel, qtyFormat);
    final List<int> priceBreakQuantities =
        _priceBreakQuantities(product, selectedUomOption);
    final double rawEffective =
        _selectedQuantity > 0 ? _selectedQuantity : minStepperQuantity;
    final int effectivePriceQuantity =
        (rawEffective * unitsPerSelection).round().clamp(1, 1 << 24);

    final List<String> quantityErrors = <String>[];
    if (product.moq > 0 && _selectedQuantity < product.moq) {
      final String template = _t('productQtyErrorBelowMoq');
      quantityErrors.add(
        template.replaceAll(
          '{moq}',
          _formatUnits(product.moq, baseUomLabel, qtyFormat),
        ),
      );
    }
    if (!_isMultipleOfStep(_selectedQuantity, stepValue)) {
      final String template = _t('productQtyErrorStep');
      quantityErrors.add(
        template.replaceAll('{step}', stepValueDisplay),
      );
    }
    final bool isQuantityValid = quantityErrors.isEmpty;
    final String quantityHeading = _t('productQtyHeading');
    final String uomSelectorLabel = _t('productQtyUomLabel');
    final String moqSummaryLabel = _t('productQtyMoqLabel');
    final String stepSummaryLabel = _t('productQtyStepLabel');
    final String stepperSemanticLabel = _t('productQtyStepperSemantic');
    final String stepperIncreaseTooltip = _t('productQtyStepperIncrease');
    final String stepperDecreaseTooltip = _t('productQtyStepperDecrease');
    final String uomUnavailableTooltip = _t('productQtyUomUnavailableTooltip');
    final String priceBreaksLabel = _t('priceBreaks');
    final String priceBreakQtyLabel = _t('productPriceBreaksQty');
    final String priceBreakPriceLabel = _t('productPriceBreaksPrice');
    final String priceBreakLoadingLabel = _t('productPriceBreaksLoading');
    final String dashLabel = _t('dash');
    final String atQtyLabel = _t('atQty');
    final String priceBreakUnavailableLabel = dashLabel;
    final String effectivePriceLabel = _t('productEffectivePriceLabel');
    final String effectivePriceLoading = _t('productEffectivePriceLoading');
    final String effectivePriceUnavailable =
        _t('productEffectivePriceUnavailable');
    final String contractPriceTag = _t('contractPrice');
    final bool disableAddToCart =
        _isAddingToCart || !isQuantityValid || productNotInCatalog;
    String labelForOption(_OrderUom type) {
      switch (type) {
        case _OrderUom.unit:
          return _t('productQtyUomUnit');
        case _OrderUom.casePack:
          return _t('productQtyUomCase');
        case _OrderUom.pallet:
          return _t('productQtyUomPallet');
      }
    }

    final bool isRtl = context.isRtl;
    final TextAlign baseTextAlign = isRtl ? TextAlign.right : TextAlign.left;
    final GoRouter? router = GoRouter.maybeOf(context);

    void handleBackNavigation() {
      final GoRouter? currentRouter = GoRouter.maybeOf(context);
      if (currentRouter != null && currentRouter.canPop()) {
        currentRouter.pop();
        return;
      }
      final NavigatorState currentNavigator = Navigator.of(context);
      if (currentNavigator.canPop()) {
        currentNavigator.pop();
        return;
      }
      if (currentRouter != null) {
        currentRouter.go('/catalog');
        return;
      }
      currentNavigator.maybePop();
    }

    Widget resolveLeading() {
      return IconButton(
        icon: const BackButtonIcon(),
        onPressed: handleBackNavigation,
        tooltip: router != null ? _t('catalogTitle') : null,
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: resolveLeading(),
        title: Text(
          product.nameHe.isNotEmpty ? product.nameHe : product.nameEn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.all(ASpacing.lg),
          children: [
            Text(
              product.nameHe,
              style: ATypography.titleLg,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (product.nameEn.isNotEmpty && product.nameEn != product.nameHe)
              Padding(
                padding: const EdgeInsets.only(top: ASpacing.xs),
                child: Text(
                  product.nameEn,
                  style: ATypography.bodyMd.copyWith(color: AColors.neutral600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: ASpacing.xs),
              child: Text(
                '$skuLabel: ${product.sku}',
                style: ATypography.bodySm.copyWith(color: AColors.neutral600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            if (quantityMeta.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: ASpacing.xs),
                child: Text(
                  quantityMeta,
                  style: ATypography.bodySm.copyWith(
                    color: AColors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            if (showNotInCatalogBanner)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: Container(
                  key: const ValueKey('not_in_catalog_banner'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AColors.warning.withValues(alpha: 0.12),
                    borderRadius: ARadii.md,
                    border: Border.all(
                      color: AColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Not in your private catalog',
                    style: ATypography.bodySm.copyWith(
                      color: const Color(0xFF8A6100),
                    ),
                    textAlign: baseTextAlign,
                  ),
                ),
              ),
            const SizedBox(height: ASpacing.lg),
            Text(galleryTitle, style: ATypography.titleSm),
            const SizedBox(height: ASpacing.sm),
            AspectRatio(
              aspectRatio: 1,
              child: AProductImage(
                imageUrl: mainImageUrl.isNotEmpty ? mainImageUrl : null,
                borderRadius: ARadii.lg,
              ),
            ),
            if (imageUrls.length > 1) ...[
              const SizedBox(height: ASpacing.md),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: ASpacing.sm),
                  itemBuilder: (context, index) {
                    final bool selected = index == heroImageIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedImageIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: ARadii.md,
                          border: Border.all(
                            color:
                                selected ? AColors.primary : Colors.transparent,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: AProductImage.square(
                          imageUrl: imageUrls[index],
                          size: 72,
                          borderRadius: ARadii.sm,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (displayVariants.length > 1) ...[
              const SizedBox(height: ASpacing.xl),
              Text(variantsTitle, style: ATypography.titleSm),
              const SizedBox(height: ASpacing.sm),
              Wrap(
                spacing: ASpacing.sm,
                runSpacing: ASpacing.sm,
                children: [
                  for (final ProductVariant variant in displayVariants)
                    ChoiceChip(
                      label: Text(
                        variantLabel(
                          variant,
                          fallbackSku: product.sku,
                        ),
                      ),
                      selected: variant.id == selectedVariant.id,
                      onSelected: (_) {
                        final List<_OrderUomOption> options =
                            _buildUomOptions(product, variant);
                        final _OrderUomOption nextOption =
                            _resolveOptionSelection(
                          options,
                          preferred: _selectedOrderUom,
                        );
                        setState(() {
                          _selectedVariantId = variant.id;
                          _selectedImageIndex = 0;
                          _selectedOrderUom = nextOption.type;
                          _selectedQuantity =
                              _defaultQuantity(product, nextOption.step);
                          _quantityProductId = product.id;
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: ASpacing.xl),
            ACard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(specsTitle, style: ATypography.titleSm),
                  const SizedBox(height: ASpacing.md),
                  _SpecRow(
                    label: uomLabel,
                    value: product.uom.isNotEmpty ? product.uom : unknownValue,
                  ),
                  _SpecRow(
                    label: moqLabel,
                    value:
                        product.moq > 0 ? product.moq.toString() : unknownValue,
                  ),
                  _SpecRow(
                    label: leadTimeLabel,
                    value: leadTimeValue,
                  ),
                ],
              ),
            ),
            if (attributes.isNotEmpty) ...[
              const SizedBox(height: ASpacing.lg),
              ACard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(attributesTitle, style: ATypography.titleSm),
                    const SizedBox(height: ASpacing.md),
                    for (final MapEntry<String, String> entry
                        in attributes.entries)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: ASpacing.xs,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: ATypography.bodySm.copyWith(
                                  color: AColors.neutral600,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                            const SizedBox(width: ASpacing.md),
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.value,
                                style: ATypography.bodySm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: const Border(
              top: BorderSide(color: AColors.borderSubtle),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            ASpacing.lg,
            ASpacing.md,
            ASpacing.lg,
            ASpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool compactWarehouse = constraints.maxWidth < 360;
                    final Widget infoColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouseName,
                          style: ATypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: ASpacing.xs),
                        Text(
                          warehouseQtyLabel,
                          style: ATypography.bodySm.copyWith(
                            color: AColors.neutral600,
                          ),
                        ),
                        const SizedBox(height: ASpacing.xxs),
                        Text(
                          warehouseLeadTimeLabel,
                          style: ATypography.bodySm.copyWith(
                            color: AColors.neutral600,
                          ),
                        ),
                      ],
                    );
                    final Widget selectorButton = AButton.secondary(
                      label: selectWarehouseLabel,
                      onPressed: () => _presentWarehouseSelector(
                        variant: selectedVariant,
                        displayOptions: warehouseDisplayOptions,
                        selectedId: highlightedWarehouseId,
                      ),
                    );

                    if (compactWarehouse) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          infoColumn,
                          const SizedBox(height: ASpacing.sm),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: selectorButton,
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: infoColumn),
                        const SizedBox(width: ASpacing.md),
                        selectorButton,
                      ],
                    );
                  },
                ),
                const SizedBox(height: ASpacing.md),
                Text(
                  quantityHeading,
                  style: ATypography.titleSm,
                  textAlign: baseTextAlign,
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  uomSelectorLabel,
                  style: ATypography.bodySm.copyWith(color: AColors.neutral600),
                  textAlign: baseTextAlign,
                ),
                const SizedBox(height: ASpacing.xs),
                Wrap(
                  spacing: ASpacing.sm,
                  runSpacing: ASpacing.sm,
                  children: [
                    for (final _OrderUomOption option in uomOptions)
                      Builder(
                        builder: (context) {
                          final ChoiceChip chip = ChoiceChip(
                            label: Text(labelForOption(option.type)),
                            selected: option.type == selectedUomOption.type,
                            onSelected: option.isEnabled
                                ? (_) {
                                    setState(() {
                                      _selectedOrderUom = option.type;
                                      _selectedQuantity = _defaultQuantity(
                                          product, option.step);
                                    });
                                  }
                                : null,
                          );
                          if (option.isEnabled) {
                            return chip;
                          }
                          return Tooltip(
                            message: uomUnavailableTooltip,
                            child: chip,
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  selectedUomDetail,
                  style: ATypography.bodyXs.copyWith(color: AColors.neutral600),
                  textAlign: baseTextAlign,
                ),
                const SizedBox(height: ASpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moqSummaryLabel,
                            style: ATypography.bodyXs.copyWith(
                              color: AColors.neutral600,
                            ),
                            textAlign: baseTextAlign,
                          ),
                          const SizedBox(height: ASpacing.xxs),
                          Text(
                            moqValueDisplay,
                            style: ATypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: baseTextAlign,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: ASpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stepSummaryLabel,
                            style: ATypography.bodyXs.copyWith(
                              color: AColors.neutral600,
                            ),
                            textAlign: baseTextAlign,
                          ),
                          const SizedBox(height: ASpacing.xxs),
                          Text(
                            stepValueDisplay,
                            style: ATypography.bodySm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: baseTextAlign,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (quantityErrors.isNotEmpty) ...[
                  const SizedBox(height: ASpacing.xs),
                  for (final String error in quantityErrors)
                    Text(
                      error,
                      style: ATypography.bodyXs.copyWith(color: AColors.danger),
                      textAlign: baseTextAlign,
                    ),
                ],
                if (priceBreakQuantities.isNotEmpty) ...[
                  const SizedBox(height: ASpacing.md),
                  Text(
                    priceBreaksLabel,
                    style: ATypography.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: ASpacing.xs),
                  _PriceBreakTable(
                    companyId: companyId,
                    variantId: selectedVariant.id,
                    quantities: priceBreakQuantities,
                    qtyFormat: qtyFormat,
                    qtyLabel: priceBreakQtyLabel,
                    priceLabel: priceBreakPriceLabel,
                    loadingLabel: priceBreakLoadingLabel,
                    unavailableLabel: priceBreakUnavailableLabel,
                    sourceFormatter: _pricingSourceLabel,
                    dashLabel: dashLabel,
                    atQtyLabel: atQtyLabel,
                  ),
                ],
                const SizedBox(height: ASpacing.md),
                _EffectivePriceSummary(
                  companyId: companyId,
                  variantId: selectedVariant.id,
                  quantity: effectivePriceQuantity,
                  label: effectivePriceLabel,
                  loadingLabel: effectivePriceLoading,
                  unavailableLabel: effectivePriceUnavailable,
                  contractTagLabel: contractPriceTag,
                  atQtyLabel: atQtyLabel,
                  sourceFormatter: _pricingSourceLabel,
                ),
                const SizedBox(height: ASpacing.md),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool stack = constraints.maxWidth < 360;
                    final Widget qtyStepper = AQtyStepper(
                      qty: _selectedQuantity,
                      min: minStepperQuantity,
                      step: stepValue,
                      compact: false,
                      enabled: !_isAddingToCart && variantAllowed,
                      semanticLabel: stepperSemanticLabel,
                      incrementTooltip: stepperIncreaseTooltip,
                      decrementTooltip: stepperDecreaseTooltip,
                      onChanged: (next) {
                        setState(() => _selectedQuantity = next.toDouble());
                      },
                    );
                    final Widget addButton = AButton.primary(
                      key: const ValueKey('product_add_to_cart_btn'),
                      label: addToCartLabel,
                      expand: true,
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      loading: _isAddingToCart,
                      onPressed: disableAddToCart
                          ? null
                          : () => _addVariantToCart(product, selectedVariant),
                    );
                    if (stack) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: qtyStepper,
                          ),
                          const SizedBox(height: ASpacing.sm),
                          addButton,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        qtyStepper,
                        const SizedBox(width: ASpacing.lg),
                        Expanded(child: addButton),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ASpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: ATypography.bodySm.copyWith(color: AColors.neutral600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          const SizedBox(width: ASpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: ATypography.bodySm.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

enum _OrderUom { unit, casePack, pallet }

class _OrderUomOption {
  const _OrderUomOption({
    required this.type,
    required this.unitsPerSelection,
    this.casesPerSelection,
  });

  final _OrderUom type;
  final int? unitsPerSelection;
  final int? casesPerSelection;

  bool get isEnabled => unitsPerSelection != null && unitsPerSelection! > 0;

  double get step => (unitsPerSelection ?? 1).toDouble();
}

class _EffectivePriceSummary extends ConsumerWidget {
  const _EffectivePriceSummary({
    required this.companyId,
    required this.variantId,
    required this.quantity,
    required this.label,
    required this.loadingLabel,
    required this.unavailableLabel,
    required this.contractTagLabel,
    required this.atQtyLabel,
    required this.sourceFormatter,
  });

  final String companyId;
  final String variantId;
  final int quantity;
  final String label;
  final String loadingLabel;
  final String unavailableLabel;
  final String contractTagLabel;
  final String atQtyLabel;
  final String Function(String source) sourceFormatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextStyle labelStyle =
        ATypography.bodyXs.copyWith(color: AColors.neutral600);
    final TextStyle valueStyle =
        ATypography.titleMd.copyWith(fontWeight: FontWeight.w600);
    final TextStyle mutedStyle =
        ATypography.bodySm.copyWith(color: AColors.neutral600);

    final int safeQuantity = quantity <= 0 ? 1 : quantity;
    if (companyId.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: ASpacing.xs),
          Text(unavailableLabel, style: mutedStyle),
        ],
      );
    }

    final PriceQuoteRequest request = PriceQuoteRequest(
      companyId: companyId,
      variantId: variantId,
      quantity: safeQuantity,
    );
    final priceAsync = ref.watch(priceResolutionProvider(request));

    Widget valueWidget() {
      return priceAsync.when(
        data: (price) {
          if (price == null) {
            return Text(unavailableLabel, style: mutedStyle);
          }
          String formatted;
          try {
            final NumberFormat currency =
                NumberFormat.currency(name: price.currency);
            formatted = currency.format(price.price);
          } catch (_) {
            formatted = '${price.currency} ${price.price.toStringAsFixed(2)}';
          }
          final NumberFormat qtyFormatter = NumberFormat.decimalPattern(
            Localizations.localeOf(context).toString(),
          );
          final String qtyText =
              '$atQtyLabel ${qtyFormatter.format(safeQuantity)}';
          final List<Widget> priceRow = <Widget>[
            Text(formatted, style: valueStyle),
          ];
          if (price.source.toLowerCase() != 'base') {
            priceRow.add(const SizedBox(width: ASpacing.sm));
            priceRow.add(
              ContractPriceBadge(
                key: const ValueKey('contract_price_chip'),
                label: contractTagLabel,
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: priceRow,
              ),
              SizedBox(height: ASpacing.xxs),
              Text(
                '${sourceFormatter(price.source)} • $qtyText',
                style: mutedStyle,
              ),
            ],
          );
        },
        loading: () => Text(loadingLabel, style: mutedStyle),
        error: (_, __) => Text(unavailableLabel, style: mutedStyle),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: ASpacing.xs),
        valueWidget(),
      ],
    );
  }
}

class _PriceBreakTable extends ConsumerWidget {
  const _PriceBreakTable({
    required this.companyId,
    required this.variantId,
    required this.quantities,
    required this.qtyFormat,
    required this.qtyLabel,
    required this.priceLabel,
    required this.loadingLabel,
    required this.unavailableLabel,
    required this.sourceFormatter,
    required this.dashLabel,
    required this.atQtyLabel,
  });

  final String companyId;
  final String variantId;
  final List<int> quantities;
  final NumberFormat qtyFormat;
  final String qtyLabel;
  final String priceLabel;
  final String loadingLabel;
  final String unavailableLabel;
  final String Function(String source) sourceFormatter;
  final String dashLabel;
  final String atQtyLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (quantities.isEmpty) {
      return const SizedBox.shrink();
    }
    if (companyId.isEmpty) {
      return Text(
        unavailableLabel,
        style: ATypography.bodySm.copyWith(color: AColors.neutral600),
      );
    }
    final TextStyle headerStyle =
        ATypography.bodyXs.copyWith(color: AColors.neutral600);

    final PriceBreakRequest request = PriceBreakRequest(
      companyId: companyId,
      variantId: variantId,
      quantities: quantities,
    );
    final asyncBreaks = ref.watch(priceBreaksProvider(request));
    final Map<int, PriceResolution?> breaks = asyncBreaks.maybeWhen(
      data: (map) => map,
      orElse: () => const <int, PriceResolution?>{},
    );
    final bool isLoading = asyncBreaks.isLoading;
    final bool hasError = asyncBreaks.hasError;

    return Container(
      decoration: BoxDecoration(
        color: AColors.surfaceSubtle,
        borderRadius: ARadii.md,
        border: Border.all(color: AColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(ASpacing.sm),
      key: const ValueKey('price_breaks_table'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  qtyLabel,
                  style: headerStyle,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    priceLabel,
                    style: headerStyle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ASpacing.xs),
          Column(
            children: [
              for (final int quantity in quantities)
                _PriceBreakRowView(
                  quantityLabel: qtyFormat.format(quantity),
                  trailing: _PriceBreakValue(
                    quantity: quantity,
                    resolution: breaks[quantity],
                    sourceFormatter: sourceFormatter,
                    dashLabel: dashLabel,
                    qtyFormat: qtyFormat,
                    atQtyLabel: atQtyLabel,
                  ),
                  quantityKey: ValueKey('price_break_qty_${_qKey(quantity)}'),
                ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ASpacing.xs),
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      loadingLabel,
                      style: ATypography.bodySm
                          .copyWith(color: AColors.neutral600),
                    ),
                  ),
                )
              else if (hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ASpacing.xs),
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      unavailableLabel,
                      style: ATypography.bodySm
                          .copyWith(color: AColors.neutral600),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceBreakRowView extends StatelessWidget {
  const _PriceBreakRowView({
    required this.quantityLabel,
    required this.trailing,
    this.quantityKey,
  });

  final String quantityLabel;
  final Widget trailing;
  final Key? quantityKey;

  @override
  Widget build(BuildContext context) {
    final TextStyle qtyStyle =
        ATypography.bodySm.copyWith(color: AColors.foreground);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ASpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              quantityLabel,
              style: qtyStyle,
              key: quantityKey,
            ),
          ),
          const SizedBox(width: ASpacing.sm),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBreakValue extends StatelessWidget {
  const _PriceBreakValue({
    required this.quantity,
    required this.resolution,
    required this.sourceFormatter,
    required this.dashLabel,
    required this.qtyFormat,
    required this.atQtyLabel,
  });

  final int quantity;
  final PriceResolution? resolution;
  final String Function(String source) sourceFormatter;
  final String dashLabel;
  final NumberFormat qtyFormat;
  final String atQtyLabel;

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle =
        ATypography.bodySm.copyWith(fontWeight: FontWeight.w600);
    final TextStyle sourceStyle =
        ATypography.bodyXs.copyWith(color: AColors.neutral600);

    if (resolution == null) {
      return Text(
        dashLabel,
        style: valueStyle,
        key: ValueKey('price_break_price_${_qKey(quantity)}'),
      );
    }

    String formatted;
    try {
      final NumberFormat currency =
          NumberFormat.currency(name: resolution!.currency);
      formatted = currency.format(resolution!.price);
    } catch (_) {
      formatted =
          '${resolution!.currency} ${resolution!.price.toStringAsFixed(2)}';
    }

    final String displaySource =
        '${sourceFormatter(resolution!.source)} • $atQtyLabel ${qtyFormat.format(quantity)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatted,
          style: valueStyle,
          key: ValueKey('price_break_price_${_qKey(quantity)}'),
        ),
        SizedBox(height: ASpacing.xxs),
        Text(displaySource, style: sourceStyle),
      ],
    );
  }
}

class _WarehouseOption {
  const _WarehouseOption({
    required this.id,
    required this.name,
    this.quantity,
    this.etaDays,
  });

  static const String primaryId = 'primary';

  final String id;
  final String name;
  final double? quantity;
  final int? etaDays;

  _WarehouseOption copyWith({
    String? id,
    String? name,
    double? quantity,
    int? etaDays,
  }) {
    return _WarehouseOption(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      etaDays: etaDays ?? this.etaDays,
    );
  }
}

class _WarehouseDisplayData {
  const _WarehouseDisplayData({
    required this.id,
    required this.title,
    required this.quantityLabel,
    required this.leadTimeLabel,
  });

  final String id;
  final String title;
  final String quantityLabel;
  final String leadTimeLabel;
}

class _WarehouseSelectionSheet extends StatelessWidget {
  const _WarehouseSelectionSheet({
    required this.translate,
    required this.options,
    required this.selectedId,
  });

  final String Function(String key) translate;
  final List<_WarehouseDisplayData> options;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isEmpty = options.isEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    translate('productWarehousesTitle'),
                    style: ATypography.titleSm,
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.md),
            if (isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: ASpacing.xl),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AColors.neutral400,
                      ),
                      const SizedBox(height: ASpacing.md),
                      Text(
                        translate('productWarehousesEmpty'),
                        style: ATypography.bodyMd.copyWith(
                          color: AColors.neutral600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final _WarehouseDisplayData data = options[index];
                    final bool isSelected = data.id == selectedId;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: ARadii.md,
                        onTap: () => Navigator.of(context).pop(data.id),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AColors.primaryMuted
                                : theme.colorScheme.surface,
                            borderRadius: ARadii.md,
                            border: Border.all(
                              color: isSelected
                                  ? AColors.primary
                                  : AColors.borderSubtle,
                            ),
                          ),
                          padding: const EdgeInsets.all(ASpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.title,
                                      style: ATypography.bodyMd.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: ASpacing.xs),
                                    Text(
                                      data.quantityLabel,
                                      style: ATypography.bodySm.copyWith(
                                        color: AColors.neutral600,
                                      ),
                                    ),
                                    const SizedBox(height: ASpacing.xxs),
                                    Text(
                                      data.leadTimeLabel,
                                      style: ATypography.bodySm.copyWith(
                                        color: AColors.neutral600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: ASpacing.sm),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isSelected
                                    ? AColors.primary
                                    : AColors.neutral400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: ASpacing.sm),
                  itemCount: options.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
