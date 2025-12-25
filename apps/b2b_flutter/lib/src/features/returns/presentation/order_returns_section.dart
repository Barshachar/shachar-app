import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/presentation/status_tokens.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/returns/data/return_request_providers.dart';
import 'package:ashachar_marketplace/src/features/returns/data/supabase_return_request_repository.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request_repository.dart';

class OrderReturnsSection extends ConsumerWidget {
  const OrderReturnsSection({
    super.key,
    required this.orderId,
    required this.orderStatus,
    required this.items,
  });

  final String orderId;
  final String orderStatus;
  final List<OrderItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<List<ReturnRequest>> returnsAsync =
        ref.watch(returnRequestsProvider(orderId));
    final List<ReturnRequest> requests = returnsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <ReturnRequest>[],
    );
    final bool hasError = returnsAsync.hasError;
    final bool isLoading = returnsAsync.isLoading;
    final Map<String, List<ReturnRequest>> byItem = _groupByItemId(requests);
    final bool eligible = _isReturnEligible(orderStatus);

    final String title = l10n?.translate('orderReturnsTitle') ?? 'Returns';
    final String subtitle = l10n?.translate('orderReturnsSubtitle') ??
        'Request a return for delivered items.';
    final String errorLabel = l10n?.translate('orderReturnsFetchError') ??
        'Return history is currently unavailable.';

    return Column(
      key: const ValueKey('order_returns_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ATypography.titleMd),
        const SizedBox(height: ASpacing.xs),
        Text(
          subtitle,
          style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
        ),
        if (isLoading) ...[
          const SizedBox(height: ASpacing.md),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if (hasError) ...[
          const SizedBox(height: ASpacing.md),
          Text(
            errorLabel,
            style: ATypography.bodySm.copyWith(color: AColors.danger),
          ),
        ],
        const SizedBox(height: ASpacing.lg),
        if (!eligible)
          AStateMessage(
            icon: Icons.assignment_late_outlined,
            title: l10n?.translate('orderReturnsNotEligible') ??
                'Returns open after shipment.',
          )
        else
          ...items.map(
            (OrderItem item) => Padding(
              padding: const EdgeInsets.only(bottom: ASpacing.lg),
              child: _ReturnItemCard(
                orderId: orderId,
                item: item,
                requests: byItem[item.id] ?? const <ReturnRequest>[],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReturnItemCard extends ConsumerStatefulWidget {
  const _ReturnItemCard({
    required this.orderId,
    required this.item,
    required this.requests,
  });

  final String orderId;
  final OrderItem item;
  final List<ReturnRequest> requests;

  @override
  ConsumerState<_ReturnItemCard> createState() => _ReturnItemCardState();
}

class _ReturnItemCardState extends ConsumerState<_ReturnItemCard> {
  bool _submitting = false;
  double _queuedQty = 0;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title =
        widget.item.productName ?? widget.item.variantSku ?? widget.item.id;
    final String? sku = widget.item.variantSku;
    final double requestedQty = _sumQty(widget.requests);
    final double returnableQty =
        (widget.item.qty - requestedQty).clamp(0, widget.item.qty).toDouble();
    final double effectiveReturnableQty =
        (returnableQty - _queuedQty).clamp(0, returnableQty).toDouble();
    final bool canRequest = effectiveReturnableQty > 0 && !_submitting;

    final String quantityLabel =
        l10n?.translate('orderDetailLineQuantityLabel') ?? 'Quantity';
    final String returnableLabel =
        l10n?.translate('orderReturnsReturnableLabel') ?? 'Returnable';
    final String requestLabel =
        l10n?.translate('orderReturnsRequestButton') ?? 'Request return';
    final String queuedLabel = l10n?.translate('orderReturnsQueued') ??
        'Saved offline. We\'ll submit when you\'re back online.';
    final String noReturnableLabel =
        l10n?.translate('orderReturnsNoReturnable') ??
            'No returnable quantity left.';

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ATypography.titleSm,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          if (sku != null && sku.trim().isNotEmpty) ...[
            const SizedBox(height: ASpacing.xs),
            Text(
              '${l10n?.translate('orderDetailLineSkuLabel') ?? 'SKU'}: $sku',
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
          const SizedBox(height: ASpacing.sm),
          Text(
            '$quantityLabel: ${_formatQty(widget.item.qty)}',
            style: ATypography.bodySm,
          ),
          Text(
            '$returnableLabel: ${_formatQty(effectiveReturnableQty)}',
            style: ATypography.bodySm,
          ),
          if (widget.requests.isNotEmpty) ...[
            const SizedBox(height: ASpacing.md),
            Text(
              l10n?.translate('orderReturnsExistingLabel') ??
                  'Existing requests',
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
            const SizedBox(height: ASpacing.xs),
            ...widget.requests.map(
              (ReturnRequest request) => Padding(
                padding: const EdgeInsets.only(bottom: ASpacing.xs),
                child: _ReturnStatusRow(
                  status: request.status,
                  qty: request.qty,
                  l10n: l10n,
                  note: request.resolutionNote,
                ),
              ),
            ),
          ],
          if (_queuedQty > 0) ...[
            const SizedBox(height: ASpacing.sm),
            Text(
              queuedLabel,
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
          ],
          if (!canRequest && effectiveReturnableQty <= 0) ...[
            const SizedBox(height: ASpacing.sm),
            Text(
              noReturnableLabel,
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
          ],
          const SizedBox(height: ASpacing.md),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AButton.secondary(
              key: ValueKey<String>(
                  'order_return_request_button_${widget.item.id}'),
              label: requestLabel,
              loading: _submitting,
              onPressed: canRequest
                  ? () => _handleRequest(context, effectiveReturnableQty)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRequest(BuildContext context, double maxQty) async {
    if (_submitting || maxQty <= 0) {
      return;
    }
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final _ReturnFormResult? result = await _showReturnDialog(context, maxQty);
    if (result == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = true;
    });
    final ReturnRequestRepository repository =
        ref.read(returnRequestRepositoryProvider);

    try {
      final ReturnRequestSubmission submission =
          await repository.submitReturnRequest(
        orderId: widget.orderId,
        orderItemId: widget.item.id,
        qty: result.qty,
        reason: result.reason,
      );

      if (!mounted) {
        return;
      }

      if (submission.queued) {
        setState(() {
          _queuedQty = (_queuedQty + result.qty).clamp(0, maxQty).toDouble();
        });
        final String message = l10n?.translate('orderReturnsQueued') ??
            'Saved offline. We\'ll submit when you\'re back online.';
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      } else {
        setState(() {
          _queuedQty = 0;
        });
        final String message = l10n?.translate('orderReturnsSubmitted') ??
            'Return request submitted.';
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.invalidate(returnRequestsProvider(widget.orderId));
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback = l10n?.translate('orderReturnsError') ??
          'Unable to submit return request.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$fallback $error')));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<_ReturnFormResult?> _showReturnDialog(
    BuildContext context,
    double maxQty,
  ) async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final TextEditingController reasonController = TextEditingController();
    final double step = maxQty < 1 ? maxQty : 1;
    final double min = maxQty < 1 ? maxQty : 1;
    double selectedQty = min;

    final _ReturnFormResult? result = await showDialog<_ReturnFormResult>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n?.translate('orderReturnsDialogTitle') ?? 'Request a return',
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              final String maxLabel =
                  l10n?.translate('orderReturnsMaxHint') ?? 'Max {max}';
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maxLabel.replaceAll('{max}', _formatQty(maxQty)),
                    style: ATypography.bodySm
                        .copyWith(color: AColors.mutedForeground),
                  ),
                  const SizedBox(height: ASpacing.sm),
                  AQtyStepper(
                    qty: selectedQty,
                    min: min,
                    step: step,
                    enabled: maxQty > 0,
                    onChanged: (num value) {
                      final double next = value.toDouble();
                      final double clamped = next.clamp(min, maxQty).toDouble();
                      setState(() {
                        selectedQty = clamped;
                      });
                    },
                  ),
                  const SizedBox(height: ASpacing.md),
                  TextFormField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: l10n?.translate('orderReturnsReasonLabel') ??
                          'Reason (optional)',
                      hintText: l10n?.translate('orderReturnsReasonHint') ??
                          'Tell us why you are returning this item.',
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n?.translate('orderReturnsCancel') ?? 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                _ReturnFormResult(
                  qty: selectedQty,
                  reason: reasonController.text,
                ),
              ),
              child: Text(
                l10n?.translate('orderReturnsSubmit') ?? 'Submit request',
              ),
            ),
          ],
        );
      },
    );

    reasonController.dispose();
    return result;
  }
}

class _ReturnStatusRow extends StatelessWidget {
  const _ReturnStatusRow({
    required this.status,
    required this.qty,
    required this.l10n,
    this.note,
  });

  final String status;
  final double qty;
  final MarketplaceLocalizations? l10n;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final StatusChipStyle style = resolveStatusChipStyle(
      status: status,
      l10n: l10n,
    );
    final String qtyLabel = _formatQty(qty);
    final String? noteValue =
        note != null && note!.trim().isNotEmpty ? note!.trim() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: ARadii.sm,
                border: Border.all(
                  color: style.foreground.withValues(alpha: 0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ASpacing.sm,
                  vertical: ASpacing.xs,
                ),
                child: Text(
                  style.label,
                  style: ATypography.bodySm.copyWith(color: style.foreground),
                ),
              ),
            ),
            const SizedBox(width: ASpacing.sm),
            Text(qtyLabel, style: ATypography.bodySm),
          ],
        ),
        if (noteValue != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: ASpacing.xs,
              top: ASpacing.xs,
            ),
            child: Text(
              noteValue,
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
          ),
      ],
    );
  }
}

class _ReturnFormResult {
  const _ReturnFormResult({
    required this.qty,
    this.reason,
  });

  final double qty;
  final String? reason;
}

Map<String, List<ReturnRequest>> _groupByItemId(
  List<ReturnRequest> requests,
) {
  final Map<String, List<ReturnRequest>> grouped = {};
  for (final ReturnRequest request in requests) {
    grouped.putIfAbsent(request.orderItemId, () => []).add(request);
  }
  return grouped;
}

double _sumQty(List<ReturnRequest> requests) {
  double total = 0;
  for (final ReturnRequest request in requests) {
    total += request.qty;
  }
  return total;
}

bool _isReturnEligible(String status) {
  final String normalized = status.trim().toLowerCase();
  return normalized == 'shipped' || normalized == 'delivered';
}

String _formatQty(num value) {
  final double d = value.toDouble();
  if (d == d.roundToDouble()) {
    return d.toInt().toString();
  }
  return d
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\\.$'), '');
}
