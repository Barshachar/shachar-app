// ignore_for_file: use_build_context_synchronously

import 'package:ashachar_marketplace/src/auth/debug_auth_sheet.dart';
import 'package:ashachar_marketplace/src/core/async_value_x.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/supabase/supabase_client_provider.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_controller.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_media_utils.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/pricing/domain/resolved_price.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:ashachar_marketplace/src/features/pricing/presentation/contract_price_badge.dart';
import 'package:ashachar_marketplace/src/features/pricing/presentation/price_quote_controller.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_create_dialog.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';

const List<String> _stepAttributeKeys = <String>[
  'step',
  'step_qty',
  'stepquantity',
  'qty_step',
  'quantity_step',
];

const Set<String> _eachLikeUomTokens = <String>{
  'unit',
  'units',
  'each',
  'ea',
  'piece',
  'pieces',
  'pc',
  'pcs',
  'item',
  'items',
  'single',
  'יחידה',
  'יחידות',
  'יח',
};

final companyCatalogVariantsProvider = FutureProvider.autoDispose
    .family<Set<String>?, String>((ref, companyId) async {
  if (companyId.isEmpty) {
    return null;
  }
  final service = ref.watch(priceResolutionServiceProvider);
  try {
    return await service.loadCompanyCatalog(companyId: companyId);
  } catch (_) {
    return null;
  }
});

@visibleForTesting
double? extractPositiveStep(Map<String, dynamic>? attributes) {
  if (attributes == null || attributes.isEmpty) {
    return null;
  }
  for (final MapEntry<dynamic, dynamic> entry in attributes.entries) {
    final String key = entry.key.toString().toLowerCase();
    if (_stepAttributeKeys.contains(key)) {
      final double? parsed = asPositiveDouble(entry.value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

@visibleForTesting
double? asPositiveDouble(Object? value) {
  if (value is num) {
    final double parsed = value.toDouble();
    return parsed > 0 ? parsed : null;
  }
  if (value is String) {
    final double? parsed = double.tryParse(value);
    if (parsed != null && parsed > 0) {
      return parsed;
    }
  }
  return null;
}

@visibleForTesting
String resolveCatalogUom(Product product, [ProductVariant? variant]) {
  final String variantUom = variant?.uom.trim() ?? '';
  if (variantUom.isNotEmpty) {
    return variantUom;
  }
  return product.uom.trim();
}

@visibleForTesting
bool isEachLikeUom(String uom) {
  if (uom.isEmpty) {
    return false;
  }
  final String normalized =
      uom.toLowerCase().replaceAll(RegExp('[^a-z\u0590-\u05FF]'), '');
  return _eachLikeUomTokens.contains(normalized);
}

@visibleForTesting
double catalogStepQuantity(Product product, ProductVariant? variant) {
  final double? variantStep = extractPositiveStep(variant?.attributes);
  if (variantStep != null) {
    return variantStep;
  }
  final String resolvedUom = resolveCatalogUom(product, variant);
  if (isEachLikeUom(resolvedUom)) {
    return 1;
  }
  if (product.packSize > 0) {
    return product.packSize.toDouble();
  }
  return 1;
}

@visibleForTesting
String catalogMetadataLabel(
  Product product, {
  ProductVariant? variant,
}) {
  final List<String> parts = <String>[];
  if (product.moq > 0) {
    parts.add('MOQ ${product.moq}');
  }
  final String resolvedUom = resolveCatalogUom(product, variant);
  if (resolvedUom.isNotEmpty) {
    parts.add(resolvedUom);
  }
  if (product.packSize > 0) {
    final String packLabel = isEachLikeUom(resolvedUom)
        ? 'Pack ${product.packSize}'
        : 'Pack ${product.packSize} ${resolvedUom.isNotEmpty ? resolvedUom : ''}'
            .trim();
    parts.add(packLabel);
  }
  return parts.join(' • ');
}

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  bool _refreshedOnce = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (mounted && !_refreshedOnce) {
        _refreshedOnce = true;
        ref.read(catalogControllerProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localizations.of<MarketplaceLocalizations>(
        context, MarketplaceLocalizations);
    final cartState = ref.watch(cartControllerProvider);
    final catalogAsync = ref.watch(catalogControllerProvider);
    final debugFeaturesEnabled = ref.watch(debugFeaturesEnabledProvider);
    bool isAuthenticated = false;
    String companyId = '';
    try {
      final sessionState = ref.watch(sessionControllerProvider);
      final Session? session = sessionState.valueOrNull;
      isAuthenticated = session != null;
      final Object? companyMeta = session?.user.appMetadata['company_id'];
      if (companyMeta is String && companyMeta.isNotEmpty) {
        companyId = companyMeta;
      }
    } catch (error, stackTrace) {
      final bool isSupabaseUninitialized =
          error.toString().contains('Supabase.instance');
      if (!isSupabaseUninitialized) {
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
    final allowedVariantsAsync =
        ref.watch(companyCatalogVariantsProvider(companyId));
    final Set<String>? allowedVariants = allowedVariantsAsync.asData?.value;
    final String signOutLabel = l10n?.translate('signOut') ?? 'Sign out';
    final String signInLabel = l10n?.translate('authSignIn') ?? 'Sign in';
    const String logoutActionKey = 'logout';
    final Color actionColor = Theme.of(context).colorScheme.onPrimary;

    final bool isCompact = MediaQuery.sizeOf(context).width < 360;
    final List<Widget> actions = [
      IconButton(
        visualDensity:
            isCompact ? VisualDensity.compact : VisualDensity.standard,
        padding: isCompact ? const EdgeInsets.all(4) : null,
        tooltip: l10n?.translate('catalogSearchTitle') ?? 'Search',
        icon: const Icon(Icons.search),
        onPressed: () => context.push('/catalog/search'),
      ),
    ];
    if (debugFeaturesEnabled) {
      actions.add(
        IconButton(
          visualDensity:
              isCompact ? VisualDensity.compact : VisualDensity.standard,
          padding: isCompact ? const EdgeInsets.all(4) : null,
          key: const ValueKey('debug_entrypoint'),
          tooltip: 'Debug auth',
          icon: const Icon(Icons.bug_report),
          onPressed: () => showDebugAuthSheet(context, ref),
        ),
      );
    }

    Future<void> handleSignOut() async {
      try {
        await ref.read(supabaseClientProvider).auth.signOut();
        debugPrint('[AUTH_FLOW] logout=ok');
        if (!mounted) {
          return;
        }
        context.go('/home');
      } catch (error) {
        debugPrint('[AUTH_FLOW] logout=fail error=$error');
      }
    }

    Widget? buildAuthAction() {
      if (isAuthenticated) {
        if (isCompact) {
          return IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4),
            tooltip: signOutLabel,
            icon: const Icon(Icons.logout),
            onPressed: handleSignOut,
          );
        }
        return PopupMenuButton<String>(
          tooltip: signOutLabel,
          onSelected: (selected) async {
            if (selected == logoutActionKey) {
              await handleSignOut();
            }
          },
          itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: logoutActionKey,
              child: Text(signOutLabel),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              signOutLabel,
              style: TextStyle(color: actionColor),
            ),
          ),
        );
      }
      if (isCompact) {
        return IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(4),
          tooltip: signInLabel,
          icon: const Icon(Icons.login),
          onPressed: () => context.go('/login'),
        );
      }
      return TextButton(
        onPressed: () {
          context.go('/login');
        },
        style: TextButton.styleFrom(
          foregroundColor: actionColor,
        ),
        child: Text(signInLabel),
      );
    }

    final Widget? authAction = buildAuthAction();
    if (authAction != null) {
      actions.add(Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: authAction,
      ));
    }

    final GoRouter? router = GoRouter.maybeOf(context);
    final bool canNavigateBack =
        router?.canPop() ?? Navigator.of(context).canPop();
    final Widget leading = canNavigateBack
        ? const BackButton()
        : IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            // Buyers/customers should land on the dedicated customer home screen
            onPressed: () {
              if (router != null) {
                router.go('/customer');
              } else {
                Navigator.of(context).maybePop();
              }
            },
          );

    return Scaffold(
      appBar: AppBar(
        leading: leading,
        title: Text(
          l10n?.translate('catalogTitle') ?? 'Catalog',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        actions: actions,
      ),
      body: catalogAsync.when(
        loading: () => const _CatalogLoading(),
        error: (error, _) => AStateMessage(
          icon: Icons.error_outline,
          title: l10n?.translate('catalogErrorTitle') ?? 'Something went wrong',
          message: l10n?.translate('catalogErrorMessage') ??
              'We could not load the catalog right now.',
          primaryLabel: l10n?.translate('catalogRetry') ?? 'Try again',
          onPrimaryPressed: () =>
              ref.read(catalogControllerProvider.notifier).refresh(),
        ),
        data: (state) {
          Future<void> handleRefresh() async {
            try {
              await ref.read(catalogControllerProvider.notifier).refresh();
            } catch (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${l10n?.translate('catalogErrorMessage') ?? "We could not load the catalog right now."}\n$error',
                  ),
                ),
              );
            }
          }

          if (state.items.isEmpty && !state.hasMore) {
            return RefreshIndicator(
              onRefresh: handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  AStateMessage(
                    icon: Icons.inventory_2_outlined,
                    title: l10n?.translate('catalogEmptyTitle') ??
                        'No products yet',
                    message: l10n?.translate('catalogEmptyMessage') ??
                        'Please check back soon or adjust filters.',
                    primaryLabel:
                        l10n?.translate('catalogEmptyCta') ?? 'Refresh catalog',
                    onPrimaryPressed: handleRefresh,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: handleRefresh,
            displacement: 80,
            child: _CatalogList(
              products: state.items,
              companyId: companyId,
              allowedVariants: allowedVariants,
              hasMore: state.hasMore,
              isLoadingMore: state.isLoadingMore,
              onLoadMore: () =>
                  ref.read(catalogControllerProvider.notifier).loadMore(),
            ),
          );
        },
      ),
      bottomNavigationBar: QuickOrderNavBar(
        currentTab: QuickNavTab.catalog,
        checkoutOrderId: cartState.draftOrderId,
      ),
      floatingActionButton: null,
    );
  }
}

class _CatalogList extends StatefulWidget {
  const _CatalogList({
    required this.products,
    required this.companyId,
    required this.allowedVariants,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<Product> products;
  final String companyId;
  final Set<String>? allowedVariants;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onLoadMore;

  @override
  State<_CatalogList> createState() => _CatalogListState();
}

class _CatalogListState extends State<_CatalogList> {
  late final ScrollController _scrollController;
  bool _pendingLoad = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _CatalogList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoadingMore) {
      _pendingLoad = false;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _triggerLoadMore() async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    try {
      await widget.onLoadMore();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n?.translate('catalogErrorMessage') ?? "We could not load the catalog right now."}\n$error',
          ),
        ),
      );
    } finally {
      _pendingLoad = false;
    }
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore || _pendingLoad) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    if (_scrollController.position.extentAfter < 320) {
      _pendingLoad = true;
      // ignore: discarded_futures
      _triggerLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsDirectional padding = context.pagePadding();
    final int extraItems = widget.hasMore ? 1 : 0;
    return ListView.separated(
      controller: _scrollController,
      padding: padding.resolve(Directionality.of(context)),
      itemCount: widget.products.length + extraItems,
      separatorBuilder: (_, __) => const SizedBox(height: ASpacing.xl),
      itemBuilder: (context, index) {
        if (index >= widget.products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: ASpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final Product product = widget.products[index];
        final String secondaryName =
            product.nameEn.isNotEmpty ? product.nameEn : product.sku;
        final String? imageUrl = resolvePrimaryImage(product);
        return _CatalogProductCard(
          product: product,
          imageUrl: imageUrl,
          secondaryName: secondaryName,
          companyId: widget.companyId,
          allowedVariants: widget.allowedVariants,
        );
      },
    );
  }
}

class _CatalogProductCard extends ConsumerStatefulWidget {
  const _CatalogProductCard({
    required this.product,
    required this.imageUrl,
    required this.secondaryName,
    required this.companyId,
    required this.allowedVariants,
  });

  final Product product;
  final String? imageUrl;
  final String secondaryName;
  final String companyId;
  final Set<String>? allowedVariants;

  @override
  ConsumerState<_CatalogProductCard> createState() =>
      _CatalogProductCardState();
}

class _CatalogProductCardState extends ConsumerState<_CatalogProductCard> {
  double _qty = 1;
  bool _isAdding = false;

  MarketplaceLocalizations? get _l10n =>
      Localizations.of<MarketplaceLocalizations>(
        context,
        MarketplaceLocalizations,
      );

  @override
  void initState() {
    super.initState();
    _qty = _minimumQty(widget.product);
  }

  @override
  void didUpdateWidget(covariant _CatalogProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final double minQty = _minimumQty(widget.product);
    if (oldWidget.product.id != widget.product.id) {
      _qty = minQty;
      return;
    }
    if (_qty < minQty) {
      _qty = minQty;
    }
  }

  ProductVariant? _resolveVariant(Product product) {
    for (final ProductVariant variant in product.variants) {
      if (variant.active) {
        return variant;
      }
    }
    return product.variants.isNotEmpty ? product.variants.first : null;
  }

  double _minimumQty(Product product) {
    if (product.moq > 0) {
      return product.moq.toDouble();
    }
    return 1;
  }

  double _normalizeQuantity(
    double qty,
    double minQty,
    double stepQty,
  ) {
    final double safe = qty < minQty ? minQty : qty;
    if (stepQty <= 0) {
      return safe;
    }
    final double stepsRaw = (safe - minQty) / stepQty;
    final int steps = stepsRaw.isFinite ? stepsRaw.round() : 0;
    final int clampedSteps = steps < 0 ? 0 : steps;
    final double normalized = minQty + clampedSteps * stepQty;
    final double clamped = normalized < minQty ? minQty : normalized;
    return double.parse(clamped.toStringAsFixed(4));
  }

  Future<void> _handleRequestAccess(ProductVariant variant) async {
    final double minQty = _minimumQty(widget.product);
    final CartLine line = CartLine(
      id: 'catalog-rfq-${variant.id}',
      orderId: 'catalog-preview',
      variantId: variant.id,
      vendorCompanyId: widget.product.vendorCompanyId,
      qty: minQty,
      unitPrice: 0,
      lineTotal: 0,
      productName: widget.product.nameHe.isNotEmpty
          ? widget.product.nameHe
          : widget.product.nameEn,
      variantSku: variant.id,
      variantAttributes: variant.attributes,
      productTranslations: <String, String>{
        'he': widget.product.nameHe,
        'en': widget.product.nameEn,
      },
    );

    final MarketplaceLocalizations? l10n = _l10n;
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);
    try {
      final String? rfqId = await showRfqCreateDialog(
        context: context,
        ref: ref,
        cartLines: <CartLine>[line],
      );
      if (!mounted || rfqId == null) {
        return;
      }
      ref.invalidate(customerRfqsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.translate('catalogRequestAccessSuccess') ??
                'הבקשה נשלחה לצוות המכירות.',
          ),
        ),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n?.translate('catalogRequestAccessError') ?? 'לא הצלחנו לשלוח בקשה.'} $error',
          ),
        ),
      );
    }
  }

  bool _isVariantAllowed(ProductVariant? variant) {
    if (widget.companyId.isEmpty) {
      return true;
    }
    if (variant == null) {
      return true;
    }
    final Set<String>? allowed = widget.allowedVariants;
    if (allowed == null) {
      return true;
    }
    return allowed.contains(variant.id);
  }

  Future<PriceResolution?> _tryResolvePrice(
    String variantId,
    int quantity,
  ) async {
    final String companyId = widget.companyId;
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
    switch (mapped) {
      case PriceSource.contract:
        return _l10n?.translate('pricingSourceContract') ?? 'Contract price';
      case PriceSource.priceList:
        return _l10n?.translate('pricingSourcePriceList') ?? 'Price list';
      case PriceSource.base:
        return _l10n?.translate('pricingSourceBase') ?? 'Base price';
      case PriceSource.fallback:
        return _l10n?.translate('pricingSourceFallback') ?? 'Standard price';
    }
  }

  String _formatAddToCartSuccess(
    PriceResolution? price,
    String baseMessage,
  ) {
    if (price == null) {
      return baseMessage;
    }
    final String label = _pricingSourceLabel(price.source).trim();
    if (label.isEmpty) {
      return baseMessage;
    }
    return '$baseMessage • $label';
  }

  Future<void> _addToCart(ProductVariant variant) async {
    if (_isAdding) {
      return;
    }

    setState(() => _isAdding = true);
    final cart = ref.read(cartControllerProvider.notifier);
    PriceResolution? resolvedPrice;
    try {
      final double minQty = _minimumQty(widget.product);
      final double stepQty = catalogStepQuantity(widget.product, variant);
      final double normalized = _normalizeQuantity(_qty, minQty, stepQty);
      final int requestQty = normalized <= 0 ? 1 : normalized.round();
      resolvedPrice = await _tryResolvePrice(variant.id, requestQty);
      await cart.addVariant(variant, qty: normalized);
      if (mounted && _qty != normalized) {
        setState(() => _qty = normalized);
      }
      if (!mounted) return;
      final String? draftId = ref.read(cartControllerProvider).draftOrderId;
      if (draftId != null) {
        ref.invalidate(cartLinesProvider(draftId));
      }
      final messenger = ScaffoldMessenger.of(context);
      final String baseMessage =
          _l10n?.translate('cartAddSuccess') ?? 'נוסף לעגלה';
      final String successMessage =
          _formatAddToCartSuccess(resolvedPrice, baseMessage);
      messenger.showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final String failureMessage =
          _l10n?.translate('catalogSearchAddToCartError') ??
              "Couldn't add to cart. Try again.";
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final ProductVariant? activeVariant = _resolveVariant(product);
    final String? activeVariantId = activeVariant?.id;
    final MarketplaceLocalizations? l10n = _l10n;
    final String addToCartLabel =
        l10n?.translate('catalogSearchAddToCart') ?? 'Add to cart';
    final bool isVariantAllowed = _isVariantAllowed(activeVariant);
    final bool isNotInCatalog = !isVariantAllowed &&
        widget.companyId.isNotEmpty &&
        widget.allowedVariants != null &&
        activeVariant != null;
    final ProductVariant? gatedVariant = isNotInCatalog ? activeVariant : null;
    final bool controlsEnabled =
        activeVariant != null && !_isAdding && isVariantAllowed;
    final ProductVariant? submissionVariant =
        controlsEnabled ? activeVariant : null;
    final double minQty = _minimumQty(product);
    final double stepQty = catalogStepQuantity(product, activeVariant);
    final double effectiveQty = _normalizeQuantity(_qty, minQty, stepQty);
    final double safePriceQty = effectiveQty <= 0 ? 1 : effectiveQty;
    final String priceLabel =
        l10n?.translate('productEffectivePriceLabel') ?? 'Effective price';
    final String priceLoadingLabel =
        l10n?.translate('productEffectivePriceLoading') ?? '…';
    final String dashLabel = l10n?.translate('dash') ?? '—';
    final String priceUnavailableLabel =
        l10n?.translate('productEffectivePriceUnavailable') ?? dashLabel;
    final String contractTagLabel =
        l10n?.translate('contractPrice') ?? 'Contract price';
    final String notInCatalogChipLabel = l10n?.translate('notInCatalogShort') ??
        (l10n?.translate('notInCatalog') ?? 'Not in catalog');
    final String atQtyLabel = l10n?.translate('atQty') ?? 'at';
    final String metadata = catalogMetadataLabel(
      product,
      variant: activeVariant,
    );
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isCardCompact = constraints.maxWidth < 360;
            final Widget image = AProductImage.square(
              imageUrl: widget.imageUrl,
              size: isCardCompact ? 56 : 60,
              borderRadius: ARadii.md,
            );

            final Widget details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameHe,
                  style: ATypography.titleSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                if (widget.secondaryName.isNotEmpty &&
                    widget.secondaryName != product.nameHe) ...[
                  const SizedBox(height: ASpacing.xs),
                  Text(
                    widget.secondaryName,
                    style: ATypography.bodySm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ],
                const SizedBox(height: ASpacing.xs),
                Text(
                  metadata,
                  style: ATypography.bodySm.copyWith(
                    color: AColors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                if (gatedVariant != null)
                  Padding(
                    padding: const EdgeInsets.only(top: ASpacing.xs),
                    child: Chip(
                      key: ValueKey(
                        'catalog_not_in_catalog_chip_${gatedVariant.id}',
                      ),
                      label: Text(
                        notInCatalogChipLabel,
                        style: ATypography.bodyXs.copyWith(
                          color: AColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      backgroundColor: AColors.dangerSurface,
                      shape: const StadiumBorder(
                        side: BorderSide(color: AColors.dangerBorder),
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                if (gatedVariant != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: _isAdding
                          ? null
                          : () => _handleRequestAccess(gatedVariant),
                      icon: const Icon(Icons.outgoing_mail, size: 18),
                      label: Text(
                        l10n?.translate('catalogRequestAccess') ?? 'בקש גישה',
                      ),
                    ),
                  ),
                const SizedBox(height: ASpacing.xs),
                if (activeVariant != null)
                  CatalogPriceSection(
                    companyId: widget.companyId,
                    variantId: activeVariant.id,
                    quantity: safePriceQty,
                    label: priceLabel,
                    loadingLabel: priceLoadingLabel,
                    unavailableLabel: priceUnavailableLabel,
                    contractTagLabel: contractTagLabel,
                    dashLabel: dashLabel,
                    sourceFormatter: _pricingSourceLabel,
                    atQtyLabel: atQtyLabel,
                    isEnabled: isVariantAllowed,
                  ),
              ],
            );

            if (isCardCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: image),
                  const SizedBox(height: ASpacing.md),
                  details,
                  const SizedBox(height: ASpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Icon(
                      context.isRtl ? Icons.chevron_left : Icons.chevron_right,
                      color: AColors.neutral400,
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image,
                const SizedBox(width: ASpacing.lg),
                Expanded(child: details),
                const SizedBox(width: ASpacing.sm),
                Icon(
                  context.isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: AColors.neutral400,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: ASpacing.md),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isCompactActions = constraints.maxWidth < 360;
            final Widget qtyStepper = AQtyStepper(
              qty: effectiveQty,
              min: minQty,
              step: stepQty,
              enabled: controlsEnabled,
              onChanged: (next) {
                final double nextQty =
                    _normalizeQuantity(next.toDouble(), minQty, stepQty);
                setState(() => _qty = nextQty);
              },
            );
            final Widget addButton = AButton.primary(
              key: activeVariantId != null
                  ? ValueKey('catalog_add_btn_$activeVariantId')
                  : null,
              label: addToCartLabel,
              expand: true,
              icon: const Icon(Icons.add_shopping_cart_outlined),
              loading: _isAdding,
              onPressed: submissionVariant != null
                  ? () => _addToCart(submissionVariant)
                  : null,
            );

            if (isCompactActions) {
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
                const SizedBox(width: ASpacing.md),
                Expanded(child: addButton),
              ],
            );
          },
        ),
      ],
    );

    return ACard(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: ASpacing.xl,
        vertical: ASpacing.md,
      ),
      onTap: () {
        final GoRouter? router = GoRouter.maybeOf(context);
        if (router == null) {
          return;
        }
        router.pushNamed(
          'product',
          pathParameters: <String, String>{'id': product.id},
        );
      },
      child: SizedBox(width: double.infinity, child: content),
    );
  }
}

class CatalogPriceSection extends ConsumerStatefulWidget {
  const CatalogPriceSection({
    super.key,
    required this.companyId,
    required this.variantId,
    required this.quantity,
    required this.label,
    required this.loadingLabel,
    required this.unavailableLabel,
    required this.contractTagLabel,
    required this.dashLabel,
    required this.sourceFormatter,
    required this.atQtyLabel,
    required this.isEnabled,
    this.priceOverride,
  });

  final String companyId;
  final String variantId;
  final double quantity;
  final String label;
  final String loadingLabel;
  final String unavailableLabel;
  final String contractTagLabel;
  final String dashLabel;
  final String Function(String source) sourceFormatter;
  final String atQtyLabel;
  final bool isEnabled;
  final AsyncValue<PriceResolution?>? priceOverride;

  @override
  ConsumerState<CatalogPriceSection> createState() =>
      _CatalogPriceSectionState();
}

class _CatalogPriceSectionState extends ConsumerState<CatalogPriceSection> {
  AsyncValue<PriceResolution?> _priceState =
      const AsyncValue<PriceResolution?>.loading();
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.priceOverride != null) {
      _priceState = widget.priceOverride!;
    } else {
      Future.microtask(_resolvePrice);
    }
  }

  @override
  void didUpdateWidget(covariant CatalogPriceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool usingOverride = widget.priceOverride != null;
    final bool wasUsingOverride = oldWidget.priceOverride != null;

    if (usingOverride) {
      if (!wasUsingOverride ||
          widget.priceOverride != oldWidget.priceOverride) {
        setState(() {
          _priceState = widget.priceOverride!;
        });
      }
      return;
    }

    if (wasUsingOverride && !usingOverride) {
      _resolvePrice();
      return;
    }

    final bool quantityChanged =
        (oldWidget.quantity - widget.quantity).abs() > 1e-4;
    if (quantityChanged ||
        oldWidget.companyId != widget.companyId ||
        oldWidget.variantId != widget.variantId ||
        oldWidget.isEnabled != widget.isEnabled) {
      _resolvePrice();
    }
  }

  Future<void> _resolvePrice() async {
    if (!mounted) {
      return;
    }
    if (widget.priceOverride != null) {
      setState(() {
        _priceState = widget.priceOverride!;
      });
      return;
    }
    if (!widget.isEnabled || widget.companyId.isEmpty) {
      setState(() {
        _priceState = const AsyncValue<PriceResolution?>.data(null);
      });
      return;
    }
    final double safeQty = widget.quantity <= 0 ? 1 : widget.quantity;
    final int requestId = ++_requestId;
    setState(() {
      _priceState = const AsyncValue<PriceResolution?>.loading();
    });
    final svc = ref.read(priceResolutionServiceProvider);
    final AsyncValue<PriceResolution?> result = await AsyncValue.guard(
      () => svc.resolve(
        companyId: widget.companyId,
        variantId: widget.variantId,
        qty: safeQty,
      ),
    );
    if (!mounted || requestId != _requestId) {
      return;
    }
    setState(() {
      _priceState = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        ATypography.bodyXs.copyWith(color: AColors.neutral600);
    final TextStyle valueStyle =
        ATypography.bodyMd.copyWith(fontWeight: FontWeight.w600);
    final TextStyle mutedStyle =
        ATypography.bodySm.copyWith(color: AColors.neutral600);

    final double safeQty = widget.quantity <= 0 ? 1 : widget.quantity;

    Widget buildValueContent() {
      if (!widget.isEnabled) {
        return Semantics(
          label: widget.unavailableLabel,
          child: Text(
            widget.dashLabel,
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        );
      }

      return KeyedSubtree(
        key: ValueKey('catalog_price_${widget.variantId}'),
        child: _priceState.when(
          data: (price) {
            if (price == null) {
              return Semantics(
                label: widget.unavailableLabel,
                child: Text(widget.dashLabel, style: valueStyle),
              );
            }
            String formattedPrice;
            try {
              final intl.NumberFormat currency =
                  intl.NumberFormat.currency(name: price.currency);
              formattedPrice = currency.format(price.price);
            } catch (_) {
              formattedPrice =
                  '${price.currency} ${price.price.toStringAsFixed(2)}';
            }
            final intl.NumberFormat qtyFormatter =
                intl.NumberFormat.decimalPattern(
              Localizations.localeOf(context).toString(),
            );
            final String qtyText =
                '${widget.atQtyLabel} ${qtyFormatter.format(safeQty)}';
            final List<Widget> rowChildren = <Widget>[
              Text(
                formattedPrice,
                style: valueStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ];
            if (price.source.toLowerCase() != 'base') {
              rowChildren.add(
                ContractPriceBadge(
                  key: ValueKey('catalog_contract_chip_${widget.variantId}'),
                  label: widget.contractTagLabel,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: ASpacing.xs,
                  runSpacing: ASpacing.xs,
                  children: rowChildren,
                ),
                const SizedBox(height: ASpacing.xxs),
                Text(
                  '${widget.sourceFormatter(price.source)} • $qtyText',
                  style: mutedStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textAlign: TextAlign.right,
                ),
              ],
            );
          },
          loading: () => Semantics(
            label: widget.loadingLabel,
            child: const SizedBox(
              width: 80,
              child: ASkeleton(height: 16),
            ),
          ),
          error: (_, __) => Semantics(
            label: widget.unavailableLabel,
            child: Text(
              widget.dashLabel,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      );
    }

    Text buildLabelText() {
      return Text(
        widget.label,
        style: labelStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack = constraints.maxWidth < 360;
        final Widget value = Align(
          alignment: stack
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          child: buildValueContent(),
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildLabelText(),
              const SizedBox(height: ASpacing.xs),
              value,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: buildLabelText()),
            const SizedBox(width: ASpacing.sm),
            Flexible(child: value),
          ],
        );
      },
    );
  }
}

class _CatalogLoading extends StatelessWidget {
  const _CatalogLoading();

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding =
        context.pagePadding().resolve(Directionality.of(context));
    return ListView.builder(
      padding: padding,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 5 ? 0 : ASpacing.xl),
          child: const ACard(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: ASpacing.xl,
              vertical: ASpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ASkeleton(width: 220, height: 18),
                SizedBox(height: ASpacing.sm),
                ASkeleton(width: 160, height: 14),
                SizedBox(height: ASpacing.sm),
                ASkeleton(width: 120, height: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
