import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_media_utils.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';

class CatalogSearchPage extends ConsumerStatefulWidget {
  const CatalogSearchPage({super.key});

  @override
  ConsumerState<CatalogSearchPage> createState() => _CatalogSearchPageState();
}

class _CatalogSearchPageState extends ConsumerState<CatalogSearchPage> {
  static const int _pageSize = 30;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  AsyncValue<List<ProductSearchResult>> _results = const AsyncValue.loading();
  Timer? _debounce;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _inStockOnly = false;
  int _offset = 0;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _addingVariantIds = <String>{};

  List<Category> _categories = const <Category>[];
  bool _isLoadingCategories = false;
  String? _selectedCategory;
  List<String> _history = const <String>[];
  List<String> _suggestions = const <String>[];
  bool _historyLoaded = false;
  String _activeQuery = '';
  bool _suppressOnChanged = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadHistory();
    });
    _loadCategories();
    _triggerSearch(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  MarketplaceLocalizations? get _l10n =>
      Localizations.of<MarketplaceLocalizations>(
          context, MarketplaceLocalizations);

  String _t(String key) => _l10n?.translate(key) ?? key;

  void _loadCategories() {
    setState(() => _isLoadingCategories = true);
    final repository = ref.read(catalogRepositoryProvider);
    repository.fetchCategories().then((value) {
      if (!mounted) return;
      setState(() {
        _categories = value;
        _isLoadingCategories = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    });
  }

  Future<void> _loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> stored =
        prefs.getStringList(_historyKey()) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _history = stored;
      _historyLoaded = true;
      _suggestions = _filterHistory(_searchController.text, stored);
    });
  }

  String _historyKey() {
    final Locale locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('he');
    return 'catalog_search_history_${locale.languageCode}';
  }

  List<String> _filterHistory(String input, [List<String>? history]) {
    final List<String> base = history ?? _history;
    final String normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) {
      return base.take(8).toList();
    }
    return base
        .where((entry) => entry.toLowerCase().contains(normalized))
        .take(8)
        .toList();
  }

  void _updateSuggestions(String value) {
    if (!_historyLoaded) {
      return;
    }
    final List<String> next = _filterHistory(value);
    setState(() => _suggestions = next);
  }

  Future<void> _saveQueryToHistory(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> next = List<String>.from(_history);
    next.removeWhere((entry) => entry.toLowerCase() == trimmed.toLowerCase());
    next.insert(0, trimmed);
    final List<String> limited = next.take(10).toList();
    await prefs.setStringList(_historyKey(), limited);
    if (!mounted) return;
    setState(() {
      _history = limited;
      _suggestions = _filterHistory(_searchController.text, limited);
    });
  }

  Future<void> _clearHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey());
    if (!mounted) return;
    setState(() {
      _history = const <String>[];
      _suggestions = const <String>[];
      _historyLoaded = true;
    });
  }

  void _applySuggestion(String query) {
    final String trimmed = query.trim();
    _suppressOnChanged = true;
    _debounce?.cancel();
    _searchController.value = TextEditingValue(
      text: trimmed,
      selection: TextSelection.fromPosition(
        TextPosition(offset: trimmed.length),
      ),
    );
    _updateSuggestions(trimmed);
    _triggerSearch(reset: true);
  }

  void _onQueryChanged(String value) {
    if (_suppressOnChanged) {
      _suppressOnChanged = false;
      return;
    }
    _debounce?.cancel();
    _updateSuggestions(value);
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _triggerSearch(reset: true);
    });
  }

  Future<void> _triggerSearch({required bool reset}) async {
    final repository = ref.read(catalogRepositoryProvider);
    final String query = _searchController.text.trim();
    final double? minPrice = double.tryParse(_minPriceController.text.trim());
    final double? maxPrice = double.tryParse(_maxPriceController.text.trim());
    final bool shouldRemember = reset && query.isNotEmpty;
    _activeQuery = query;

    if (reset) {
      setState(() {
        _offset = 0;
        _hasMore = true;
        _results = const AsyncValue.loading();
        _isLoadingMore = false;
      });
    } else {
      if (_isLoadingMore || !_hasMore) {
        return;
      }
      setState(() => _isLoadingMore = true);
    }

    try {
      final items = await repository.searchProducts(
        q: query,
        categoryId: _selectedCategory,
        inStockOnly: _inStockOnly,
        minPrice: minPrice,
        maxPrice: maxPrice,
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _results = AsyncValue.data(items);
        } else {
          final existing = _results.value ?? const <ProductSearchResult>[];
          _results =
              AsyncValue.data(<ProductSearchResult>[...existing, ...items]);
          _isLoadingMore = false;
        }
        _offset += items.length;
        _hasMore = items.length == _pageSize;
      });
      if (shouldRemember) {
        await _saveQueryToHistory(query);
      }
    } catch (error, stack) {
      if (!mounted) return;
      setState(() {
        _results = AsyncValue.error(error, stack);
        _isLoadingMore = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _refresh() => _triggerSearch(reset: true);

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoadingMore ||
        !_hasMore ||
        _results.isLoading) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    const double threshold = 280;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      _triggerSearch(reset: false);
    }
  }

  Future<void> _handleAddToCart(ProductSearchResult item) async {
    final String variantId = item.variant.id;
    if (_addingVariantIds.contains(variantId)) {
      return;
    }
    setState(() => _addingVariantIds.add(variantId));
    final CartController cart = ref.read(cartControllerProvider.notifier);
    try {
      await cart.addToCart(item.variant);
    } catch (_) {
      if (!mounted) return;
      final ScaffoldMessengerState? messenger =
          ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(content: Text(_t('catalogSearchAddToCartError'))),
      );
    } finally {
      if (mounted) {
        setState(() => _addingVariantIds.remove(variantId));
      }
    }
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    final Widget? historySection = _buildHistorySection();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          ASpacing.lg, ASpacing.lg, ASpacing.lg, ASpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: _t('catalogSearchPlaceholder'),
              filled: true,
              fillColor: AColors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: ARadii.lg,
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onQueryChanged,
          ),
          if (historySection != null) ...[
            const SizedBox(height: ASpacing.sm),
            historySection,
          ],
          const SizedBox(height: ASpacing.md),
          Wrap(
            spacing: ASpacing.sm,
            runSpacing: ASpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AChip(
                label: _t('filterInStockOnly'),
                selected: _inStockOnly,
                icon: Icons.inventory_2,
                onSelected: (value) {
                  setState(() => _inStockOnly = value);
                  _triggerSearch(reset: true);
                },
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _minPriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _t('filterMinPrice'),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _triggerSearch(reset: true),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _t('filterMaxPrice'),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _triggerSearch(reset: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: ASpacing.md),
          if (_isLoadingCategories)
            const SizedBox(
              height: 42,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: ASpacing.sm),
                    child: ChoiceChip(
                      label: Text(_t('filterAllCategories')),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = null);
                          _triggerSearch(reset: true);
                        }
                      },
                    ),
                  ),
                  ..._categories.map((category) {
                    final bool isSelected = _selectedCategory == category.id;
                    return Padding(
                      padding:
                          const EdgeInsetsDirectional.only(end: ASpacing.sm),
                      child: ChoiceChip(
                        label: Text(category.nameHe.isNotEmpty
                            ? category.nameHe
                            : category.nameEn),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory =
                              isSelected ? null : category.id);
                          _triggerSearch(reset: true);
                        },
                      ),
                    );
                  }),
                ],
              ),
            )
          else
            Text(
              _t('filterAllCategories'),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget? _buildHistorySection() {
    if (!_historyLoaded) {
      return null;
    }
    final ThemeData theme = Theme.of(context);
    final String currentText = _searchController.text.trim();
    final List<String> entries = currentText.isEmpty ? _history : _suggestions;
    final bool hasEntries = entries.isNotEmpty;
    final bool hasClearAction = _history.isNotEmpty;
    if (!hasEntries && !hasClearAction) {
      return null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _t('catalogSearchRecent'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasClearAction)
              TextButton(
                onPressed: _clearHistory,
                child: Text(_t('catalogSearchClear')),
              ),
          ],
        ),
        const SizedBox(height: ASpacing.xs),
        if (hasEntries)
          Wrap(
            spacing: ASpacing.sm,
            runSpacing: ASpacing.sm,
            children: [
              for (final String query in entries)
                ActionChip(
                  label: Text(query),
                  onPressed: () => _applySuggestion(query),
                ),
            ],
          )
        else
          Text(
            _t('catalogSearchNoRecent'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AColors.neutral600,
            ),
          ),
      ],
    );
  }

  Widget _buildResultCard(ProductSearchResult item) {
    final intl.NumberFormat currency = intl.NumberFormat.currency(symbol: '₪');
    final String nameHe = item.product.nameHe;
    final String nameEn = item.product.nameEn;
    final String sku = item.product.sku.isNotEmpty
        ? item.product.sku
        : item.variant.barcode ?? '';
    final String? imageUrl = resolvePrimaryImage(
      item.product,
      variant: item.variant,
    );
    final Map<String, String> attributeMap =
        extractDisplayAttributes(item.variant);
    final String attributes = attributeMap.entries
        .take(2)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' · ');
    final String skuLabel = _t('productSkuLabel');
    final TextDirection direction = Directionality.of(context);
    final bool isRtl = direction == TextDirection.rtl;
    final bool isAdding = _addingVariantIds.contains(item.variant.id);

    final List<Widget> trailingChildren = <Widget>[];
    if (item.unitPrice != null) {
      trailingChildren.add(
        Align(
          alignment: isRtl
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ASpacing.md,
              vertical: ASpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AColors.primary.withValues(alpha: 0.12),
              borderRadius: ARadii.md,
            ),
            child: Text(
              currency.format(item.unitPrice),
              style: ATypography.bodyMd.copyWith(
                color: AColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      trailingChildren.add(const SizedBox(height: ASpacing.sm));
    }
    trailingChildren.add(
      AButton.primary(
        expand: true,
        label: _t('catalogSearchAddToCart'),
        icon: const Icon(Icons.add_shopping_cart_outlined),
        loading: isAdding,
        onPressed: isAdding ? null : () => _handleAddToCart(item),
      ),
    );

    return ACard(
      margin: const EdgeInsets.symmetric(
        horizontal: ASpacing.lg,
        vertical: ASpacing.sm,
      ),
      onTap: () => context.pushNamed(
        'product',
        pathParameters: <String, String>{'id': item.product.id},
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: direction,
        children: [
          AProductImage.square(
            imageUrl: imageUrl,
            size: 72,
          ),
          const SizedBox(width: ASpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nameHe.isNotEmpty)
                  _highlightedRichText(nameHe, style: ATypography.titleSm),
                if (nameEn.isNotEmpty && nameEn != nameHe) ...[
                  const SizedBox(height: ASpacing.xs),
                  _highlightedRichText(nameEn, style: ATypography.bodyMd),
                ],
                if (attributes.isNotEmpty) ...[
                  const SizedBox(height: ASpacing.xs),
                  _highlightedRichText(attributes, style: ATypography.bodySm),
                ],
                const SizedBox(height: ASpacing.xs),
                RichText(
                  text: TextSpan(
                    style: ATypography.bodySm.copyWith(
                      color: AColors.neutral600,
                    ),
                    children: [
                      TextSpan(text: '$skuLabel: '),
                      ..._buildHighlightSpans(sku),
                    ],
                  ),
                ),
                if (item.inventoryQty != null)
                  Padding(
                    padding: const EdgeInsets.only(top: ASpacing.xs),
                    child: Text(
                      '${_t('filterInStockOnly')}: ${item.inventoryQty!.toStringAsFixed(0)}',
                      style: ATypography.bodySm,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: ASpacing.lg),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Column(
                crossAxisAlignment:
                    isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: trailingChildren,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _activeTokens => _activeQuery
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList();

  List<TextSpan> _buildHighlightSpans(String source) {
    final List<String> tokens = _activeTokens;
    if (tokens.isEmpty || source.isEmpty) {
      return <TextSpan>[TextSpan(text: source)];
    }
    final List<String> tokensLower = tokens
        .map((token) => token.toLowerCase())
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokensLower.isEmpty) {
      return <TextSpan>[TextSpan(text: source)];
    }
    final String lowerSource = source.toLowerCase();
    final TextStyle highlightStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: AColors.primary,
    );
    final List<TextSpan> spans = <TextSpan>[];
    int index = 0;
    while (index < source.length) {
      int matchIndex = -1;
      int matchLength = 0;
      for (final String token in tokensLower) {
        final int candidate = lowerSource.indexOf(token, index);
        if (candidate != -1 && (matchIndex == -1 || candidate < matchIndex)) {
          matchIndex = candidate;
          matchLength = token.length;
        }
      }
      if (matchIndex == -1 || matchLength == 0) {
        spans.add(TextSpan(text: source.substring(index)));
        break;
      }
      if (matchIndex > index) {
        spans.add(TextSpan(text: source.substring(index, matchIndex)));
      }
      final int matchEnd = matchIndex + matchLength;
      spans.add(TextSpan(
        text: source.substring(matchIndex, matchEnd),
        style: highlightStyle,
      ));
      index = matchEnd;
    }
    return spans;
  }

  Widget _highlightedRichText(String text, {TextStyle? style}) {
    return RichText(
      textDirection: Directionality.of(context),
      text: TextSpan(
        style: style ?? ATypography.bodyMd,
        children: _buildHighlightSpans(text),
      ),
    );
  }

  Widget _buildResults() {
    return _results.when(
      loading: _buildSkeletons,
      error: (error, _) => _buildStateWithSkeleton(
        icon: Icons.error_outline,
        title: _t('catalogSearchError'),
        message: error.toString(),
        primaryLabel: _t('catalogSearchRetry'),
        onPrimaryPressed: () => _triggerSearch(reset: true),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _buildStateWithSkeleton(
            icon: Icons.search_off,
            title: _t('catalogSearchEmpty'),
          );
        }
        return _buildResultsList(items);
      },
    );
  }

  Widget _buildResultsList(List<ProductSearchResult> items) {
    final int itemCount = items.length + (_isLoadingMore ? 1 : 0);
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: ASpacing.xxl),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return _buildLoadingMoreTile();
        }
        final ProductSearchResult item = items[index];
        return _buildResultCard(item);
      },
    );
  }

  Widget _buildLoadingMoreTile() {
    if (!_isLoadingMore) {
      return const SizedBox(height: ASpacing.xxl);
    }
    return const Padding(
      padding: EdgeInsets.fromLTRB(ASpacing.lg, 0, ASpacing.lg, ASpacing.lg),
      child: ACard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ASkeleton(width: 56, height: 56),
                SizedBox(width: ASpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ASkeleton(width: double.infinity, height: 16),
                      SizedBox(height: ASpacing.sm),
                      ASkeleton(width: 180, height: 14),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ASpacing.md),
            ASkeleton(width: double.infinity, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStateWithSkeleton({
    required IconData icon,
    required String title,
    String? message,
    String? primaryLabel,
    VoidCallback? onPrimaryPressed,
  }) {
    final TextDirection direction = Directionality.of(context);
    final AlignmentDirectional skeletonAlignment =
        direction == TextDirection.rtl
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart;
    final List<Widget> actions = <Widget>[];
    if (primaryLabel != null && onPrimaryPressed != null) {
      actions.add(
          AButton.primary(label: primaryLabel, onPressed: onPrimaryPressed));
    }

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(ASpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 52, color: AColors.primary),
              const SizedBox(height: ASpacing.lg),
              Text(
                title,
                style: ATypography.titleMd,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: ASpacing.sm),
                Text(
                  message,
                  style: ATypography.bodySm,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: ASpacing.lg),
              Align(
                alignment: skeletonAlignment,
                child: SizedBox(
                  width: 320,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      ASkeleton(width: double.infinity, height: 14),
                      SizedBox(height: ASpacing.xs),
                      ASkeleton(width: double.infinity, height: 14),
                      SizedBox(height: ASpacing.xs),
                      ASkeleton(width: 200, height: 14),
                    ],
                  ),
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: ASpacing.lg),
                Wrap(
                  spacing: ASpacing.sm,
                  runSpacing: ASpacing.sm,
                  alignment: WrapAlignment.center,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletons() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.lg,
        vertical: ASpacing.lg,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final TextDirection direction = Directionality.of(context);
        final bool isRtl = direction == TextDirection.rtl;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == 3 ? 0 : ASpacing.lg,
          ),
          child: ACard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: direction,
              children: [
                const ASkeleton(width: 72, height: 72, borderRadius: ARadii.md),
                const SizedBox(width: ASpacing.lg),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ASkeleton(width: 200, height: 18),
                      SizedBox(height: ASpacing.sm),
                      ASkeleton(width: 160, height: 16),
                      SizedBox(height: ASpacing.sm),
                      ASkeleton(width: double.infinity, height: 12),
                    ],
                  ),
                ),
                const SizedBox(width: ASpacing.lg),
                Flexible(
                  flex: 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Column(
                      crossAxisAlignment: isRtl
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        ASkeleton(width: 120, height: 22),
                        SizedBox(height: ASpacing.sm),
                        ASkeleton(
                          width: double.infinity,
                          height: 40,
                          borderRadius: ARadii.pill,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('catalogSearchTitle')),
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildResults(),
            ),
          ),
        ],
      ),
    );
  }
}
