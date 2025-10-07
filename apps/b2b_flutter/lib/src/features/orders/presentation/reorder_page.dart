import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

@immutable
class ReorderLineItem {
  const ReorderLineItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantity,
  });

  final String id;
  final String name;
  final String sku;
  final num quantity;
}

final Provider<AsyncValue<List<ReorderLineItem>>> reorderLinesProvider =
    Provider<AsyncValue<List<ReorderLineItem>>>(
  (ref) => const AsyncLoading<List<ReorderLineItem>>(),
);

class ReorderPage extends ConsumerStatefulWidget {
  const ReorderPage({super.key});

  @override
  ConsumerState<ReorderPage> createState() => _ReorderPageState();
}

class _ReorderPageState extends ConsumerState<ReorderPage> {
  final Map<String, num> _quantities = <String, num>{};

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<List<ReorderLineItem>> reorderAsync =
        ref.watch(reorderLinesProvider);

    return Scaffold(
      key: const ValueKey('reorder_root'),
      appBar: AppBar(
        title: Text(l10n?.translate('reorderTitle') ?? 'Quick reorder'),
      ),
      body: reorderAsync.when(
        loading: () => const _ReorderLoading(),
        error: (Object error, _) => _ReorderError(
          message: error.toString(),
          l10n: l10n,
          onRetry: () => ref.invalidate(reorderLinesProvider),
        ),
        data: (List<ReorderLineItem> lines) {
          if (lines.isEmpty) {
            _quantities.clear();
            return _ReorderEmpty(l10n: l10n);
          }
          _ensureQuantities(lines);
          return _ReorderContent(
            lines: lines,
            quantities: _quantities,
            l10n: l10n,
            onQuantityChanged: (String id, num value) {
              setState(() {
                _quantities[id] = value < 1 ? 1 : value;
              });
            },
          );
        },
      ),
    );
  }

  void _ensureQuantities(List<ReorderLineItem> lines) {
    final Map<String, num> next = <String, num>{
      for (final ReorderLineItem line in lines)
        line.id: _quantities[line.id] ?? line.quantity,
    };
    if (!mapEquals(_quantities, next)) {
      _quantities
        ..clear()
        ..addAll(next);
    }
  }
}

class _ReorderLoading extends StatelessWidget {
  const _ReorderLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        key: ValueKey('reorder_loading_spinner'),
      ),
    );
  }
}

class _ReorderEmpty extends StatelessWidget {
  const _ReorderEmpty({required this.l10n});

  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String title =
        l10n?.translate('reorderEmptyTitle') ?? 'No items to reorder';
    final String message = l10n?.translate('reorderEmptyMessage') ??
        'Select a previous order to add its items again.';
    return Center(
      child: AStateMessage(
        key: const ValueKey('reorder_empty_state'),
        icon: Icons.playlist_remove_outlined,
        title: title,
        message: message,
      ),
    );
  }
}

class _ReorderError extends StatelessWidget {
  const _ReorderError({
    required this.message,
    required this.l10n,
    required this.onRetry,
  });

  final String message;
  final MarketplaceLocalizations? l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String title =
        l10n?.translate('reorderErrorTitle') ?? 'Reorder unavailable';
    final String retryLabel = l10n?.translate('ordersRetry') ?? 'Try again';
    return Center(
      child: AStateMessage(
        key: const ValueKey('reorder_error_state'),
        icon: Icons.error_outline,
        title: title,
        message: message,
        primaryLabel: retryLabel,
        onPrimaryPressed: onRetry,
      ),
    );
  }
}

class _ReorderContent extends StatelessWidget {
  const _ReorderContent({
    required this.lines,
    required this.quantities,
    required this.l10n,
    required this.onQuantityChanged,
  });

  final List<ReorderLineItem> lines;
  final Map<String, num> quantities;
  final MarketplaceLocalizations? l10n;
  final void Function(String id, num value) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsetsGeometry padding =
        context.pagePadding().resolve(textDirection);
    final String addAllLabel = l10n?.translate('addAll') ?? 'Add all';
    final String itemCountTemplate =
        l10n?.translate('itemsCount') ?? '{count} items';
    final int totalLines = lines.length;
    final num totalUnits =
        quantities.values.fold<num>(0, (num acc, num value) => acc + value);
    final String summaryLabel =
        itemCountTemplate.replaceAll('{count}', totalLines.toString());
    final String totalUnitsTemplate =
        l10n?.translate('reorderTotalUnitsLabel') ?? 'Total units: {count}';
    final String totalUnitsLabel =
        totalUnitsTemplate.replaceAll('{count}', totalUnits.round().toString());
    final String snackbarTemplate = l10n?.translate('reorderAddAllSuccess') ??
        'Added {itemCount} items to cart';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                summaryLabel,
                style: ATypography.titleSm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: textDirection,
              ),
              Text(
                totalUnitsLabel,
                style: ATypography.bodySm.copyWith(color: AColors.neutral500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: textDirection,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: padding,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 640),
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        l10n?.translate('reorderTableItem') ?? 'Item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textDirection: textDirection,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n?.translate('reorderTableSku') ?? 'SKU',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textDirection: textDirection,
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n?.translate('reorderTableQuantity') ?? 'Quantity',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textDirection: textDirection,
                      ),
                    ),
                  ],
                  rows: lines
                      .map(
                        (ReorderLineItem line) => DataRow(
                          cells: [
                            DataCell(
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 320),
                                child: Text(
                                  line.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: textDirection,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                line.sku,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                textDirection: textDirection,
                              ),
                            ),
                            DataCell(
                              AQtyStepper(
                                key: ValueKey<String>(
                                  'reorder_qty_stepper_${line.id}',
                                ),
                                qty: quantities[line.id] ?? line.quantity,
                                min: 1,
                                step: 1,
                                onChanged: (num value) =>
                                    onQuantityChanged(line.id, value),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: padding,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              key: const ValueKey('reorder_add_all_btn'),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                addAllLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: textDirection,
              ),
              onPressed: () {
                final String message = snackbarTemplate.replaceAll(
                    '{itemCount}', totalUnits.round().toString());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    key: const ValueKey('reorder_add_all_result_snackbar'),
                    content: Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: textDirection,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
