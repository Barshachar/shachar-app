import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';

import 'package:ashachar_marketplace/src/features/rfq/domain/rfq_models.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_controller.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/quote_detail_page.dart';

class RfqPage extends ConsumerStatefulWidget {
  const RfqPage({super.key});

  @override
  ConsumerState<RfqPage> createState() => _RfqPageState();
}

class _RfqPageState extends ConsumerState<RfqPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ref.listen<RfqDraftState>(rfqDraftControllerProvider, (previous, next) {
      final AsyncValue<RfqRequest?> submission = next.submission;
      final messenger = ScaffoldMessenger.of(context);
      final MarketplaceLocalizations? l10n =
          Localizations.of<MarketplaceLocalizations>(
              context, MarketplaceLocalizations);
      if (submission is AsyncData<RfqRequest?>) {
        final RfqRequest? nextValue = submission.value;
        final RfqRequest? previousValue =
            (previous?.submission is AsyncData<RfqRequest?>)
                ? (previous!.submission as AsyncData<RfqRequest?>).value
                : null;
        if (nextValue != null && nextValue != previousValue) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              key: const ValueKey('rfq_result_snackbar'),
              content: Text(
                l10n?.translate('rfq_created') ?? 'RFQ created',
              ),
            ),
          );
        }
      } else if (submission is AsyncError<RfqRequest?> &&
          previous?.submission != submission) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            key: const ValueKey('rfq_result_snackbar'),
            content: Text(
              l10n?.translate('rfq_error') ?? 'RFQ failed',
            ),
          ),
        );
      }
    });

    final RfqDraftState state = ref.watch(rfqDraftControllerProvider);
    final RfqDraftController controller =
        ref.read(rfqDraftControllerProvider.notifier);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    final DateFormat dateFormat = DateFormat.yMMMMd();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      key: const ValueKey('rfq_root'),
      appBar: AppBar(
        title: Text(l10n?.translate('rfq_title') ?? 'Request for quote'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: !state.isActive
            ? _buildEmptyState(context, controller, l10n)
            : Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool compact = constraints.maxWidth < 480;
                    return ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? ASpacing.md : ASpacing.lg,
                        vertical: ASpacing.lg,
                      ),
                      children: [
                        Wrap(
                          spacing: ASpacing.md,
                          runSpacing: ASpacing.md,
                          children: [
                            _buildRequestedDateTile(
                              context,
                              state,
                              controller,
                              l10n,
                              dateFormat,
                            ),
                            _buildCurrencyDropdown(state, controller, l10n),
                          ],
                        ),
                        const SizedBox(height: ASpacing.lg),
                        ...List<Widget>.generate(state.lines.length,
                            (int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: ASpacing.md),
                            child: _RfqLineCard(index: index),
                          );
                        }),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Semantics(
                            button: true,
                            label:
                                l10n?.translate('rfq_add_line') ?? 'Add line',
                            child: OutlinedButton.icon(
                              key: const ValueKey('rfq_line_add_btn'),
                              onPressed: controller.addLine,
                              icon: const Icon(Icons.add),
                              label: Text(
                                l10n?.translate('rfq_add_line') ?? 'Add line',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: ASpacing.lg),
                        TextFormField(
                          initialValue: state.notes,
                          maxLines: 3,
                          onChanged: controller.updateNotes,
                          decoration: InputDecoration(
                            labelText: l10n?.translate('rfq_notes_label') ??
                                'Notes for vendor',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: ASpacing.lg),
                        Semantics(
                          button: true,
                          label: l10n?.translate('rfq_submit') ?? 'Submit RFQ',
                          child: FilledButton.icon(
                            key: const ValueKey('rfq_submit_btn'),
                            onPressed:
                                state.canSubmit && !state.submission.isLoading
                                    ? () async {
                                        if (_formKey.currentState?.validate() ??
                                            true) {
                                          await controller.submit();
                                        }
                                      }
                                    : null,
                            icon: state.submission.isLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              l10n?.translate('rfq_submit') ?? 'Submit',
                            ),
                          ),
                        ),
                        if (state.lastSubmitted != null)
                          Padding(
                            padding: const EdgeInsets.only(top: ASpacing.lg),
                            child: FilledButton.tonalIcon(
                              key: const ValueKey('rfq_view_quotes_btn'),
                              onPressed: () {
                                final RfqRequest request = state.lastSubmitted!;
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) {
                                      return QuoteDetailPage(
                                        rfqId: request.id,
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility),
                              label: Text(
                                l10n?.translate('quote_title') ?? 'Quote',
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    RfqDraftController controller,
    MarketplaceLocalizations? l10n,
  ) {
    return Center(
      child: Semantics(
        button: true,
        label: l10n?.translate('rfq_create') ?? 'Create RFQ',
        child: FilledButton(
          key: const ValueKey('rfq_create_btn'),
          onPressed: controller.startNewDraft,
          child: Text(l10n?.translate('rfq_create') ?? 'Create RFQ'),
        ),
      ),
    );
  }

  Widget _buildRequestedDateTile(
    BuildContext context,
    RfqDraftState state,
    RfqDraftController controller,
    MarketplaceLocalizations? l10n,
    DateFormat dateFormat,
  ) {
    final String label =
        l10n?.translate('rfq_delivery_date') ?? 'Delivery date';
    final String value = state.requestedDate != null
        ? dateFormat.format(state.requestedDate!.toLocal())
        : l10n?.translate('rfq_select_date') ?? 'Select date';
    return Card(
      child: ListTile(
        title: Text(label, softWrap: false, overflow: TextOverflow.ellipsis),
        subtitle: Text(value),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final DateTime now = DateTime.now();
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate:
                state.requestedDate ?? now.add(const Duration(days: 7)),
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
          );
          if (picked != null) {
            controller.updateRequestedDate(picked);
          }
        },
      ),
    );
  }

  Widget _buildCurrencyDropdown(
    RfqDraftState state,
    RfqDraftController controller,
    MarketplaceLocalizations? l10n,
  ) {
    const List<String> options = <String>['USD', 'EUR', 'ILS'];
    return DropdownButtonFormField<String>(
      value: state.targetCurrency,
      decoration: InputDecoration(
        labelText: l10n?.translate('rfq_currency') ?? 'Currency',
        border: const OutlineInputBorder(),
      ),
      onChanged: (String? value) {
        if (value != null) {
          controller.updateCurrency(value);
        }
      },
      items: options
          .map((String currency) => DropdownMenuItem<String>(
                value: currency,
                child: Text(currency, softWrap: false),
              ))
          .toList(growable: false),
    );
  }
}

class _RfqLineCard extends ConsumerWidget {
  const _RfqLineCard({required this.index});

  final int index;

  static const List<_ProductOption> _options = <_ProductOption>[
    _ProductOption(
      id: 'prod-001',
      sku: 'SKU-001',
      name: 'Fresh Oranges',
      uoms: <String>['unit', 'case'],
    ),
    _ProductOption(
      id: 'prod-002',
      sku: 'SKU-002',
      name: 'Premium Olives',
      uoms: <String>['unit', 'case', 'pallet'],
    ),
    _ProductOption(
      id: 'prod-003',
      sku: 'SKU-003',
      name: 'Tahini Bulk',
      uoms: <String>['kg', 'case'],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RfqDraftState state = ref.watch(rfqDraftControllerProvider);
    final RfqDraftController controller =
        ref.read(rfqDraftControllerProvider.notifier);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    final RfqDraftLine line = state.lines[index];
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('rfq_line_${index}_product'),
                    value: line.productId.isEmpty ? null : line.productId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n?.translate('rfq_product') ?? 'Product',
                    ),
                    items: _options
                        .map((e) => DropdownMenuItem<String>(
                              value: e.id,
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            ))
                        .toList(growable: false),
                    onChanged: (String? value) {
                      if (value == null) return;
                      final _ProductOption selected =
                          _options.firstWhere((element) => element.id == value);
                      controller.updateLine(
                        index,
                        line.copyWith(
                          productId: selected.id,
                          sku: selected.sku,
                          uom: selected.uoms.first,
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: l10n?.translate('remove') ?? 'Remove',
                  onPressed: () => controller.removeLine(index),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.sm),
            Wrap(
              spacing: ASpacing.md,
              runSpacing: ASpacing.md,
              children: [
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('rfq_line_${index}_uom'),
                    value: line.uom,
                    decoration: InputDecoration(
                      labelText: l10n?.translate('rfq_uom') ?? 'UOM',
                    ),
                    items: _options
                        .firstWhere(
                          (option) =>
                              option.id ==
                              (line.productId.isEmpty
                                  ? _options.first.id
                                  : line.productId),
                          orElse: () => _options.first,
                        )
                        .uoms
                        .map((String unit) => DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit, softWrap: false),
                            ))
                        .toList(growable: false),
                    onChanged: (String? unit) {
                      if (unit == null) return;
                      controller.updateLine(index, line.copyWith(uom: unit));
                    },
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextFormField(
                    key: ValueKey('rfq_line_${index}_qty'),
                    initialValue: line.quantity.toString(),
                    decoration: InputDecoration(
                      labelText: l10n?.translate('rfq_quantity') ?? 'Quantity',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return l10n?.translate('field_required') ?? 'Required';
                      }
                      final int? parsed = int.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return l10n?.translate('rfq_qty_invalid') ??
                            'Invalid quantity';
                      }
                      return null;
                    },
                    onChanged: (String value) {
                      final int parsed = int.tryParse(value) ?? 1;
                      controller.updateLine(
                          index, line.copyWith(quantity: parsed));
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextFormField(
                    key: ValueKey('rfq_line_${index}_price'),
                    initialValue:
                        line.targetUnitPrice?.toStringAsFixed(2) ?? '',
                    decoration: InputDecoration(
                      labelText:
                          l10n?.translate('rfq_target_price') ?? 'Target price',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (String value) {
                      final double? parsed = double.tryParse(value);
                      controller.updateLine(
                        index,
                        line.copyWith(targetUnitPrice: parsed),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (line.sku.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: ASpacing.sm),
                child: Text(
                  '${l10n?.translate('rfq_sku_label') ?? 'SKU'}: ${line.sku}',
                  style: theme.textTheme.bodySmall,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductOption {
  const _ProductOption({
    required this.id,
    required this.sku,
    required this.name,
    required this.uoms,
  });

  final String id;
  final String sku;
  final String name;
  final List<String> uoms;
}
