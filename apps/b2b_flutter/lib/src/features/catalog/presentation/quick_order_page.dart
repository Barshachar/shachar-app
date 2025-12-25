import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/async_value_x.dart';
import 'package:ashachar_marketplace/src/features/catalog/data/catalog_repository.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/product_media_utils.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart'
    show priceResolutionServiceProvider;
import 'package:offline_toolkit/offline_toolkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _BulkStatus {
  matched,
  adjusted,
  ambiguous,
  notFound,
  error,
  added,
}

enum QuickNavTab {
  quickOrder,
  reorders,
  catalog,
  categories,
  promotions,
  cart,
  checkout,
}

@visibleForTesting
dynamic quickOrderCreateBulkReviewRow({
  required String code,
  required ProductSearchResult match,
  double requestedQuantity = 1,
  double quantity = 1,
  bool packQuantity = false,
  String? quantityToken,
  String? message,
  List<ProductSearchResult> suggestions = const <ProductSearchResult>[],
}) {
  assert(() {
    return true;
  }());
  return _BulkReviewRow(
    code: code,
    requestedQuantity: requestedQuantity,
    quantity: quantity,
    packQuantity: packQuantity,
    quantityToken: quantityToken,
    status: _BulkStatus.matched,
    match: match,
    message: message,
    suggestions: suggestions,
  );
}

class _BulkReviewRow {
  _BulkReviewRow({
    required this.code,
    required this.requestedQuantity,
    required this.quantity,
    required this.status,
    this.packQuantity = false,
    this.quantityToken,
    this.match,
    this.message,
    this.suggestions = const <ProductSearchResult>[],
  });

  final String code;
  final double requestedQuantity;
  final double quantity;
  final bool packQuantity;
  final String? quantityToken;
  final _BulkStatus status;
  final ProductSearchResult? match;
  final String? message;
  final List<ProductSearchResult> suggestions;

  bool get canAdd =>
      (status == _BulkStatus.matched || status == _BulkStatus.adjusted) &&
      match != null;

  _BulkReviewRow copyWith({
    double? requestedQuantity,
    double? quantity,
    bool? packQuantity,
    String? quantityToken,
    _BulkStatus? status,
    ProductSearchResult? match,
    String? message,
    List<ProductSearchResult>? suggestions,
  }) {
    return _BulkReviewRow(
      code: code,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      quantity: quantity ?? this.quantity,
      packQuantity: packQuantity ?? this.packQuantity,
      quantityToken: quantityToken ?? this.quantityToken,
      status: status ?? this.status,
      match: match ?? this.match,
      message: message ?? this.message,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

class QuickOrderNavBar extends StatelessWidget {
  const QuickOrderNavBar({
    super.key,
    required this.currentTab,
    this.checkoutOrderId,
    this.onQuickTabSelected,
    this.onCheckoutUnavailable,
  });

  final QuickNavTab currentTab;
  final String? checkoutOrderId;
  final ValueChanged<QuickNavTab>? onQuickTabSelected;
  final VoidCallback? onCheckoutUnavailable;

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items = <_NavItem>[
      _NavItem(
        tab: QuickNavTab.quickOrder,
        icon: Icons.flash_on_outlined,
        label: _label(context, 'quickOrderTabQuickOrder', 'הזמנה מהירה'),
      ),
      _NavItem(
        tab: QuickNavTab.catalog,
        icon: Icons.storefront_outlined,
        label: _label(context, 'quickOrderTabCatalog', 'קטלוג'),
      ),
      _NavItem(
        tab: QuickNavTab.cart,
        icon: Icons.shopping_cart_outlined,
        label: _label(context, 'quickOrderTabCart', 'סל'),
      ),
      _NavItem(
        tab: QuickNavTab.checkout,
        icon: Icons.assignment_turned_in_outlined,
        label: _label(context, 'quickOrderTabCheckout', 'תשלום'),
      ),
    ];

    final int selectedIndex =
        items.indexWhere((item) => item.tab == currentTab).clamp(0, 3);

    return Material(
      color: AColors.surface,
      elevation: 4,
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          backgroundColor: Colors.transparent,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: items
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(
                    item.icon,
                    color: AColors.primary,
                  ),
                  label: item.label,
                ),
              )
              .toList(),
          onDestinationSelected: (int index) {
            if (index < 0 || index >= items.length) {
              return;
            }
            _handleSelection(context, items[index].tab);
          },
        ),
      ),
    );
  }

  void _handleSelection(BuildContext context, QuickNavTab tab) {
    switch (tab) {
      case QuickNavTab.quickOrder:
      case QuickNavTab.reorders:
      case QuickNavTab.categories:
        if (onQuickTabSelected != null) {
          onQuickTabSelected!(tab);
        } else {
          _goToQuickOrder(context, tab);
        }
        return;
      case QuickNavTab.catalog:
        context.go('/catalog');
        return;
      case QuickNavTab.promotions:
        context.go('/promotions');
        return;
      case QuickNavTab.cart:
        context.go('/customer/cart');
        return;
      case QuickNavTab.checkout:
        if (checkoutOrderId != null && checkoutOrderId!.isNotEmpty) {
          context.go('/customer/cart/checkout', extra: checkoutOrderId);
          return;
        }
        onCheckoutUnavailable?.call();
        _showSnack(
          context,
          _label(
            context,
            'quickOrderCheckoutUnavailable',
            'פתחו הזמנה כדי לבצע תשלום',
          ),
        );
        onQuickTabSelected?.call(QuickNavTab.cart);
        return;
    }
  }

  void _goToQuickOrder(BuildContext context, QuickNavTab tab) {
    final String? tabParam = switch (tab) {
      QuickNavTab.quickOrder => null,
      QuickNavTab.reorders => 'reorders',
      QuickNavTab.categories => 'categories',
      _ => null,
    };
    final Uri uri = Uri(
      path: '/catalog/quick-order',
      queryParameters:
          tabParam == null ? null : <String, String>{'tab': tabParam},
    );
    context.go(uri.toString());
  }

  String _label(BuildContext context, String key, String fallback) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String value = l10n?.translate(key) ?? fallback;
    return value.isEmpty ? fallback : value;
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.tab,
    required this.icon,
    required this.label,
  });
  final QuickNavTab tab;
  final IconData icon;
  final String label;
}

class _RawBulkEntry {
  _RawBulkEntry({
    required this.code,
    required this.quantity,
    this.packQuantity = false,
    this.quantityToken,
  });

  final String code;
  final double quantity;
  final bool packQuantity;
  final String? quantityToken;
}

class _ParsedQuantity {
  const _ParsedQuantity({
    required this.quantity,
    this.packQuantity = false,
    this.quantityToken,
  });

  final double quantity;
  final bool packQuantity;
  final String? quantityToken;
}

class _QuantityAdjustmentResult {
  const _QuantityAdjustmentResult({
    required this.quantity,
    required this.messages,
    required this.adjusted,
  });

  final double quantity;
  final List<String> messages;
  final bool adjusted;
}

class _UndoEntry {
  _UndoEntry({
    required this.lineId,
    required this.variantId,
    required this.previousQty,
  });

  final String lineId;
  final String variantId;
  final double previousQty;
}

class _UndoBatch {
  _UndoBatch({
    required this.orderId,
    required this.entries,
    required this.lineCount,
  });

  final String orderId;
  final List<_UndoEntry> entries;
  final int lineCount;
}

class _VariantAddRequest {
  _VariantAddRequest({required this.variant, required this.quantity});

  final ProductVariant variant;
  double quantity;
}

final quickOrderCompanyIdProvider = Provider<String>((ref) {
  try {
    final AsyncValue<Session?> sessionState =
        ref.watch(sessionControllerProvider);
    final Session? session = sessionState.valueOrNull;
    final Object? companyMeta = session?.user.appMetadata['company_id'];
    if (companyMeta is String && companyMeta.isNotEmpty) {
      return companyMeta;
    }
  } catch (error, stackTrace) {
    final bool isSupabaseUninitialized =
        error.toString().contains('Supabase.instance');
    if (!isSupabaseUninitialized) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
  return '';
});

final quickOrderCompanyCatalogProvider = FutureProvider.autoDispose
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

class QuickOrderPage extends ConsumerStatefulWidget {
  const QuickOrderPage({
    super.key,
    this.showFilters = true,
    this.autoSearch = true,
    this.initialTab = QuickNavTab.quickOrder,
  });

  @visibleForTesting
  final bool showFilters;

  @visibleForTesting
  final bool autoSearch;

  final QuickNavTab initialTab;

  @override
  ConsumerState<QuickOrderPage> createState() => _QuickOrderPageState();
}

enum QuickOrderStage {
  input,
  review,
  summary,
}

class _BulkSummary {
  const _BulkSummary({
    required this.total,
    required this.actionable,
    required this.adjusted,
    required this.requiresAttention,
    required this.added,
    required this.skipped,
  });

  final int total;
  final int actionable;
  final int adjusted;
  final int requiresAttention;
  final int added;
  final int skipped;

  bool get hasPending => requiresAttention > 0;
}

class _QuickOrderPageState extends ConsumerState<QuickOrderPage> {
  static const int _pageSize = 25;
  static const double _resultsBottomPadding = 120;
  static const double _doubleTolerance = 0.0001;
  static const Map<String, String> _packTokenAliases = <String, String>{
    'case': 'case',
    'cases': 'case',
    'pack': 'pack',
    'packs': 'pack',
    'carton': 'carton',
    'cartons': 'carton',
    'מארז': 'מארז',
    'מארזים': 'מארז',
    'קרטון': 'קרטון',
    'קרטונים': 'קרטון',
  };

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _bulkInputController = TextEditingController();

  final Map<String, double> _quantities = <String, double>{};

  AsyncValue<List<ProductSearchResult>> _results = const AsyncValue.loading();
  Timer? _debounce;
  final bool _inStockOnly = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  String? _selectedCategory;
  List<Category> _categories = const <Category>[];
  bool _categoriesLoading = false;
  String? _pendingVariantId;
  bool _submittingDraft = false;
  bool _addingBulk = false;
  bool _undoInFlight = false;
  List<_BulkReviewRow> _bulkRows = const <_BulkReviewRow>[];
  bool _isBulkParsing = false;
  String? _bulkError;
  String? _bulkInfoMessage;
  _UndoBatch? _pendingUndoBatch;
  int _sessionAdditions = 0;
  QuickOrderStage _stage = QuickOrderStage.input;
  bool _bulkFlowOpen = false;
  _BulkSummary? _lastBulkSummary;
  late QuickNavTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _loadCategories();
    if (widget.autoSearch) {
      _performSearch(reset: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _bulkInputController.dispose();
    super.dispose();
  }

  MarketplaceLocalizations? get _l10n =>
      Localizations.of<MarketplaceLocalizations>(
          context, MarketplaceLocalizations);

  String _t(String key) => _l10n?.translate(key) ?? key;

  String _localizedOrDefault(String key, String fallback) {
    final String value = _t(key);
    return value == key ? fallback : value;
  }

  Future<void> _loadCategories() async {
    setState(() => _categoriesLoading = true);
    try {
      final CatalogRepository repository = ref.read(catalogRepositoryProvider);
      final items = await repository.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = items;
        _categoriesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _categoriesLoading = false);
    }
  }

  Future<void> _performSearch({required bool reset}) async {
    final CatalogRepository repository = ref.read(catalogRepositoryProvider);
    final double? minPrice = double.tryParse(_minPriceController.text.trim());
    final double? maxPrice = double.tryParse(_maxPriceController.text.trim());

    if (reset) {
      setState(() {
        _results = const AsyncValue.loading();
        _offset = 0;
        _hasMore = true;
      });
    } else {
      if (_isLoadingMore || !_hasMore) {
        return;
      }
      setState(() => _isLoadingMore = true);
    }

    try {
      final List<ProductSearchResult> fetched = await repository.searchProducts(
        q: _searchController.text.trim(),
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
          _results = AsyncValue.data(fetched);
        } else {
          final existing = _results.value ?? <ProductSearchResult>[];
          _results =
              AsyncValue.data(<ProductSearchResult>[...existing, ...fetched]);
          _isLoadingMore = false;
        }
        _offset += fetched.length;
        _hasMore = fetched.length == _pageSize;
      });
    } catch (error, stack) {
      if (!mounted) return;
      setState(() {
        _results = AsyncValue.error(error, stack);
        _isLoadingMore = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _reviewManualInput() async {
    final List<_RawBulkEntry> entries =
        _parseManualEntries(_bulkInputController.text);
    if (entries.isEmpty) {
      setState(() {
        _bulkRows = const <_BulkReviewRow>[];
        _bulkError = _friendlyManualEmptyMessage();
        _bulkInfoMessage = null;
        _stage = QuickOrderStage.input;
      });
      return;
    }
    await _prepareBulkReview(entries);
  }

  Future<void> _handlePasteCsv() async {
    try {
      final ClipboardData? data = await Clipboard.getData('text/plain');
      final String? text = data?.text;
      if (text == null || text.trim().isEmpty) {
        if (!mounted) return;
        setState(() {
          _bulkRows = const <_BulkReviewRow>[];
          _bulkError = _friendlyClipboardEmptyMessage();
          _bulkInfoMessage = null;
          _stage = QuickOrderStage.input;
        });
        return;
      }
      final List<_RawBulkEntry> entries = _parseCsvEntries(text);
      if (entries.isEmpty) {
        if (!mounted) return;
        setState(() {
          _bulkRows = const <_BulkReviewRow>[];
          _bulkError = _friendlyCsvError();
          _bulkInfoMessage = null;
          _stage = QuickOrderStage.input;
        });
        return;
      }
      await _prepareBulkReview(entries);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bulkRows = const <_BulkReviewRow>[];
        _bulkError = _friendlyCsvError(error: error);
        _bulkInfoMessage = null;
        _stage = QuickOrderStage.input;
      });
    }
  }

  String? _normalizePackToken(String? rawToken) {
    if (rawToken == null) {
      return null;
    }
    final String lowered = rawToken.trim().toLowerCase();
    if (lowered.isEmpty) {
      return null;
    }
    return _packTokenAliases[lowered];
  }

  _ParsedQuantity _parseQuantityToken(String raw, {double defaultValue = 1}) {
    String cleaned = raw.trim();
    if (cleaned.isEmpty) {
      return _ParsedQuantity(quantity: defaultValue);
    }

    if (cleaned.startsWith(RegExp(r'^(x|X|\*)'))) {
      cleaned = cleaned.substring(1).trim();
    }

    final RegExp valueFirstPattern =
        RegExp(r'^(\d+(?:[\.,]\d+)?)(?:\s+([^\s]+))?$', unicode: true);
    final RegExp tokenFirstPattern = RegExp(
      r'^([^\s]+)\s*(?:x|X|\*)?\s*(\d+(?:[\.,]\d+)?)$',
      unicode: true,
    );

    RegExpMatch? match = valueFirstPattern.firstMatch(cleaned);
    if (match == null) {
      match = tokenFirstPattern.firstMatch(cleaned);
      if (match != null) {
        final String qtyRaw = match.group(2) ?? '';
        final double quantity =
            double.tryParse(qtyRaw.replaceAll(',', '.')) ?? defaultValue;
        final String? token = match.group(1)?.trim();
        final String? normalized = _normalizePackToken(token);
        return _ParsedQuantity(
          quantity: quantity,
          packQuantity: normalized != null,
          quantityToken: normalized,
        );
      }
    } else {
      final String qtyRaw = match.group(1) ?? '';
      final double quantity =
          double.tryParse(qtyRaw.replaceAll(',', '.')) ?? defaultValue;
      final String? token = match.group(2)?.trim();
      final String? normalized = _normalizePackToken(token);
      return _ParsedQuantity(
        quantity: quantity,
        packQuantity: normalized != null,
        quantityToken: normalized,
      );
    }

    final String digitsOnly =
        cleaned.replaceAll(RegExp(r'[^0-9\.,]+', unicode: true), '');
    final double? parsed = double.tryParse(digitsOnly.replaceAll(',', '.'));
    if (parsed != null) {
      return _ParsedQuantity(quantity: parsed);
    }
    return _ParsedQuantity(quantity: defaultValue);
  }

  List<_RawBulkEntry> _parseManualEntries(String input) {
    final List<_RawBulkEntry> entries = <_RawBulkEntry>[];
    final Iterable<String> tokens = input.split(RegExp(r'[\n,;]'));
    final RegExp primaryPattern = RegExp(
      r'^(.+?)(?:\s*(?:x|X|\*)\s*|\s+)(\d+(?:[\.,]\d+)?)(?:\s+([^\s]+))?\s*$',
      unicode: true,
    );
    final RegExp tokenLeadingPattern = RegExp(
      r'^(.+?)\s+([^\s]+)\s*(?:x|X|\*)\s*(\d+(?:[\.,]\d+)?)\s*$',
      unicode: true,
    );
    final RegExp tokenLeadingNoXPattern = RegExp(
      r'^(.+?)\s+([^\s]+)\s+(\d+(?:[\.,]\d+)?)\s*$',
      unicode: true,
    );
    for (final String token in tokens) {
      final String trimmed = token.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      String code = trimmed;
      double quantity = 1;
      bool packQuantity = false;
      String? quantityToken;
      RegExpMatch? match = primaryPattern.firstMatch(trimmed);
      if (match != null) {
        code = match.group(1)?.trim() ?? trimmed;
        final String qtyString = (match.group(2) ?? '1').replaceAll(',', '.');
        quantity = double.tryParse(qtyString) ?? 1;
        final String? tokenRaw = match.group(3)?.trim();
        final String? normalized = _normalizePackToken(tokenRaw);
        packQuantity = normalized != null;
        quantityToken = normalized;
      } else {
        match = tokenLeadingPattern.firstMatch(trimmed);
        if (match != null) {
          code = match.group(1)?.trim() ?? trimmed;
          final String qtyString = (match.group(3) ?? '1').replaceAll(',', '.');
          quantity = double.tryParse(qtyString) ?? 1;
          final String? tokenRaw = match.group(2)?.trim();
          final String? normalized = _normalizePackToken(tokenRaw);
          packQuantity = normalized != null;
          quantityToken = normalized;
        } else {
          match = tokenLeadingNoXPattern.firstMatch(trimmed);
          if (match != null) {
            code = match.group(1)?.trim() ?? trimmed;
            final String qtyString =
                (match.group(3) ?? '1').replaceAll(',', '.');
            quantity = double.tryParse(qtyString) ?? 1;
            final String? tokenRaw = match.group(2)?.trim();
            final String? normalized = _normalizePackToken(tokenRaw);
            packQuantity = normalized != null;
            quantityToken = normalized;
          }
        }
      }
      if (code.isEmpty) {
        continue;
      }
      entries.add(_RawBulkEntry(
        code: code,
        quantity: quantity,
        packQuantity: packQuantity,
        quantityToken: quantityToken,
      ));
    }
    return entries;
  }

  List<_RawBulkEntry> _parseCsvEntries(String input) {
    final List<_RawBulkEntry> entries = <_RawBulkEntry>[];
    final Iterable<String> lines = input.split(RegExp(r'[\r\n]+'));
    for (final String rawLine in lines) {
      final String line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      final List<String> parts =
          line.split(RegExp(r'[;,\t]')).map((part) => part.trim()).toList();
      if (parts.isEmpty) {
        continue;
      }
      final String code = parts.first;
      if (code.isEmpty) {
        continue;
      }
      double quantity = 1;
      bool packQuantity = false;
      String? quantityToken;
      if (parts.length > 1) {
        final _ParsedQuantity parsed =
            _parseQuantityToken(parts[1], defaultValue: quantity);
        quantity = parsed.quantity;
        packQuantity = parsed.packQuantity;
        quantityToken = parsed.quantityToken;
      }
      if (!packQuantity && parts.length > 2) {
        final _ParsedQuantity parsed = _parseQuantityToken(
          '${parts[1]} ${parts[2]}',
          defaultValue: quantity,
        );
        if (parsed.packQuantity) {
          quantity = parsed.quantity;
          packQuantity = true;
          quantityToken = parsed.quantityToken;
        }
      }
      entries.add(_RawBulkEntry(
        code: code,
        quantity: quantity,
        packQuantity: packQuantity,
        quantityToken: quantityToken,
      ));
    }
    return entries;
  }

  _BulkReviewRow _buildResolvedRow({
    required _RawBulkEntry entry,
    required ProductSearchResult match,
    required List<ProductSearchResult> suggestions,
    required _BulkStatus baseStatus,
    String? baseMessage,
  }) {
    final _QuantityAdjustmentResult adjustment =
        _applyQuantityAdjustments(entry, match);
    final List<String> messages = <String>[];
    if (baseMessage != null && baseMessage.isNotEmpty) {
      messages.add(baseMessage);
    }
    messages.addAll(adjustment.messages);

    final _BulkStatus effectiveStatus = baseStatus == _BulkStatus.matched
        ? (adjustment.adjusted ? _BulkStatus.adjusted : _BulkStatus.matched)
        : baseStatus;

    return _BulkReviewRow(
      code: entry.code,
      requestedQuantity: entry.quantity,
      quantity: adjustment.quantity,
      packQuantity: entry.packQuantity,
      quantityToken: entry.quantityToken,
      status: effectiveStatus,
      match: match,
      message: messages.isEmpty ? null : messages.join('\n'),
      suggestions: suggestions,
    );
  }

  _BulkReviewRow _rebuildRowForMatch(
    _BulkReviewRow current,
    ProductSearchResult match, {
    String? baseMessage,
  }) {
    final _RawBulkEntry entry = _RawBulkEntry(
      code: current.code,
      quantity: current.requestedQuantity,
      packQuantity: current.packQuantity,
      quantityToken: current.quantityToken,
    );

    final Iterable<ProductSearchResult> remaining = current.suggestions.where(
      (ProductSearchResult candidate) =>
          candidate.variant.id != match.variant.id,
    );
    final List<ProductSearchResult> suggestions = <ProductSearchResult>[
      match,
      ...remaining,
    ];

    return _buildResolvedRow(
      entry: entry,
      match: match,
      suggestions: suggestions,
      baseStatus: _BulkStatus.matched,
      baseMessage: baseMessage,
    );
  }

  Future<void> _prepareBulkReview(List<_RawBulkEntry> entries) async {
    setState(() {
      _isBulkParsing = true;
      _bulkError = null;
      _bulkRows = const <_BulkReviewRow>[];
    });

    final List<_BulkReviewRow> rows = <_BulkReviewRow>[];
    for (final _RawBulkEntry entry in entries) {
      final _RawBulkEntry safeEntry = _RawBulkEntry(
        code: entry.code,
        quantity: entry.quantity <= 0 ? 1 : entry.quantity,
        packQuantity: entry.packQuantity,
        quantityToken: entry.quantityToken,
      );
      try {
        final _BulkReviewRow row = await _resolveBulkEntry(safeEntry);
        rows.add(row);
      } catch (error) {
        rows.add(_BulkReviewRow(
          code: safeEntry.code,
          requestedQuantity: safeEntry.quantity,
          quantity: safeEntry.quantity,
          packQuantity: safeEntry.packQuantity,
          quantityToken: safeEntry.quantityToken,
          status: _BulkStatus.error,
          message: error.toString(),
        ));
      }
    }

    if (!mounted) return;
    setState(() {
      _bulkRows = rows;
      _isBulkParsing = false;
      if (rows.isEmpty) {
        _bulkError = _friendlyManualEmptyMessage();
        _bulkInfoMessage = null;
        _stage = QuickOrderStage.input;
      } else {
        final _BulkSummary summary = _summarizeRows(rows);
        _bulkInfoMessage = _buildReviewInfo(summary);
        _bulkError = null;
        _stage = QuickOrderStage.review;
        _lastBulkSummary = null;
      }
    });
  }

  Future<_BulkReviewRow> _resolveBulkEntry(_RawBulkEntry entry) async {
    final CatalogRepository repository = ref.read(catalogRepositoryProvider);
    final String query = entry.code.trim();
    if (query.isEmpty) {
      return _BulkReviewRow(
        code: entry.code,
        requestedQuantity: entry.quantity,
        quantity: entry.quantity,
        packQuantity: entry.packQuantity,
        quantityToken: entry.quantityToken,
        status: _BulkStatus.error,
        message: _t('quickOrderBulkStatusError'),
      );
    }
    final List<ProductSearchResult> results =
        await repository.searchProducts(q: query, limit: 10);
    if (results.isEmpty) {
      return _BulkReviewRow(
        code: entry.code,
        requestedQuantity: entry.quantity,
        quantity: entry.quantity,
        packQuantity: entry.packQuantity,
        quantityToken: entry.quantityToken,
        status: _BulkStatus.notFound,
        message: _t('quickOrderBulkStatusNotFound'),
      );
    }

    final String lowered = query.toLowerCase();
    final List<ProductSearchResult> directMatches = results.where((result) {
      final String productSku = result.product.sku.toLowerCase();
      final String? variantBarcode = result.variant.barcode?.toLowerCase();
      return productSku == lowered || variantBarcode == lowered;
    }).toList();

    if (directMatches.isNotEmpty) {
      final ProductSearchResult chosen = directMatches.first;
      if (directMatches.length == 1) {
        return _buildResolvedRow(
          entry: entry,
          match: chosen,
          suggestions: directMatches,
          baseStatus: _BulkStatus.matched,
        );
      }
      return _buildResolvedRow(
        entry: entry,
        match: chosen,
        suggestions: directMatches,
        baseStatus: _BulkStatus.ambiguous,
        baseMessage: _t('quickOrderBulkStatusAmbiguous'),
      );
    }

    return _buildResolvedRow(
      entry: entry,
      match: results.first,
      suggestions: results,
      baseStatus: _BulkStatus.ambiguous,
      baseMessage: _t('quickOrderBulkStatusNeedsReview'),
    );
  }

  String _formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toStringAsFixed(0);
    }
    return qty.toStringAsFixed(2);
  }

  bool _almostEquals(double a, double b) => (a - b).abs() <= _doubleTolerance;

  bool _isMultipleOf(double quantity, int base) {
    if (base <= 0) {
      return true;
    }
    final double modulus = quantity.remainder(base.toDouble()).abs();
    return _almostEquals(modulus, 0) || _almostEquals(modulus, base.toDouble());
  }

  String _translateWithVars(String key, Map<String, String> values) {
    String template = _t(key);
    values.forEach((String placeholder, String value) {
      template = template.replaceAll('{$placeholder}', value);
    });
    return template;
  }

  _QuantityAdjustmentResult _applyQuantityAdjustments(
    _RawBulkEntry entry,
    ProductSearchResult match,
  ) {
    double working = entry.quantity;
    final List<String> messages = <String>[];
    bool adjusted = false;

    final Product product = match.product;
    final int packSize = product.packSize < 0 ? 0 : product.packSize;
    final int moq = product.moq < 0 ? 0 : product.moq;

    if (entry.packQuantity) {
      if (packSize > 0) {
        final double converted = entry.quantity * packSize;
        final String packs = _formatQuantity(entry.quantity);
        final String units = _formatQuantity(converted);
        messages.add(
          _translateWithVars(
            'quickOrderBulkAdjustmentPackApplied',
            <String, String>{
              'packs': packs,
              'packSize': packSize.toString(),
              'units': units,
            },
          ),
        );
        if (!_almostEquals(converted, entry.quantity)) {
          adjusted = true;
        }
        working = converted;
      } else {
        messages.add(
          _translateWithVars(
            'quickOrderBulkAdjustmentPackMissing',
            <String, String>{
              'requested': _formatQuantity(entry.quantity),
            },
          ),
        );
      }
    }

    final double beforeMoq = working;
    if (moq > 0 && working < moq) {
      working = moq.toDouble();
      adjusted = true;
      messages.add(
        _translateWithVars(
          'quickOrderBulkAdjustmentRaisedMoq',
          <String, String>{
            'moq': moq.toString(),
            'requested': _formatQuantity(beforeMoq),
            'finalValue': _formatQuantity(working),
          },
        ),
      );
    }

    final double beforeMultiple = working;
    if (packSize > 0 && !_isMultipleOf(beforeMultiple, packSize)) {
      final double adjustedQty =
          (beforeMultiple / packSize).ceil().toDouble() * packSize;
      if (!_almostEquals(adjustedQty, beforeMultiple)) {
        working = adjustedQty;
        adjusted = true;
        messages.add(
          _translateWithVars(
            'quickOrderBulkAdjustmentRoundedPack',
            <String, String>{
              'packSize': packSize.toString(),
              'requested': _formatQuantity(beforeMultiple),
              'finalValue': _formatQuantity(working),
            },
          ),
        );
      }
    }

    return _QuantityAdjustmentResult(
      quantity: working,
      messages: messages,
      adjusted: adjusted,
    );
  }

  Future<void> _addAllBulkRows({
    required String companyId,
    required Set<String>? companyCatalog,
  }) async {
    final List<_BulkReviewRow> actionable = _bulkRows
        .where(
          (row) => _canAddRow(
            row,
            companyId: companyId,
            companyCatalog: companyCatalog,
          ),
        )
        .toList();
    if (actionable.isEmpty) {
      if (!mounted) return;
      final String message = _bulkRows.isEmpty
          ? _t('quickOrderBulkReviewEmpty')
          : _t('quickOrderBulkReviewConfirmPending');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    final int skippedCount = _bulkRows
        .where(
          (row) =>
              row.canAdd &&
              !_canAddRow(
                row,
                companyId: companyId,
                companyCatalog: companyCatalog,
              ),
        )
        .length;
    final int adjustedCount =
        _bulkRows.where((row) => row.status == _BulkStatus.adjusted).length;
    final int requiresAttentionCount = _bulkRows
        .where(
          (row) =>
              row.status == _BulkStatus.ambiguous ||
              row.status == _BulkStatus.notFound ||
              row.status == _BulkStatus.error,
        )
        .length;
    final _BulkSummary outcome = _BulkSummary(
      total: _bulkRows.length,
      actionable: actionable.length,
      adjusted: adjustedCount,
      requiresAttention: requiresAttentionCount,
      added: actionable.length,
      skipped: skippedCount,
    );
    final CartController cart = ref.read(cartControllerProvider.notifier);

    setState(() {
      _addingBulk = true;
      _bulkError = null;
    });

    try {
      final String orderId = await cart.ensureDraftOrder();
      final autoDisposeFutureProvider = cartLinesProvider(orderId);
      List<CartLine> beforeLines = <CartLine>[];
      try {
        beforeLines = await ref.read(autoDisposeFutureProvider.future);
      } catch (_) {
        beforeLines = <CartLine>[];
      }

      final Map<String, _VariantAddRequest> additions =
          <String, _VariantAddRequest>{};
      for (final _BulkReviewRow row in actionable) {
        final ProductVariant variant = row.match!.variant;
        additions.update(
          variant.id,
          (existing) {
            existing.quantity += row.quantity;
            return existing;
          },
          ifAbsent: () =>
              _VariantAddRequest(variant: variant, quantity: row.quantity),
        );
      }

      for (final _VariantAddRequest request in additions.values) {
        await cart.addVariant(request.variant, qty: request.quantity);
      }

      final List<CartLine> afterLines =
          await ref.read(autoDisposeFutureProvider.future);

      final Map<String, CartLine> beforeMap = <String, CartLine>{
        for (final CartLine line in beforeLines) line.variantId: line,
      };
      final Map<String, CartLine> afterMap = <String, CartLine>{
        for (final CartLine line in afterLines) line.variantId: line,
      };

      final List<_UndoEntry> undoEntries = <_UndoEntry>[];
      additions.forEach((String variantId, _VariantAddRequest request) {
        final CartLine? beforeLine = beforeMap[variantId];
        final CartLine? afterLine = afterMap[variantId];
        if (afterLine == null) {
          return;
        }
        undoEntries.add(
          _UndoEntry(
            lineId: afterLine.rowId,
            variantId: variantId,
            previousQty: beforeLine?.qty ?? 0,
          ),
        );
      });

      final Set<String> addedVariantIds = additions.keys.toSet();

      if (!mounted) return;
      setState(() {
        _bulkRows = _bulkRows.map((row) {
          final String? variantId = row.match?.variant.id;
          if (variantId != null && addedVariantIds.contains(variantId)) {
            return row.copyWith(status: _BulkStatus.added);
          }
          return row;
        }).toList();
        _addingBulk = false;
        _pendingUndoBatch = undoEntries.isEmpty
            ? null
            : _UndoBatch(
                orderId: orderId,
                entries: undoEntries,
                lineCount: additions.length,
              );
        _sessionAdditions =
            (_sessionAdditions + additions.length).clamp(0, 9999);
        _stage = QuickOrderStage.summary;
        _lastBulkSummary = outcome;
        _bulkInfoMessage = _buildOutcomeInfo(outcome);
        _bulkError = null;
      });

      if (!mounted) return;
      final SnackBarAction? undoAction = _pendingUndoBatch == null
          ? null
          : SnackBarAction(
              label: _t('quickOrderBulkUndoLabel'),
              onPressed: () {
                if (_undoInFlight) {
                  return;
                }
                _undoLastBatch();
              },
            );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('qo_add_all_result_snackbar'),
          content: Text(_buildSnackSummary(outcome)),
          action: undoAction,
        ),
      );

      await _showBulkOutcomeSheet(outcome);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _addingBulk = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_t('quickOrderAddError')}: $error')),
      );
    }
  }

  Future<void> _undoLastBatch() async {
    final _UndoBatch? batch = _pendingUndoBatch;
    if (batch == null || _undoInFlight) {
      return;
    }
    final CartController cart = ref.read(cartControllerProvider.notifier);
    setState(() {
      _undoInFlight = true;
    });
    try {
      for (final _UndoEntry entry in batch.entries) {
        if (entry.previousQty <= 0) {
          await cart.deleteLine(entry.lineId);
        } else {
          await cart.updateLineQty(entry.lineId, entry.previousQty);
        }
      }
      if (!mounted) return;
      setState(() {
        _undoInFlight = false;
        _pendingUndoBatch = null;
        _sessionAdditions =
            (_sessionAdditions - batch.lineCount).clamp(0, 9999);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('quickOrderBulkUndoDone'))),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _undoInFlight = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_t('quickOrderAddError')}: $error')),
      );
    }
  }

  void _resetToInput({bool clearText = false}) {
    setState(() {
      _bulkRows = const <_BulkReviewRow>[];
      _bulkError = null;
      _bulkInfoMessage = null;
      _lastBulkSummary = null;
      _stage = QuickOrderStage.input;
    });
    if (clearText) {
      _bulkInputController.clear();
    }
  }

  void _clearBulkReview() {
    _resetToInput(clearText: true);
  }

  bool get _shouldShowBulkFlow {
    return _bulkFlowOpen ||
        _stage != QuickOrderStage.input ||
        _bulkRows.isNotEmpty ||
        _bulkError != null ||
        _isBulkParsing ||
        (_bulkInfoMessage?.isNotEmpty ?? false);
  }

  void _openBulkFlow() {
    setState(() => _bulkFlowOpen = true);
  }

  void _dismissBulkFlow({bool clearText = false}) {
    setState(() {
      _bulkFlowOpen = false;
      _bulkRows = const <_BulkReviewRow>[];
      _bulkError = null;
      _bulkInfoMessage = null;
      _lastBulkSummary = null;
      _stage = QuickOrderStage.input;
    });
    if (clearText) {
      _bulkInputController.clear();
    }
  }

  Widget _buildBulkFlow(String companyId, Set<String>? companyCatalog) {
    final WrapAlignment alignment =
        Directionality.of(context) == TextDirection.rtl
            ? WrapAlignment.end
            : WrapAlignment.start;

    late final Widget content;
    switch (_stage) {
      case QuickOrderStage.input:
        content = _buildInputStage(alignment);
        break;
      case QuickOrderStage.review:
        content = _buildReviewStage(companyId, companyCatalog, alignment);
        break;
      case QuickOrderStage.summary:
        content = _buildSummaryStage(alignment);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _localizedOrDefault('quickOrderBulkAdd', 'הוספה מרוכזת'),
                style: ATypography.titleSm,
              ),
            ),
            IconButton(
              tooltip: _localizedOrDefault('commonClose', 'סגירה'),
              icon: const Icon(Icons.close),
              onPressed: () => _dismissBulkFlow(clearText: true),
            ),
          ],
        ),
        const SizedBox(height: ASpacing.sm),
        content,
      ],
    );
  }

  String _friendlyManualEmptyMessage() => _localizedOrDefault(
        'quickOrderBulkReviewEmptyFriendly',
        'לא נמצאו שורות. הזינו SKU וכמות (לדוגמה: DAIRY-001 x 6).',
      );

  String _friendlyClipboardEmptyMessage() => _localizedOrDefault(
        'quickOrderBulkClipboardEmptyFriendly',
        'הלוח ריק. הדביקו רשימה או העלו קובץ CSV עם שני עמודות: SKU וכמות.',
      );

  String _friendlyCsvError({Object? error}) {
    final String base = _localizedOrDefault(
      'quickOrderBulkCsvErrorFriendly',
      'לא הצלחנו לעבד את הקובץ. ודאו שהפורמט הוא CSV עם כותרות SKU,Quantity או הדביקו ישירות.',
    );
    if (error == null) {
      return base;
    }
    final String raw = error.toString();
    if (raw.contains('FormatException') || raw.contains('CSV')) {
      return '$base\nבדקו שהקובץ מקודד ב-UTF8 וללא תווים מיוחדים בכותרות.';
    }
    if (raw.contains('RangeError')) {
      return '$base\nנראה שחלק מהשורות חסרות ערכי כמות.';
    }
    return '$base\n${raw.replaceAll(RegExp(r"\s+"), ' ').trim()}';
  }

  _BulkSummary _summarizeRows(List<_BulkReviewRow> rows) {
    final int actionable = rows.where((row) => row.canAdd).length;
    final int adjusted =
        rows.where((row) => row.status == _BulkStatus.adjusted).length;
    final int requiresAttention = rows
        .where((row) =>
            row.status == _BulkStatus.ambiguous ||
            row.status == _BulkStatus.notFound ||
            row.status == _BulkStatus.error)
        .length;
    return _BulkSummary(
      total: rows.length,
      actionable: actionable,
      adjusted: adjusted,
      requiresAttention: requiresAttention,
      added: 0,
      skipped: 0,
    );
  }

  String _buildReviewInfo(_BulkSummary summary) {
    if (summary.total == 0) {
      return _friendlyManualEmptyMessage();
    }
    final String readyLabel =
        '${summary.actionable} ${_localizedOrDefault('quickOrderBulkSummaryReady', 'שורות מוכנות להוספה')}';
    final String adjustedLabel = summary.adjusted > 0
        ? ', ${summary.adjusted} ${_localizedOrDefault('quickOrderBulkSummaryAdjusted', 'כמויות עודכנו לפי MOQ/Pack')}'
        : '';
    final String needsReviewLabel = summary.requiresAttention > 0
        ? ', ${summary.requiresAttention} ${_localizedOrDefault('quickOrderBulkSummaryNeedsReview', 'דורשות בחירה ידנית')}'
        : '';
    final String intro =
        _localizedOrDefault('quickOrderBulkSummaryIntro', 'סיכום בדיקה:');
    return '$intro $readyLabel$adjustedLabel$needsReviewLabel';
  }

  String _buildOutcomeInfo(_BulkSummary summary) {
    final List<String> parts = <String>[];
    parts.add(
      '${summary.added} ${_localizedOrDefault('quickOrderBulkOutcomeAdded', 'פריטים הוספו לעגלת הטיוטה')}',
    );
    if (summary.skipped > 0) {
      parts.add(
        '${summary.skipped} ${_localizedOrDefault('quickOrderBulkOutcomeSkipped', 'שורות דולגו כי אינן זמינות לרכישה')}',
      );
    }
    if (summary.requiresAttention > 0) {
      parts.add(
        '${summary.requiresAttention} ${_localizedOrDefault('quickOrderBulkOutcomePending', 'עדיין דורשות בדיקה ידנית')}',
      );
    }
    return parts.join(' · ');
  }

  String _buildSnackSummary(_BulkSummary summary) {
    final String added =
        '${summary.added} ${_localizedOrDefault('quickOrderBulkSnackbarAdded', 'נוספו')}';
    final String skipped = summary.skipped > 0
        ? ', ${summary.skipped} ${_localizedOrDefault('quickOrderBulkSnackbarSkipped', 'דולגו')}'
        : '';
    return '$added$skipped';
  }

  Future<void> _showBulkOutcomeSheet(_BulkSummary summary) async {
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext bottomSheetContext) {
        final TextDirection direction = Directionality.of(context);
        final Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _localizedOrDefault(
                'quickOrderBulkOutcomeTitle',
                'רשימה נוספה לסל',
              ),
              style: ATypography.titleSm,
            ),
            const SizedBox(height: ASpacing.sm),
            _buildOutcomeStatRow(
              icon: Icons.playlist_add_check,
              label: _localizedOrDefault(
                'quickOrderBulkOutcomeAddedLabel',
                'הוספנו לסל',
              ),
              value: summary.added.toString(),
            ),
            if (summary.skipped > 0)
              _buildOutcomeStatRow(
                icon: Icons.block,
                label: _localizedOrDefault(
                  'quickOrderBulkOutcomeSkippedLabel',
                  'דילגנו על',
                ),
                value: summary.skipped.toString(),
              ),
            if (summary.requiresAttention > 0)
              _buildOutcomeStatRow(
                icon: Icons.help_outline,
                label: _localizedOrDefault(
                  'quickOrderBulkOutcomePendingLabel',
                  'דורש בדיקה ידנית',
                ),
                value: summary.requiresAttention.toString(),
              ),
            const SizedBox(height: ASpacing.md),
            AButton.primary(
              label: _localizedOrDefault(
                'quickOrderBulkOutcomeClose',
                'סגירה והמשך',
              ),
              onPressed: () => Navigator.of(bottomSheetContext).maybePop(),
            ),
          ],
        );

        return Directionality(
          textDirection: direction,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              ASpacing.lg,
              ASpacing.md,
              ASpacing.lg,
              ASpacing.lg,
            ),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildOutcomeStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: ASpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AColors.primary),
          const SizedBox(width: ASpacing.sm),
          Expanded(
            child: Text(
              label,
              style: ATypography.bodySm,
            ),
          ),
          Text(
            value,
            style: ATypography.titleSm,
          ),
        ],
      ),
    );
  }

  void _resumePendingRows() {
    setState(() {
      _stage = QuickOrderStage.review;
      _bulkInfoMessage = _buildReviewInfo(_summarizeRows(_bulkRows));
      _lastBulkSummary = null;
      _bulkError = null;
    });
  }

  Widget _buildInputStage(WrapAlignment alignment) {
    final ThemeData theme = Theme.of(context);
    final TextDirection direction = Directionality.of(context);
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: ARadii.lg,
      borderSide: const BorderSide(color: AColors.borderSubtle),
    );
    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: ARadii.lg,
      borderSide: const BorderSide(color: AColors.primary, width: 1.2),
    );

    return Column(
      key: const ValueKey<String>('qo_stage_input'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ACard(
          backgroundColor: AColors.surface,
          padding: const EdgeInsetsDirectional.all(ASpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _bulkInputController,
                minLines: 1,
                maxLines: 4,
                textDirection: direction,
                decoration: InputDecoration(
                  labelText: _localizedOrDefault(
                    'quickOrderBulkHint',
                    'הדביקו קודים וכמויות (SKU x כמות)',
                  ),
                  hintText: _localizedOrDefault(
                    'quickOrderBulkExample',
                    'לדוגמה: DAIRY-001 x 6',
                  ),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: focusedBorder,
                  filled: true,
                  fillColor: AColors.surfaceMuted,
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: ASpacing.md,
                    vertical: ASpacing.sm,
                  ),
                ),
              ),
              const SizedBox(height: ASpacing.sm),
              Wrap(
                spacing: ASpacing.sm,
                runSpacing: ASpacing.sm,
                alignment: alignment,
                children: [
                  AButton.primary(
                    label: _localizedOrDefault(
                      'quickOrderBulkReviewAction',
                      'בדיקת רשימה',
                    ),
                    icon: const Icon(Icons.spellcheck),
                    loading: _isBulkParsing,
                    onPressed: _isBulkParsing ? null : _reviewManualInput,
                  ),
                  AButton.secondary(
                    label: _localizedOrDefault(
                      'quickOrderBulkPasteCsv',
                      'הדבקת CSV',
                    ),
                    icon: const Icon(Icons.content_paste_go),
                    onPressed: _isBulkParsing ? null : _handlePasteCsv,
                  ),
                  AButton.text(
                    label: _localizedOrDefault(
                      'quickOrderBulkClear',
                      'ניקוי הרשימה',
                    ),
                    onPressed: _bulkInputController.text.isEmpty
                        ? null
                        : _clearBulkReview,
                  ),
                ],
              ),
              const SizedBox(height: ASpacing.sm),
              Text(
                _localizedOrDefault(
                  'quickOrderBulkTip',
                  'טיפ: ניתן להדביק מקובץ Excel או לסרוק ברקודים ברצף.',
                ),
                style: ATypography.bodySm.copyWith(
                  color: AColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        if (_bulkError != null) ...[
          const SizedBox(height: ASpacing.sm),
          ACard(
            backgroundColor: AColors.danger.withValues(alpha: 0.08),
            borderRadius: ARadii.md,
            elevation: AElevation.level0,
            padding: const EdgeInsetsDirectional.all(ASpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: AColors.danger),
                const SizedBox(width: ASpacing.sm),
                Expanded(
                  child: Text(
                    _bulkError!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_isBulkParsing) ...[
          const SizedBox(height: ASpacing.md),
          _buildBulkLoadingCard(),
        ],
        if (_bulkInfoMessage != null && _bulkInfoMessage!.isNotEmpty) ...[
          const SizedBox(height: ASpacing.md),
          _buildInfoBanner(_bulkInfoMessage!),
        ],
      ],
    );
  }

  Widget _buildInfoBanner(String message) {
    return ACard(
      backgroundColor: AColors.success.withValues(alpha: 0.08),
      borderRadius: ARadii.md,
      elevation: AElevation.level0,
      padding: const EdgeInsetsDirectional.all(ASpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AColors.success),
          const SizedBox(width: ASpacing.sm),
          Expanded(
            child: Text(
              message,
              style: ATypography.bodySm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStage(
    String companyId,
    Set<String>? companyCatalog,
    WrapAlignment alignment,
  ) {
    final _BulkSummary summary = _summarizeRows(_bulkRows);
    final String infoMessage = _bulkInfoMessage ?? _buildReviewInfo(summary);

    return Column(
      key: const ValueKey<String>('qo_stage_review'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(infoMessage),
        const SizedBox(height: ASpacing.sm),
        Align(
          alignment: alignment == WrapAlignment.end
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: TextButton.icon(
            icon: const Icon(Icons.edit),
            label: Text(
              _localizedOrDefault(
                'quickOrderBulkEditList',
                'עריכת הרשימה',
              ),
            ),
            onPressed: () {
              setState(() {
                _stage = QuickOrderStage.input;
                _bulkInfoMessage = null;
              });
            },
          ),
        ),
        const SizedBox(height: ASpacing.sm),
        if (_bulkRows.isNotEmpty)
          _buildBulkReviewCard(
            companyId: companyId,
            companyCatalog: companyCatalog,
          )
        else
          _buildInfoBanner(_friendlyManualEmptyMessage()),
      ],
    );
  }

  Widget _buildSummaryStage(
    WrapAlignment alignment,
  ) {
    final _BulkSummary? summary = _lastBulkSummary;
    final List<_BulkReviewRow> pendingRows = _bulkRows
        .where((row) => row.status != _BulkStatus.added)
        .toList(growable: false);

    return Column(
      key: const ValueKey<String>('qo_stage_summary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary != null)
          ACard(
            padding: const EdgeInsetsDirectional.all(ASpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedOrDefault(
                    'quickOrderSummaryCompleteTitle',
                    'הרשימה הועברה לעגלת הטיוטה',
                  ),
                  style: ATypography.titleSm,
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  _buildOutcomeInfo(summary),
                  style: ATypography.bodySm,
                ),
              ],
            ),
          ),
        if (pendingRows.isNotEmpty) ...[
          const SizedBox(height: ASpacing.sm),
          ACard(
            padding: const EdgeInsetsDirectional.all(ASpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedOrDefault(
                    'quickOrderSummaryPendingTitle',
                    'שורות שעדיין דורשות טיפול',
                  ),
                  style:
                      ATypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: ASpacing.sm),
                ...pendingRows.map((row) {
                  return Padding(
                    padding:
                        const EdgeInsetsDirectional.only(bottom: ASpacing.xs),
                    child: Row(
                      children: [
                        Icon(
                          _statusIcon(row.status),
                          size: 18,
                          color: _statusColor(row.status),
                        ),
                        const SizedBox(width: ASpacing.xs),
                        Expanded(
                          child: Text(
                            '${row.code} • ${_statusLabel(row.status)}',
                            style: ATypography.bodySm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
        const SizedBox(height: ASpacing.sm),
        Wrap(
          spacing: ASpacing.sm,
          runSpacing: ASpacing.sm,
          alignment: alignment,
          children: [
            AButton.primary(
              label: _localizedOrDefault(
                'quickOrderSummaryNewList',
                'התחלת רשימה חדשה',
              ),
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _resetToInput(clearText: true),
            ),
            if (pendingRows.isNotEmpty)
              AButton.secondary(
                label: _localizedOrDefault(
                  'quickOrderSummaryResolvePending',
                  'חזרה לשורות פתוחות',
                ),
                icon: const Icon(Icons.assignment_return),
                onPressed: _resumePendingRows,
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _openSuggestionsSheet(int rowIndex) async {
    if (rowIndex < 0 || rowIndex >= _bulkRows.length) {
      return;
    }
    final _BulkReviewRow row = _bulkRows[rowIndex];
    if (row.suggestions.isEmpty) {
      return;
    }

    final ProductSearchResult? picked =
        await showModalBottomSheet<ProductSearchResult>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        final TextDirection direction = Directionality.of(context);
        return Directionality(
          textDirection: direction,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ASpacing.lg,
                ASpacing.md,
                ASpacing.lg,
                ASpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _t('quickOrderBulkSuggestionTitle'),
                    style: ATypography.titleSm,
                  ),
                  const SizedBox(height: ASpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: row.suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final ProductSearchResult option =
                            row.suggestions[index];
                        final bool isSelected =
                            row.match?.variant.id == option.variant.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: ASpacing.xs,
                          ),
                          title: Text(
                            _bulkProductTitle(option),
                            style: ATypography.bodyMd,
                          ),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_t('quickOrderBulkSkuLabel')}: ${option.product.sku.isNotEmpty ? option.product.sku : (option.variant.barcode ?? option.variant.id)}',
                                style: ATypography.bodySm,
                              ),
                              if (option.variant.attributes.isNotEmpty)
                                Text(
                                  option.variant.attributes.entries
                                      .map((entry) =>
                                          '${entry.key}: ${entry.value}')
                                      .join(' · '),
                                  style: ATypography.caption,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AColors.primary)
                              : const Icon(Icons.check_circle_outline,
                                  color: AColors.neutral500),
                          onTap: () =>
                              Navigator.of(bottomSheetContext).pop(option),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: ASpacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(bottomSheetContext).maybePop(),
                      child: Text(_t('quickOrderBulkSuggestionCancel')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      final List<_BulkReviewRow> nextRows = List<_BulkReviewRow>.of(_bulkRows);
      nextRows[rowIndex] = _rebuildRowForMatch(
        nextRows[rowIndex],
        picked,
        baseMessage: _t('quickOrderBulkStatusMatchedManual'),
      );
      _bulkRows = nextRows;
    });
  }

  String _bulkProductTitle(ProductSearchResult result) {
    if (result.product.nameHe.isNotEmpty) {
      return result.product.nameHe;
    }
    if (result.product.nameEn.isNotEmpty) {
      return result.product.nameEn;
    }
    if (result.product.sku.isNotEmpty) {
      return result.product.sku;
    }
    return result.variant.id;
  }

  String _statusLabel(_BulkStatus status) {
    switch (status) {
      case _BulkStatus.matched:
        return _t('quickOrderBulkStatusMatched');
      case _BulkStatus.adjusted:
        return _t('quickOrderBulkStatusAdjusted');
      case _BulkStatus.ambiguous:
        return _t('quickOrderBulkStatusAmbiguous');
      case _BulkStatus.notFound:
        return _t('quickOrderBulkStatusNotFound');
      case _BulkStatus.error:
        return _t('quickOrderBulkStatusError');
      case _BulkStatus.added:
        return _t('quickOrderBulkStatusAdded');
    }
  }

  Color _statusColor(_BulkStatus status) {
    switch (status) {
      case _BulkStatus.matched:
      case _BulkStatus.added:
        return AColors.success;
      case _BulkStatus.adjusted:
        return AColors.warning;
      case _BulkStatus.ambiguous:
        return AColors.warning;
      case _BulkStatus.notFound:
      case _BulkStatus.error:
        return AColors.danger;
    }
  }

  IconData _statusIcon(_BulkStatus status) {
    switch (status) {
      case _BulkStatus.matched:
        return Icons.check_circle_outline;
      case _BulkStatus.adjusted:
        return Icons.rule;
      case _BulkStatus.ambiguous:
        return Icons.help_outline;
      case _BulkStatus.notFound:
        return Icons.block;
      case _BulkStatus.error:
        return Icons.error_outline;
      case _BulkStatus.added:
        return Icons.done_all;
    }
  }

  Widget _buildStatusIndicator(_BulkReviewRow row) {
    final IconData icon = _statusIcon(row.status);
    if (row.status == _BulkStatus.ambiguous ||
        row.status == _BulkStatus.notFound) {
      final Color color = _statusColor(row.status);
      return IgnorePointer(
        child: AChip(
          label: _statusLabel(row.status),
          selected: true,
          icon: icon,
          onSelected: (_) {},
          foregroundColor: color,
          backgroundColor: color.withValues(alpha: 0.08),
          selectedColor: color.withValues(alpha: 0.16),
        ),
      );
    }
    final Color color = _statusColor(row.status);
    final TextStyle style =
        ATypography.bodySm.copyWith(color: color, fontWeight: FontWeight.w600);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: ASpacing.xs),
        Flexible(
          child: Text(
            _statusLabel(row.status),
            style: style,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCell(
    _BulkReviewRow row,
    int rowIndex, {
    required bool rowNotInCatalog,
  }) {
    final ProductSearchResult? match = row.match;
    final List<Widget> children = <Widget>[_buildStatusIndicator(row)];
    final bool isWarning = row.status == _BulkStatus.adjusted;
    final TextStyle messageStyle = isWarning
        ? ATypography.bodySm.copyWith(color: AColors.warning)
        : ATypography.bodySm;
    bool messageRendered = false;

    if (row.status == _BulkStatus.ambiguous) {
      final String message =
          row.message ?? _t('quickOrderBulkStatusNeedsReview');
      children.add(const SizedBox(height: ASpacing.xs));
      children.add(
        ALabeledValue(
          label: _t('quickOrderBulkStatusDetailsLabel'),
          value: message,
          icon:
              const Icon(Icons.info_outline, color: AColors.warning, size: 18),
        ),
      );
      messageRendered = true;
    } else if (row.status == _BulkStatus.notFound) {
      final String message = row.message ?? _t('quickOrderBulkStatusNotFound');
      children.add(const SizedBox(height: ASpacing.xs));
      children.add(
        ALabeledValue(
          label: _t('quickOrderBulkStatusDetailsLabel'),
          value: message,
          icon: const Icon(Icons.search_off, color: AColors.danger, size: 18),
        ),
      );
      messageRendered = true;
    }

    if (match != null) {
      final String name = _bulkProductTitle(match);
      final String sku = match.product.sku.isNotEmpty
          ? match.product.sku
          : (match.variant.barcode ?? match.variant.id);
      children.add(const SizedBox(height: ASpacing.xs));
      children.add(Text(
        name,
        style: ATypography.bodyMd,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ));
      children.add(Text(
        '${_t('quickOrderBulkSkuLabel')}: $sku',
        style: ATypography.bodySm,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
      if (rowNotInCatalog) {
        final String label = _t('notInCatalogShort');
        children.add(const SizedBox(height: ASpacing.xs));
        children.add(
          Chip(
            key: ValueKey('qo_row_not_in_catalog_${match.variant.id}'),
            label: Text(
              label,
              style: ATypography.bodyXs.copyWith(
                color: AColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AColors.dangerSurface,
            shape: const StadiumBorder(
              side: BorderSide(color: AColors.dangerBorder),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }
    }

    if (row.suggestions.isNotEmpty) {
      final bool needsSelection = row.status == _BulkStatus.ambiguous;
      final bool canReselect = (row.status == _BulkStatus.matched ||
              row.status == _BulkStatus.adjusted) &&
          row.suggestions.length > 1;

      if (needsSelection || canReselect) {
        children.add(const SizedBox(height: ASpacing.xs));
        children.add(
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AButton.secondary(
              label: needsSelection
                  ? _t('quickOrderBulkSelectSuggestion')
                  : _t('quickOrderBulkChangeSelection'),
              icon: const Icon(Icons.list_alt),
              onPressed: () => _openSuggestionsSheet(rowIndex),
            ),
          ),
        );
      }
    }

    if (row.message != null && row.message!.isNotEmpty && !messageRendered) {
      children.add(const SizedBox(height: ASpacing.xs));
      children.add(Text(
        row.message!,
        style: messageStyle,
      ));
    }

    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildBulkQuantityCell(
    _BulkReviewRow row, {
    required int rowIndex,
    required bool enabled,
  }) {
    if (!row.canAdd || row.match == null) {
      return Text(_formatQuantity(row.quantity));
    }
    final ProductSearchResult match = row.match!;
    final bool effectiveEnabled = enabled && !_addingBulk;
    return AQtyStepper(
      key: ValueKey('qo_bulk_qty_stepper_${match.variant.id}'),
      qty: row.quantity,
      min: 1,
      step: 1,
      enabled: effectiveEnabled,
      onChanged: (value) =>
          _handleBulkQuantityChanged(rowIndex, value.toDouble()),
    );
  }

  void _handleBulkQuantityChanged(int rowIndex, double requestedQuantity) {
    if (rowIndex < 0 || rowIndex >= _bulkRows.length) {
      return;
    }
    final _BulkReviewRow current = _bulkRows[rowIndex];
    final ProductSearchResult? match = current.match;
    if (match == null) {
      return;
    }
    final _RawBulkEntry entry = _RawBulkEntry(
      code: current.code,
      quantity: requestedQuantity,
      packQuantity: current.packQuantity,
      quantityToken: current.quantityToken,
    );
    final _BulkReviewRow updated = _buildResolvedRow(
      entry: entry,
      match: match,
      suggestions: current.suggestions,
      baseStatus: _BulkStatus.matched,
    );
    setState(() {
      final List<_BulkReviewRow> nextRows = List<_BulkReviewRow>.of(_bulkRows);
      nextRows[rowIndex] = updated;
      _bulkRows = nextRows;
    });
  }

  bool _isRowNotInCatalog(
    _BulkReviewRow row, {
    required String companyId,
    required Set<String>? companyCatalog,
  }) {
    if (companyId.isEmpty || companyCatalog == null) {
      return false;
    }
    final ProductSearchResult? match = row.match;
    if (match == null) {
      return false;
    }
    return !companyCatalog.contains(match.variant.id);
  }

  bool _canAddRow(
    _BulkReviewRow row, {
    required String companyId,
    required Set<String>? companyCatalog,
  }) {
    if (!row.canAdd) {
      return false;
    }
    if (companyCatalog == null || companyId.isEmpty) {
      return row.canAdd;
    }
    final ProductSearchResult? match = row.match;
    if (match == null) {
      return false;
    }
    return companyCatalog.contains(match.variant.id);
  }

  Widget _buildBulkLoadingCard() {
    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('quickOrderBulkParsing'),
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.md),
          const ASkeleton(width: double.infinity, height: 16),
          const SizedBox(height: ASpacing.sm),
          const ASkeleton(width: double.infinity, height: 16),
          const SizedBox(height: ASpacing.sm),
          const ASkeleton(width: double.infinity, height: 16),
        ],
      ),
    );
  }

  Widget _buildBulkReviewCard({
    required String companyId,
    required Set<String>? companyCatalog,
  }) {
    final TextDirection direction = Directionality.of(context);
    final WrapAlignment alignment = direction == TextDirection.rtl
        ? WrapAlignment.end
        : WrapAlignment.start;
    final bool hasMatches = _bulkRows.any(
      (row) =>
          _canAddRow(row, companyId: companyId, companyCatalog: companyCatalog),
    );

    final TextStyle headingTextStyle = ATypography.bodyMd.copyWith(
      fontWeight: FontWeight.w600,
      color: AColors.foreground,
    );

    return ACard(
      padding: const EdgeInsetsDirectional.all(ASpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _t('quickOrderBulkReviewTitle'),
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: ASpacing.xl,
              horizontalMargin: 0,
              headingRowColor:
                  WidgetStateProperty.all<Color>(AColors.surfaceSubtle),
              headingTextStyle: headingTextStyle,
              dataTextStyle: ATypography.bodySm,
              dividerThickness: 1,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 140,
              columns: [
                DataColumn(label: Text(_t('quickOrderBulkTableHeaderCode'))),
                DataColumn(label: Text(_t('quickOrderBulkTableHeaderQty'))),
                DataColumn(label: Text(_t('quickOrderBulkTableHeaderResult'))),
              ],
              rows: List<DataRow>.generate(
                _bulkRows.length,
                (int index) {
                  final _BulkReviewRow row = _bulkRows[index];
                  final bool rowNotInCatalog = _isRowNotInCatalog(
                    row,
                    companyId: companyId,
                    companyCatalog: companyCatalog,
                  );
                  return DataRow(
                    cells: [
                      DataCell(Text(row.code)),
                      DataCell(
                        _buildBulkQuantityCell(
                          row,
                          rowIndex: index,
                          enabled: !rowNotInCatalog && row.canAdd,
                        ),
                      ),
                      DataCell(
                        _buildResultCell(
                          row,
                          index,
                          rowNotInCatalog: rowNotInCatalog,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: ASpacing.md),
          Wrap(
            spacing: ASpacing.sm,
            runSpacing: ASpacing.sm,
            alignment: alignment,
            children: [
              AButton.primary(
                key: const ValueKey('qo_add_all_btn'),
                label: _t('quickOrderBulkAddAll'),
                icon: const Icon(Icons.playlist_add),
                loading: _addingBulk,
                onPressed: _addingBulk || !hasMatches
                    ? null
                    : () => _addAllBulkRows(
                          companyId: companyId,
                          companyCatalog: companyCatalog,
                        ),
              ),
              AButton.text(
                label: _t('quickOrderBulkClear'),
                onPressed: _addingBulk ? null : _clearBulkReview,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addToDraft(ProductSearchResult item) async {
    final double qty = _quantities[item.variant.id] ?? 1;
    final cart = ref.read(cartControllerProvider.notifier);
    setState(() => _pendingVariantId = item.variant.id);
    try {
      await cart.addToCart(item.variant, qty: qty);
      if (!mounted) return;
      final String? draftId = ref.read(cartControllerProvider).draftOrderId;
      if (draftId != null) {
        ref.invalidate(cartLinesProvider(draftId));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('quickOrderAddSuccess') == 'quickOrderAddSuccess'
              ? 'נוסף לעגלה'
              : _t('quickOrderAddSuccess')),
        ),
      );
      setState(() {
        _quantities[item.variant.id] = 1;
        _sessionAdditions = (_sessionAdditions + 1).clamp(0, 9999);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_t('quickOrderAddError')}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingVariantId = null);
      }
    }
  }

  Future<void> _submitDraft() async {
    final cart = ref.read(cartControllerProvider.notifier);
    setState(() => _submittingDraft = true);
    try {
      final String orderId = await cart.submitCurrentDraft();
      if (!mounted) return;
      setState(() {
        _sessionAdditions = 0;
        _pendingUndoBatch = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('quickOrderSubmitSuccess'))),
      );
      context.go('/customer/orders/$orderId');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_t('quickOrderSubmitError')}: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingDraft = false);
      }
    }
  }

  void _setQuantity(String variantId, num value) {
    final double clamped = value.toDouble().clamp(1, 999);
    setState(() {
      _quantities[variantId] = clamped;
    });
  }

  @visibleForTesting
  void debugSetBulkRows(List<dynamic> rows) {
    assert(() {
      if (!rows.every((element) => element is _BulkReviewRow)) {
        throw ArgumentError('rows must contain _BulkReviewRow instances');
      }
      setState(() {
        _bulkRows = List<_BulkReviewRow>.from(rows.cast<_BulkReviewRow>());
        if (_bulkRows.isNotEmpty) {
          _bulkError = null;
          _bulkInfoMessage = _buildReviewInfo(_summarizeRows(_bulkRows));
          _stage = QuickOrderStage.review;
        }
      });
      return true;
    }());
  }

  @visibleForTesting
  void debugSetResults(List<ProductSearchResult> items) {
    assert(() {
      setState(() {
        _results = AsyncValue<List<ProductSearchResult>>.data(items);
        _hasMore = false;
      });
      return true;
    }());
  }

  // Filters UI handled in header/bulk sheet; legacy filter builder removed.

  Widget _buildQuantityControl(String variantId, {required bool enabled}) {
    final double quantity = _quantities[variantId] ?? 1;
    return AQtyStepper(
      key: ValueKey('qo_qty_stepper_$variantId'),
      qty: quantity,
      min: 1,
      step: 1,
      enabled: enabled,
      onChanged: (value) => _setQuantity(variantId, value),
    );
  }

  Widget _buildResultTile(
    ProductSearchResult item, {
    required String companyId,
    required Set<String>? companyCatalog,
  }) {
    final intl.NumberFormat currency = intl.NumberFormat.currency(symbol: '₪');
    final String displayName = item.product.nameHe.isNotEmpty
        ? item.product.nameHe
        : item.product.nameEn;
    final String sku = item.product.sku.isNotEmpty
        ? item.product.sku
        : (item.variant.barcode ?? '');
    final String attributes = item.variant.attributes.entries.isEmpty
        ? ''
        : item.variant.attributes.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join(' · ');
    final bool isPending = _pendingVariantId == item.variant.id;
    final String? imageUrl = resolvePrimaryImage(
      item.product,
      variant: item.variant,
    );
    final bool notInCatalog = companyId.isNotEmpty &&
        companyCatalog != null &&
        !companyCatalog.contains(item.variant.id);
    final String notInCatalogLabel = _t('notInCatalogShort');
    final double quantity = _quantities[item.variant.id] ?? 1;

    return ACard(
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: ASpacing.page,
        vertical: ASpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget imageWidget = AProductImage.square(
                imageUrl: imageUrl,
                size: 64,
                borderRadius: ARadii.md,
                placeholderIcon: Icons.inventory_2,
              );
              final Widget detailsColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: ATypography.titleSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  const SizedBox(height: ASpacing.xs),
                  Text(
                    'SKU: $sku',
                    style: ATypography.bodySm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  if (attributes.isNotEmpty) ...[
                    const SizedBox(height: ASpacing.xs),
                    Text(
                      attributes,
                      style: ATypography.bodySm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ],
                  if (notInCatalog)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: ASpacing.xs,
                      ),
                      child: Chip(
                        key: ValueKey(
                          'qo_row_not_in_catalog_${item.variant.id}',
                        ),
                        label: Text(
                          notInCatalogLabel,
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
                  if (item.inventoryQty != null) ...[
                    const SizedBox(height: ASpacing.xs),
                    Text(
                      '${_t('filterInStockOnly')}: ${item.inventoryQty!.toStringAsFixed(0)}',
                      style: ATypography.bodySm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ],
                ],
              );
              final Widget? priceTag = item.unitPrice != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: ASpacing.sm,
                            vertical: ASpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AColors.surfaceMuted,
                            borderRadius: ARadii.sm,
                            border: Border.all(color: AColors.cardBorder),
                          ),
                          child: Text(
                            currency.format(item.unitPrice),
                            style: ATypography.bodyMd.copyWith(
                              color: AColors.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (quantity > 1) ...[
                          const SizedBox(height: ASpacing.xs),
                          Text(
                            '${quantity.toStringAsFixed(0)} × ${currency.format(item.unitPrice)} = ${currency.format((item.unitPrice ?? 0) * quantity)}',
                            style: ATypography.bodyXs.copyWith(
                              color: AColors.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    )
                  : null;
              final bool stack = constraints.maxWidth < 360;
              final Widget mainRow = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageWidget,
                  const SizedBox(width: ASpacing.lg),
                  Expanded(child: detailsColumn),
                  if (!stack && priceTag != null) ...[
                    const SizedBox(width: ASpacing.md),
                    priceTag,
                  ],
                ],
              );
              if (!stack) {
                return mainRow;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mainRow,
                  if (priceTag != null) ...[
                    const SizedBox(height: ASpacing.sm),
                    priceTag,
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: ASpacing.md),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isCompactActions = constraints.maxWidth < 360;
              final Widget qtyControl = Align(
                alignment: AlignmentDirectional.centerStart,
                child: _buildQuantityControl(
                  item.variant.id,
                  enabled: !notInCatalog,
                ),
              );

              AButton buildAddButton({required bool expand}) {
                return AButton.primary(
                  label: _t('quickOrderAddButton'),
                  icon: isPending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  expand: expand,
                  onPressed: isPending || notInCatalog
                      ? null
                      : () => _addToDraft(item),
                );
              }

              if (isCompactActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    qtyControl,
                    const SizedBox(height: ASpacing.sm),
                    buildAddButton(expand: true),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: qtyControl),
                  const SizedBox(width: ASpacing.md),
                  Flexible(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: buildAddButton(expand: false),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSliver(String companyId, Set<String>? companyCatalog) {
    return _results.when(
      loading: _buildSkeletonSliver,
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            ASpacing.page,
            ASpacing.lg,
            ASpacing.page,
            _resultsBottomPadding,
          ),
          child: AStateMessage(
            icon: Icons.error_outline,
            title: _t('quickOrderAddError'),
            message: error.toString(),
            primaryLabel: _t('catalogSearchRetry'),
            onPrimaryPressed: () => _performSearch(reset: true),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                ASpacing.page,
                ASpacing.lg,
                ASpacing.page,
                _resultsBottomPadding,
              ),
              child: AStateMessage(
                icon: Icons.search,
                title: _t('quickOrderEmpty'),
              ),
            ),
          );
        }

        final bool showLoadMore = _hasMore;
        return SliverPadding(
          padding: const EdgeInsetsDirectional.only(
            bottom: _resultsBottomPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= items.length) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      ASpacing.page,
                      ASpacing.lg,
                      ASpacing.page,
                      ASpacing.lg,
                    ),
                    child: Center(
                      child: _isLoadingMore
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : AButton.secondary(
                              label: _t('quickOrderLoadMore'),
                              onPressed: () => _performSearch(reset: false),
                            ),
                    ),
                  );
                }
                final ProductSearchResult item = items[index];
                return _buildResultTile(
                  item,
                  companyId: companyId,
                  companyCatalog: companyCatalog,
                );
              },
              childCount: items.length + (showLoadMore ? 1 : 0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonSliver() {
    return SliverPadding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        ASpacing.page,
        ASpacing.lg,
        ASpacing.page,
        _resultsBottomPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const ACard(
              margin: EdgeInsetsDirectional.only(bottom: ASpacing.lg),
              padding: EdgeInsetsDirectional.all(ASpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ASkeleton(
                        width: 64,
                        height: 64,
                        borderRadius: ARadii.md,
                      ),
                      SizedBox(width: ASpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ASkeleton(width: 200, height: 16),
                            SizedBox(height: ASpacing.sm),
                            ASkeleton(width: 140, height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ASpacing.lg),
                  ASkeleton(width: 160, height: 40, borderRadius: ARadii.pill),
                ],
              ),
            );
          },
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildSubmitSection({required bool canSubmit, required bool isBusy}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Material(
        elevation: 6,
        borderRadius: ARadii.lg,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(ASpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AButton.primary(
                label: _t('quickOrderSubmitDraft'),
                icon: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: canSubmit && !isBusy ? _submitDraft : null,
              ),
              if (!canSubmit && !isBusy)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: ASpacing.xs),
                  child: Text(
                    _t('quickOrderSubmitDisabled'),
                    textAlign: TextAlign.center,
                    style: ATypography.bodyXs,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomArea({
    required bool canSubmit,
    required bool isBusy,
    required String? checkoutOrderId,
  }) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomPadding = math.max(16, mediaQuery.viewPadding.bottom);

    return Material(
      elevation: 12,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuickOrderNavBar(
              currentTab: _currentTab,
              checkoutOrderId: checkoutOrderId,
              onQuickTabSelected: (QuickNavTab tab) {
                setState(() => _currentTab = tab);
              },
              onCheckoutUnavailable: _showCheckoutUnavailableMessage,
            ),
            if (_currentTab == QuickNavTab.quickOrder)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  ASpacing.page,
                  ASpacing.sm,
                  ASpacing.page,
                  bottomPadding,
                ),
                child: _buildSubmitSection(
                  canSubmit: canSubmit,
                  isBusy: isBusy,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t('quickOrderCheckoutUnavailable'))),
    );
  }

  Widget _buildActiveTabContent(
    String companyId,
    Set<String>? companyCatalog,
    int cartItems,
    double cartTotal,
  ) {
    switch (_currentTab) {
      case QuickNavTab.quickOrder:
        return _buildQuickOrderBody(
          companyId,
          companyCatalog,
          cartItems,
          cartTotal,
        );
      case QuickNavTab.reorders:
        return _buildReorderTab();
      case QuickNavTab.categories:
        return _buildCategoriesTab();
      case QuickNavTab.catalog:
      case QuickNavTab.promotions:
      case QuickNavTab.cart:
      case QuickNavTab.checkout:
        return _buildQuickOrderBody(
          companyId,
          companyCatalog,
          cartItems,
          cartTotal,
        );
    }
  }

  Widget _buildQuickOrderBody(
    String companyId,
    Set<String>? companyCatalog,
    int cartItems,
    double cartTotal,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              ASpacing.page,
              ASpacing.lg,
              ASpacing.page,
              ASpacing.sm,
            ),
            child: _QuickOrderHeader(
              onBulkTap: _openBulkFlow,
              onSearchTap: () => context.go('/catalog/search'),
            ),
          ),
        ),
        if (widget.showFilters)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                ASpacing.page,
                ASpacing.sm,
                ASpacing.page,
                ASpacing.sm,
              ),
              child: _buildFiltersBar(),
            ),
          ),
        if (_shouldShowBulkFlow)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                ASpacing.page,
                ASpacing.sm,
                ASpacing.page,
                ASpacing.md,
              ),
              child: _buildBulkFlow(companyId, companyCatalog),
            ),
          ),
        SliverToBoxAdapter(
          child: OfflineSyncBanner(
            padding: const EdgeInsetsDirectional.fromSTEB(
              ASpacing.page,
              ASpacing.sm,
              ASpacing.page,
              ASpacing.sm,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _SummaryBanner(
            itemCount: cartItems,
            total: cartTotal,
            onTap: () => context.go('/customer/cart'),
          ),
        ),
        _buildResultsSliver(companyId, companyCatalog),
      ],
    );
  }

  Widget _buildFiltersBar() {
    final String label = _localizedOrDefault(
      'quickOrderCategoryFilter',
      'קטגוריה',
    );
    final String allLabel = _localizedOrDefault(
      'quickOrderCategoryAll',
      'כל הקטגוריות',
    );
    final List<DropdownMenuItem<String?>> items = [
      DropdownMenuItem<String?>(
        value: null,
        child: Text(allLabel),
      ),
      ..._categories.map(
        (category) => DropdownMenuItem<String?>(
          value: category.id,
          child: Text(
            category.nameHe.isNotEmpty ? category.nameHe : category.nameEn,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    return DropdownButtonFormField<String?>(
      value: _selectedCategory,
      items: items,
      isExpanded: true,
      onChanged: _categoriesLoading
          ? null
          : (String? value) {
              setState(() => _selectedCategory = value);
              _performSearch(reset: true);
            },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: ARadii.md),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: ASpacing.md,
          vertical: ASpacing.sm,
        ),
      ),
    );
  }

  Widget _buildReorderTab() {
    return _buildPlaceholder(
      icon: Icons.history,
      message: _t('quickOrderReorderEmpty'),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_categories.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.category_outlined,
        message: _t('quickOrderCategoriesEmpty'),
      );
    }

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final IconData arrowIcon = isRtl ? Icons.chevron_left : Icons.chevron_right;

    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(
        ASpacing.page,
        ASpacing.lg,
        ASpacing.page,
        120,
      ),
      itemBuilder: (BuildContext context, int index) {
        final Category category = _categories[index];
        final String name =
            category.nameHe.isNotEmpty ? category.nameHe : category.nameEn;
        return ListTile(
          key: ValueKey('quick_order_category_${category.id}'),
          title: Text(name),
          trailing: Icon(arrowIcon),
          onTap: () => _handleCategorySelected(category.id),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: _categories.length,
    );
  }

  Widget _buildPlaceholder({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: ASpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ATypography.bodyMd,
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategory = categoryId;
      _currentTab = QuickNavTab.quickOrder;
    });
    _performSearch(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final AsyncValue<List<CartLine>> cartLinesAsync =
        cartState.draftOrderId == null
            ? const AsyncValue<List<CartLine>>.data(<CartLine>[])
            : ref.watch(cartLinesProvider(cartState.draftOrderId!));

    final String companyId = ref.watch(quickOrderCompanyIdProvider);
    final AsyncValue<Set<String>?> companyCatalogAsync = companyId.isEmpty
        ? const AsyncValue<Set<String>?>.data(null)
        : ref.watch(quickOrderCompanyCatalogProvider(companyId));
    final Set<String>? companyCatalog = companyCatalogAsync.asData?.value;

    final bool hasLines = cartLinesAsync.maybeWhen(
      data: (lines) => lines.isNotEmpty,
      orElse: () => false,
    );
    final List<CartLine> cartLines =
        cartLinesAsync.asData?.value ?? const <CartLine>[];
    final double cartTotal = cartLines.fold<double>(
      0,
      (double running, CartLine line) => running + line.lineTotal,
    );

    final bool footerBusy = cartState.isLoading || _submittingDraft;
    final bool canSubmit = hasLines && _sessionAdditions > 0;
    final Widget body = _buildActiveTabContent(
      companyId,
      companyCatalog,
      cartLines.length,
      cartTotal,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(_t('quickOrderTitle'))),
      body: body,
      bottomNavigationBar: _buildBottomArea(
        canSubmit: canSubmit,
        isBusy: footerBusy,
        checkoutOrderId: cartState.draftOrderId,
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  final int itemCount;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final intl.NumberFormat currency =
        intl.NumberFormat.currency(symbol: '₪', decimalDigits: 2);
    final String itemsLabel =
        itemCount == 0 ? 'אין פריטים בסל' : '$itemCount פריטים בסל';
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        ASpacing.page,
        ASpacing.sm,
        ASpacing.page,
        ASpacing.md,
      ),
      child: InkWell(
        borderRadius: ARadii.lg,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AColors.surface,
            borderRadius: ARadii.lg,
            border: Border.all(color: AColors.cardBorder),
            boxShadow: AElevation.shadowSoft,
          ),
          padding: const EdgeInsets.all(ASpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemsLabel,
                      style: ATypography.bodyMd.copyWith(
                        color: AColors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: ASpacing.xs),
                    Text(
                      currency.format(total),
                      style: ATypography.titleMd.copyWith(
                        color: AColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ASpacing.md),
              AButton.primary(
                label: 'לסל',
                size: AButtonSize.compact,
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickOrderHeader extends StatelessWidget {
  const _QuickOrderHeader({
    required this.onBulkTap,
    required this.onSearchTap,
  });

  final VoidCallback onBulkTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title =
        l10n?.translate('quickOrderRecentTitle') ?? 'רכישות חוזרות';
    final String bulkLabel =
        l10n?.translate('quickOrderBulkAdd') ?? 'הוספה מרוכזת';
    final String searchLabel =
        l10n?.translate('homeSearchPlaceholder') ?? 'חיפוש / סריקה';

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack = constraints.maxWidth < 420;
        final Widget primary = AButton.ghost(
          label: '$title · $searchLabel',
          icon: const Icon(Icons.history),
          onPressed: onSearchTap,
          expand: true,
        );
        final Widget secondary = AButton.secondary(
          label: bulkLabel,
          icon: const Icon(Icons.upload_file_outlined),
          onPressed: onBulkTap,
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              const SizedBox(height: ASpacing.sm),
              secondary,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: primary),
            const SizedBox(width: ASpacing.sm),
            secondary,
          ],
        );
      },
    );
  }
}
