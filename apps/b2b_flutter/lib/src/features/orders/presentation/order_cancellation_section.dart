import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/orders/data/supabase_order_cancellation_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_cancellation.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_cancellation_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';

class OrderCancellationSection extends ConsumerStatefulWidget {
  const OrderCancellationSection({
    super.key,
    required this.orderId,
    required this.status,
    this.cancelledAt,
    this.cancellationReason,
  });

  final String orderId;
  final String status;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  @override
  ConsumerState<OrderCancellationSection> createState() =>
      _OrderCancellationSectionState();
}

class _OrderCancellationSectionState
    extends ConsumerState<OrderCancellationSection> {
  bool _submitting = false;
  bool _queued = false;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String status = widget.status.trim();
    final bool isCancelled = _isCancelled(status);
    final bool isCancellable = _isCancellable(status);
    final bool showSection = isCancelled || isCancellable || _queued;

    if (!showSection) {
      return const SizedBox.shrink();
    }

    final bool canCancel = !_queued && !_submitting && isCancellable;
    final String title = isCancelled
        ? l10n?.translate('orderCancelStatusTitle') ?? 'Cancellation'
        : l10n?.translate('orderCancelTitle') ?? 'Cancel order';
    final String subtitle = isCancelled
        ? l10n?.translate('orderCancelStatusSubtitle') ??
            'This order has been cancelled.'
        : l10n?.translate('orderCancelSubtitle') ??
            'You can cancel this order before it ships.';

    final DateTime? cancelledAt = widget.cancelledAt;
    final String? reason = widget.cancellationReason;
    final String? reasonValue =
        reason != null && reason.trim().isNotEmpty ? reason.trim() : null;
    final Locale locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final intl.DateFormat dateFormat =
        intl.DateFormat.yMMMd(locale.toLanguageTag()).add_Hm();
    final String? cancelledAtLabel = cancelledAt != null
        ? (l10n?.translate('orderCancelCancelledAt') ?? 'Cancelled on {date}')
            .replaceAll('{date}', dateFormat.format(cancelledAt.toLocal()))
        : null;
    final String? reasonLabel = reasonValue != null
        ? (l10n?.translate('orderCancelReasonValue') ?? 'Reason: {reason}')
            .replaceAll('{reason}', reasonValue)
        : null;

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ATypography.titleSm),
          const SizedBox(height: ASpacing.xs),
          Text(
            subtitle,
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
          ),
          if (cancelledAtLabel != null) ...[
            const SizedBox(height: ASpacing.sm),
            Text(cancelledAtLabel, style: ATypography.bodySm),
          ],
          if (reasonLabel != null) ...[
            const SizedBox(height: ASpacing.xs),
            Text(reasonLabel, style: ATypography.bodySm),
          ],
          if (_queued) ...[
            const SizedBox(height: ASpacing.sm),
            Text(
              l10n?.translate('orderCancelQueued') ??
                  'Saved offline. We\'ll cancel when you\'re back online.',
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
          ],
          if (!isCancelled) ...[
            const SizedBox(height: ASpacing.md),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AButton.destructive(
                key: const ValueKey('order_detail_cancel_btn'),
                label: l10n?.translate('orderCancelButton') ?? 'Cancel order',
                loading: _submitting,
                onPressed: canCancel ? () => _handleCancel(context) : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleCancel(BuildContext context) async {
    if (_submitting) {
      return;
    }

    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final _CancelFormResult? result = await _showCancelDialog(context);
    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    final OrderCancellationRepository repository =
        ref.read(orderCancellationRepositoryProvider);

    try {
      final OrderCancellationSubmission submission =
          await repository.cancelOrder(
        orderId: widget.orderId,
        reason: result.reason,
      );

      if (!mounted) {
        return;
      }

      if (submission.queued) {
        setState(() {
          _queued = true;
        });
        final String message = l10n?.translate('orderCancelQueued') ??
            'Saved offline. We\'ll cancel when you\'re back online.';
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      } else {
        setState(() {
          _queued = false;
        });
        final String message =
            l10n?.translate('orderCancelSuccess') ?? 'Order cancelled.';
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.invalidate(orderDetailProvider(widget.orderId));
        ref.invalidate(ordersControllerProvider);
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback =
          l10n?.translate('orderCancelError') ?? 'Unable to cancel order.';
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

  Future<_CancelFormResult?> _showCancelDialog(BuildContext context) async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final TextEditingController reasonController = TextEditingController();

    final _CancelFormResult? result = await showDialog<_CancelFormResult>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n?.translate('orderCancelDialogTitle') ?? 'Cancel this order?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.translate('orderCancelDialogMessage') ??
                    'Tell us why you are cancelling (optional).',
                style: ATypography.bodySm,
              ),
              const SizedBox(height: ASpacing.md),
              TextFormField(
                controller: reasonController,
                maxLines: 2,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: l10n?.translate('orderCancelReasonLabel') ??
                      'Reason (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n?.translate('orderCancelDialogKeep') ?? 'Keep order',
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                _CancelFormResult(reason: reasonController.text),
              ),
              child: Text(
                l10n?.translate('orderCancelDialogConfirm') ?? 'Cancel order',
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

class _CancelFormResult {
  const _CancelFormResult({this.reason});

  final String? reason;
}

bool _isCancelled(String status) {
  return status.trim().toLowerCase() == 'cancelled';
}

bool _isCancellable(String status) {
  switch (status.trim().toLowerCase()) {
    case 'draft':
    case 'placed':
    case 'confirmed':
    case 'picking':
    case 'approved':
    case 'pending_approval':
      return true;
    default:
      return false;
  }
}
