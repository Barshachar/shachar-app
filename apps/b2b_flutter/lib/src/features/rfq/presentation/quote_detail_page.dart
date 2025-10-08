import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

import 'package:ashachar_marketplace/src/features/rfq/data/rfq_repository.dart';
import 'package:ashachar_marketplace/src/features/rfq/domain/rfq_models.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_controller.dart';

class QuoteDetailPage extends ConsumerStatefulWidget {
  const QuoteDetailPage({required this.rfqId, super.key});

  final String rfqId;

  @override
  ConsumerState<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends ConsumerState<QuoteDetailPage> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _converting = false;
  String? _lastViewedQuoteId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Quote>> quotesAsync =
        ref.watch(rfqQuotesProvider(widget.rfqId));
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.yMMMMd().add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.translate('quote_title') ?? 'Quote'),
      ),
      body: quotesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, _) => Center(
          child: Text(
            l10n?.translate('rfq_error') ?? 'Unable to load quote',
            textAlign: TextAlign.center,
          ),
        ),
        data: (List<Quote> quotes) {
          if (quotes.isEmpty) {
            return Center(
              child: Text(
                l10n?.translate('quote_empty') ?? 'Waiting for vendor quotes',
                textAlign: TextAlign.center,
              ),
            );
          }
          final int safeIndex = _currentPage.clamp(0, quotes.length - 1);
          final Quote activeQuote = quotes[safeIndex];
          final RfqRepository repository = ref.read(rfqRepositoryProvider);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markQuoteViewed(repository, activeQuote.id);
          });

          return Column(
            children: [
              SizedBox(
                height: 56,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int index) async {
                    setState(() {
                      _currentPage = index;
                    });
                    final Quote selected = quotes[index];
                    await _markQuoteViewed(repository, selected.id);
                  },
                  itemCount: quotes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Quote quote = quotes[index];
                    return _QuoteVersionChip(
                      index: index,
                      quote: quote,
                      isActive: index == _currentPage,
                    );
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ASpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuoteHeader(
                        quote: activeQuote,
                        dateFormat: dateFormat,
                        l10n: l10n,
                      ),
                      const SizedBox(height: ASpacing.md),
                      _QuoteLinesTable(
                        quote: activeQuote,
                        l10n: l10n,
                      ),
                      const SizedBox(height: ASpacing.lg),
                      Semantics(
                        button: true,
                        label: l10n?.translate('rfq_to_order') ??
                            'Convert to order',
                        child: FilledButton.icon(
                          key: const ValueKey('rfq_convert_to_order_btn'),
                          onPressed: _converting
                              ? null
                              : () => _convertQuote(activeQuote, l10n),
                          icon: _converting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.shopping_cart_checkout),
                          label: Text(
                            l10n?.translate('rfq_to_order') ??
                                'Convert to order',
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _convertQuote(
    Quote quote,
    MarketplaceLocalizations? l10n,
  ) async {
    setState(() {
      _converting = true;
    });
    final RfqRepository repository = ref.read(rfqRepositoryProvider);
    try {
      await repository.convertToOrder(quote.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('rfq_result_snackbar'),
          content: Text(
            l10n?.translate('rfq_to_order_success') ?? 'Order created',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('rfq_result_snackbar'),
          content: Text(
            l10n?.translate('rfq_to_order_error') ?? 'Conversion failed',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _converting = false;
        });
      }
    }
  }

  Future<void> _markQuoteViewed(
    RfqRepository repository,
    String quoteId,
  ) async {
    if (_lastViewedQuoteId == quoteId) {
      return;
    }
    _lastViewedQuoteId = quoteId;
    await repository.getQuote(quoteId);
  }
}

class _QuoteVersionChip extends StatelessWidget {
  const _QuoteVersionChip({
    required this.index,
    required this.quote,
    required this.isActive,
  });

  final int index;
  final Quote quote;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final Color foreground = isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ASpacing.xs),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: ARadii.pill,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ASpacing.md,
          vertical: ASpacing.sm,
        ),
        child: Text(
          'v${quote.version}',
          style: theme.textTheme.labelLarge?.copyWith(color: foreground),
          softWrap: false,
        ),
      ),
    );
  }
}

class _QuoteHeader extends StatelessWidget {
  const _QuoteHeader({
    required this.quote,
    required this.dateFormat,
    required this.l10n,
  });

  final Quote quote;
  final DateFormat dateFormat;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('rfq_quote_card_${quote.id}'),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n?.translate('quote_title') ?? 'Quote'} · ${quote.currency}',
              style: Theme.of(context).textTheme.titleMedium,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: ASpacing.sm),
            Text(
              '${l10n?.translate('quote_valid_until') ?? 'Valid until'} '
              '${dateFormat.format(quote.validUntil.toLocal())}',
              style: Theme.of(context).textTheme.bodyMedium,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            if (quote.terms != null && quote.terms!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: ASpacing.sm),
                child: Text(
                  quote.terms!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuoteLinesTable extends StatelessWidget {
  const _QuoteLinesTable({required this.quote, required this.l10n});

  final Quote quote;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: <DataColumn>[
        DataColumn(
          label: Text(
            l10n?.translate('rfq_product') ?? 'Product',
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataColumn(
          numeric: true,
          label: Text(
            l10n?.translate('rfq_quantity') ?? 'Quantity',
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataColumn(
          label: Text(
            l10n?.translate('rfq_uom') ?? 'UOM',
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataColumn(
          numeric: true,
          label: Text(
            l10n?.translate('rfq_unit_price') ?? 'Unit price',
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataColumn(
          numeric: true,
          label: Text(
            l10n?.translate('rfq_lead_time') ?? 'Lead time',
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      rows: quote.lines
          .map(
            (QuoteLine line) => DataRow(
              cells: <DataCell>[
                DataCell(Text(line.sku, softWrap: false)),
                DataCell(Text(line.minQty.toString(), softWrap: false)),
                DataCell(Text(line.uom, softWrap: false)),
                DataCell(
                    Text(line.unitPrice.toStringAsFixed(2), softWrap: false)),
                DataCell(Text('${line.leadTimeDays}d', softWrap: false)),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}
