import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/presentation/status_tokens.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/widgets/approval_status_banner.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/checkout_page.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/widgets/order_status_chip.dart';

// UI-only enums & models (private)
enum _UiApprovalStepStatus { approved, pending, rejected }

class _UiApprovalStep {
  const _UiApprovalStep({
    required this.id,
    required this.status,
    this.note,
    this.approverName,
    this.decidedAt,
  });

  final String id;
  final _UiApprovalStepStatus status;
  final String? note;
  final String? approverName;
  final DateTime? decidedAt;
}

typedef UiApprovalStep = _UiApprovalStep;

typedef _LabelAndColor = ({String label, Color foreground, Color background});

final approvalTimelineProvider =
    Provider.autoDispose.family<List<_UiApprovalStep>, String>((ref, orderId) {
  final OrderApprovalState? state =
      ref.watch(orderApprovalProvider(orderId)).maybeWhen(
            data: (value) => value,
            orElse: () => null,
          );
  if (state == null) {
    return const <_UiApprovalStep>[];
  }

  final OrderApprovalStage stage = state.stage;
  if (stage == OrderApprovalStage.notRequired ||
      stage == OrderApprovalStage.readyToRequest) {
    return const <_UiApprovalStep>[];
  }

  final _UiApprovalStepStatus status;
  switch (stage) {
    case OrderApprovalStage.pending:
      status = _UiApprovalStepStatus.pending;
      break;
    case OrderApprovalStage.approved:
      status = _UiApprovalStepStatus.approved;
      break;
    case OrderApprovalStage.rejected:
      status = _UiApprovalStepStatus.rejected;
      break;
    case OrderApprovalStage.notRequired:
    case OrderApprovalStage.readyToRequest:
      return const <_UiApprovalStep>[];
  }

  final DateTime? decidedAt = stage == OrderApprovalStage.pending
      ? state.sentAt
      : state.resolvedAt ?? state.sentAt;

  return <_UiApprovalStep>[
    _UiApprovalStep(
      id: 'stage',
      status: status,
      note: state.note,
      approverName: null,
      decidedAt: decidedAt,
    ),
  ];
});

UiApprovalStep createUiApprovalStep({
  required String id,
  required String status,
  String? note,
  String? approverName,
  DateTime? decidedAt,
}) {
  return _UiApprovalStep(
    id: id,
    status: _parseUiStatus(status),
    note: note,
    approverName: approverName,
    decidedAt: decidedAt,
  );
}

_UiApprovalStepStatus _parseUiStatus(String raw) {
  final String normalized = raw.trim().toLowerCase();
  switch (normalized) {
    case 'approved':
      return _UiApprovalStepStatus.approved;
    case 'rejected':
      return _UiApprovalStepStatus.rejected;
    case 'pending':
    default:
      return _UiApprovalStepStatus.pending;
  }
}

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<OrderDetail> orderAsync =
        ref.watch(orderDetailProvider(orderId));

    Future<void> handleReorder() async {
      final controller = ref.read(orderActionsControllerProvider);
      try {
        await controller.reorderOrder(orderId, context: context);
      } catch (error) {
        if (!context.mounted) {
          return;
        }
        final messenger = ScaffoldMessenger.maybeOf(context);
        final String template = l10n?.translate('orderDetailReorderError') ??
            "Couldn't reorder this order. Error: {message}";
        final String message = template.replaceAll('{message}', '$error');
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    }

    void triggerReorder() {
      unawaited(handleReorder());
    }

    return Scaffold(
      key: const ValueKey('order_detail_root'),
      appBar: AppBar(
        title: Text(
          l10n?.translate('orderDetailTitle') ?? 'Order Detail',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
      body: orderAsync.when(
        loading: () => const _OrderDetailLoading(),
        error: (Object error, _) => AStateMessage(
          icon: Icons.error_outline,
          title: l10n?.translate('ordersError') ?? 'Failed to load orders',
          message: error.toString(),
          primaryLabel: l10n?.translate('ordersRetry') ?? 'Try again',
          onPrimaryPressed: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
        data: (OrderDetail detail) {
          final bool canReorder = detail.items.isNotEmpty;
          final AsyncValue<OrderApprovalState> approvalAsync =
              ref.watch(orderApprovalProvider(detail.id));
          return RepaintBoundary(
            key: const ValueKey('order_detail_capture'),
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(orderApprovalProvider(detail.id));
                ref.invalidate(orderDetailProvider(orderId));
                await ref.read(orderDetailProvider(orderId).future);
              },
              child: _OrderDetailBody(
                detail: detail,
                l10n: l10n,
                onReorder: triggerReorder,
                reorderEnabled: canReorder,
                approvalAsync: approvalAsync,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerStatefulWidget {
  const _OrderDetailBody({
    required this.detail,
    required this.l10n,
    required this.onReorder,
    required this.reorderEnabled,
    required this.approvalAsync,
  });

  final OrderDetail detail;
  final MarketplaceLocalizations? l10n;
  final VoidCallback onReorder;
  final bool reorderEnabled;
  final AsyncValue<OrderApprovalState> approvalAsync;

  @override
  ConsumerState<_OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends ConsumerState<_OrderDetailBody> {
  bool _isSendingApproval = false;

  @override
  Widget build(BuildContext context) {
    final String localeName = _resolveLocale(context);
    final intl.NumberFormat currencyFormat =
        intl.NumberFormat.simpleCurrency(locale: localeName);
    final intl.DateFormat dateFormat =
        intl.DateFormat.yMMMMd(localeName).add_Hm();
    final TextDirection textDirection = Directionality.of(context);
    final String createdLabel =
        dateFormat.format(widget.detail.createdAt.toLocal());
    final List<Widget> approvalWidgets = widget.approvalAsync.when(
      data: (OrderApprovalState state) => _buildApprovalWidgets(context, state),
      loading: () => const <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(bottom: ASpacing.md),
          child: LinearProgressIndicator(minHeight: 2),
        ),
      ],
      error: (Object error, _) {
        final String message = widget.l10n?.translate('approvalBannerError') ??
            'Could not load approval status.';
        return <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: ASpacing.md),
            child: Text(
              message,
              style: ATypography.bodySm.copyWith(color: AColors.danger),
            ),
          ),
        ];
      },
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.pagePadding().resolve(Directionality.of(context)),
      children: [
        ...approvalWidgets,
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool stack = constraints.maxWidth < 360;
                  final Widget title = Text(
                    widget.detail.orderNumber,
                    style: ATypography.titleLg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textDirection: textDirection,
                  );
                  final Widget statusChip = OrderStatusChip(
                    status: widget.detail.status,
                    l10n: widget.l10n,
                  );
                  if (stack) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: ASpacing.sm),
                        statusChip,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: ASpacing.sm),
                      statusChip,
                    ],
                  );
                },
              ),
              const SizedBox(height: ASpacing.md),
              ALabeledValue(
                label: widget.l10n?.translate('orderDetailCreatedAt') ??
                    'Created at',
                value: createdLabel,
                icon: const Icon(
                  Icons.schedule,
                  size: 18,
                  color: AColors.neutral400,
                ),
              ),
              const SizedBox(height: ASpacing.lg),
              _TotalsSection(
                detail: widget.detail,
                currencyFormat: currencyFormat,
                l10n: widget.l10n,
              ),
              const SizedBox(height: ASpacing.lg),
              AButton.primary(
                key: const ValueKey('order_detail_reorder_btn'),
                expand: true,
                label: widget.l10n?.translate('reorder') ?? 'Reorder',
                icon: const Icon(Icons.replay_outlined, size: 18),
                semanticsLabel:
                    widget.l10n?.translate('order_detail_reorder_btn'),
                onPressed: widget.reorderEnabled ? widget.onReorder : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: ASpacing.xxl),
        Text(
          widget.l10n?.translate('orderDetailLines') ?? 'Order lines',
          style: ATypography.titleMd,
          textDirection: textDirection,
        ),
        const SizedBox(height: ASpacing.md),
        if (widget.detail.items.isEmpty)
          AStateMessage(
            icon: Icons.list_alt_outlined,
            title: widget.l10n?.translate('orderDetailNoLines') ??
                'No lines for this order',
          )
        else
          ...widget.detail.items.map(
            (OrderItem item) => Padding(
              padding: const EdgeInsets.only(bottom: ASpacing.lg),
              child: _OrderLineCard(
                item: item,
                currencyFormat: currencyFormat,
                l10n: widget.l10n,
              ),
            ),
          ),
        const SizedBox(height: ASpacing.xxl),
        Text(
          widget.l10n?.translate('orderDetailShipments') ?? 'Shipments',
          style: ATypography.titleMd,
          textDirection: textDirection,
        ),
        const SizedBox(height: ASpacing.md),
        if (widget.detail.shipments.isEmpty)
          AStateMessage(
            icon: Icons.local_shipping_outlined,
            title: widget.l10n?.translate('orderDetailNoShipments') ??
                'Shipments are not ready yet',
          )
        else
          ...widget.detail.shipments.map(
            (OrderShipment shipment) => Padding(
              padding: const EdgeInsets.only(bottom: ASpacing.lg),
              child: _ShipmentCard(
                shipment: shipment,
                l10n: widget.l10n,
                dateFormat: dateFormat,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildApprovalWidgets(
    BuildContext context,
    OrderApprovalState state,
  ) {
    if (!state.requiresApproval) {
      return const <Widget>[];
    }
    final List<Widget> widgets = <Widget>[];
    // Map stage → stable banner key for tests
    Key? bannerKey;
    switch (state.stage) {
      case OrderApprovalStage.readyToRequest:
        bannerKey = const ValueKey('order_detail_requires_approval_banner');
        break;
      case OrderApprovalStage.pending:
        bannerKey = const ValueKey('order_detail_pending_approval_banner');
        break;
      case OrderApprovalStage.approved:
        bannerKey = const ValueKey('order_detail_approved_banner');
        break;
      case OrderApprovalStage.rejected:
        bannerKey = const ValueKey('order_detail_rejected_banner');
        break;
      case OrderApprovalStage.notRequired:
        bannerKey = null;
        break;
    }
    if (bannerKey != null) {
      widgets.add(
        ApprovalStatusBanner(
          key: bannerKey,
          state: state,
          l10n: widget.l10n,
          margin: const EdgeInsetsDirectional.only(bottom: ASpacing.lg),
        ),
      );
    }
    final List<_UiApprovalStep> steps =
        ref.watch(approvalTimelineProvider(state.orderId));
    widgets.add(
      _OrderApprovalTimeline(
        steps: steps,
        l10n: widget.l10n,
      ),
    );
    widgets.add(const SizedBox(height: ASpacing.lg));

    final Widget? action = _buildApprovalAction(state);
    if (action != null) {
      widgets.add(action);
      widgets.add(const SizedBox(height: ASpacing.xl));
    }

    return widgets;
  }

  Widget? _buildApprovalAction(OrderApprovalState state) {
    if (!state.canRequestApproval) {
      return null;
    }
    final MarketplaceLocalizations? l10n = widget.l10n;
    final String label = _isSendingApproval
        ? l10n?.translate('approvalSendLoading') ?? 'Sending...'
        : l10n?.translate('resendForApproval') ?? 'Resend for approval';
    final IconData iconData =
        state.stage == OrderApprovalStage.rejected ? Icons.refresh : Icons.send;
    return AButton.primary(
      key: const ValueKey('order_detail_resend_for_approval_btn'),
      label: label,
      icon: Icon(iconData, size: 18),
      loading: _isSendingApproval,
      onPressed: _isSendingApproval ? null : _handleSendForApproval,
    );
  }

  Future<void> _handleSendForApproval() async {
    if (_isSendingApproval) {
      return;
    }
    setState(() {
      _isSendingApproval = true;
    });

    final SendOrderForApproval sendOrderForApproval =
        ref.read(sendOrderForApprovalProvider);
    final MarketplaceLocalizations? l10n = widget.l10n;
    final ScaffoldMessengerState? messenger =
        ScaffoldMessenger.maybeOf(context);

    try {
      await sendOrderForApproval(orderId: widget.detail.id);
      if (!context.mounted) {
        return;
      }
      ref.invalidate(orderApprovalProvider(widget.detail.id));
      ref.invalidate(approvalTimelineProvider(widget.detail.id));
      final String message =
          l10n?.translate('approvalSendSuccess') ?? 'Approval request sent.';
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      final String message = l10n?.translate('approvalSendError') ??
          'Could not send approval request.';
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (context.mounted) {
        setState(() {
          _isSendingApproval = false;
        });
      }
    }
  }
}

class _OrderApprovalTimeline extends StatelessWidget {
  const _OrderApprovalTimeline({
    required this.steps,
    required this.l10n,
  });

  final List<_UiApprovalStep> steps;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Text(
        l10n?.translate('approvalTimeline') ?? 'Approval timeline',
        style: ATypography.titleMd,
      ),
    ];

    if (steps.isNotEmpty) {
      children.add(const SizedBox(height: ASpacing.md));
      for (int index = 0; index < steps.length; index++) {
        children.add(
          _ApprovalTimelineStepTile(
            index: index,
            total: steps.length,
            step: steps[index],
          ),
        );
      }
    }

    return Container(
      key: const ValueKey('order_approval_timeline'),
      margin: const EdgeInsetsDirectional.only(bottom: ASpacing.lg),
      padding: const EdgeInsets.all(ASpacing.lg),
      decoration: BoxDecoration(
        color: AColors.surfaceSubtle,
        borderRadius: ARadii.lg,
        border: Border.all(color: AColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ApprovalTimelineStepTile extends StatelessWidget {
  const _ApprovalTimelineStepTile({
    required this.index,
    required this.total,
    required this.step,
  });

  final int index;
  final int total;
  final _UiApprovalStep step;

  @override
  Widget build(BuildContext context) {
    final bool isFirst = index == 0;
    final bool isLast = index == total - 1;
    final String statusKey = _statusKey(step.status);
    final _LabelAndColor statusData = _mapStatus(context, statusKey);
    final Color accent = statusData.foreground;
    final Locale locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final intl.DateFormat dateFormat =
        intl.DateFormat.yMd(locale.toLanguageTag()).add_Hm();
    final DateTime? timestamp = step.decidedAt?.toLocal();
    final String? timestampLabel =
        timestamp != null ? dateFormat.format(timestamp) : null;
    final List<String> metadataParts = <String>[
      if (step.approverName != null && step.approverName!.trim().isNotEmpty)
        step.approverName!.trim(),
      if (timestampLabel != null) timestampLabel,
    ];
    final String? metadata =
        metadataParts.isNotEmpty ? metadataParts.join(' • ') : null;
    final String? noteValue = step.note?.trim();

    return Padding(
      key: ValueKey('approval_step_${index}_${step.id}'),
      padding: EdgeInsetsDirectional.only(bottom: isLast ? 0 : ASpacing.lg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  if (!isFirst)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AColors.borderSubtle,
                      ),
                    ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AColors.borderSubtle,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: ASpacing.md),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(ASpacing.md),
                decoration: BoxDecoration(
                  color: AColors.surface,
                  borderRadius: ARadii.md,
                  border: Border.all(color: AColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ApprovalStatusChip(
                      label: statusData.label,
                      foreground: statusData.foreground,
                      background: statusData.background,
                      chipKey: ValueKey(
                          'approval_step_chip_${statusKey}_${step.id}'),
                    ),
                    if (metadata != null) ...[
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        metadata,
                        style: ATypography.bodySm.copyWith(
                          color: AColors.neutral600,
                        ),
                      ),
                    ],
                    if (noteValue != null && noteValue.isNotEmpty) ...[
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        noteValue,
                        key: ValueKey('approval_step_note_${step.id}'),
                        style: ATypography.bodyMd,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusKey(_UiApprovalStepStatus status) {
    switch (status) {
      case _UiApprovalStepStatus.approved:
        return 'approved';
      case _UiApprovalStepStatus.pending:
        return 'pending';
      case _UiApprovalStepStatus.rejected:
        return 'rejected';
    }
  }

  _LabelAndColor _mapStatus(BuildContext context, String code) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final StatusChipStyle style = resolveStatusChipStyle(
      status: code,
      l10n: l10n,
    );
    return (
      label: style.label,
      foreground: style.foreground,
      background: style.background,
    );
  }
}

class _ApprovalStatusChip extends StatelessWidget {
  const _ApprovalStatusChip({
    required this.label,
    required this.foreground,
    required this.background,
    required this.chipKey,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Key chipKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: chipKey,
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: ARadii.pill,
        border: Border.all(color: foreground.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: ATypography.bodySm.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({
    required this.detail,
    required this.currencyFormat,
    required this.l10n,
  });

  final OrderDetail detail;
  final intl.NumberFormat currencyFormat;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalRow(
          label: l10n?.translate('subtotalShort') ?? 'Subtotal',
          value: currencyFormat.format(detail.subtotal),
        ),
        const SizedBox(height: ASpacing.sm),
        _TotalRow(
          label: l10n?.translate('vatShort') ?? 'VAT',
          value: currencyFormat.format(detail.tax),
        ),
        const Divider(height: ASpacing.xxl),
        _TotalRow(
          label: l10n?.translate('totalShort') ?? 'Total',
          value: currencyFormat.format(detail.total),
          highlight: true,
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        highlight ? ATypography.titleSm : ATypography.bodyMd;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack = constraints.maxWidth < 360;
        final Widget labelWidget = Text(
          label,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        );
        final TextStyle valueStyle = style.copyWith(
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
        );
        final Widget valueWidget = Text(
          value,
          style: valueStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          textAlign: stack ? TextAlign.start : TextAlign.end,
        );
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelWidget,
              const SizedBox(height: ASpacing.xs),
              valueWidget,
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: labelWidget),
            const SizedBox(width: ASpacing.lg),
            Flexible(child: valueWidget),
          ],
        );
      },
    );
  }
}

String _truncateId(String raw) {
  if (raw.length <= 6) {
    return raw;
  }
  return raw.substring(0, 6);
}

class _OrderLineCard extends StatelessWidget {
  const _OrderLineCard({
    required this.item,
    required this.currencyFormat,
    required this.l10n,
  });

  final OrderItem item;
  final intl.NumberFormat currencyFormat;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final String skuPrefix = l10n?.translate('orderDetailSkuPrefix') ?? 'SKU';
    final String displayName =
        item.productName ?? '$skuPrefix ${_truncateId(item.variantId)}';
    final String skuLabel = l10n?.translate('orderDetailLineSkuLabel') ?? 'SKU';
    final String quantityLabel =
        l10n?.translate('orderDetailLineQuantityLabel') ?? 'Quantity';
    final String unitPriceLabel =
        l10n?.translate('orderDetailLineUnitPriceLabel') ?? 'Unit price';
    final String qtyLabel = item.qty % 1 == 0
        ? item.qty.toStringAsFixed(0)
        : item.qty.toStringAsFixed(2);

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: ATypography.titleSm,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textDirection: textDirection,
          ),
          const SizedBox(height: ASpacing.sm),
          if (item.variantSku != null)
            Text(
              '$skuLabel: ${item.variantSku}',
              style: ATypography.bodySm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textDirection: textDirection,
            ),
          Text(
            '$quantityLabel: $qtyLabel',
            style: ATypography.bodySm,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textDirection: textDirection,
          ),
          Text(
            '$unitPriceLabel: ${currencyFormat.format(item.unitPrice)}',
            style: ATypography.bodySm,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textDirection: textDirection,
          ),
          const SizedBox(height: ASpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              currencyFormat.format(item.lineTotal),
              style: ATypography.titleSm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textDirection: textDirection,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.shipment,
    required this.l10n,
    required this.dateFormat,
  });

  final OrderShipment shipment;
  final MarketplaceLocalizations? l10n;
  final intl.DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final String createdLabel = dateFormat.format(shipment.createdAt.toLocal());

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool stack = constraints.maxWidth < 360;
              final Widget title = Text(
                shipment.vendorName ?? shipment.vendorCompanyId,
                style: ATypography.titleSm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: textDirection,
              );
              final Widget statusChip = OrderStatusChip(
                status: shipment.status,
                l10n: l10n,
                compact: true,
              );
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: ASpacing.sm),
                    statusChip,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: ASpacing.sm),
                  statusChip,
                ],
              );
            },
          ),
          const SizedBox(height: ASpacing.sm),
          ALabeledValue(
            label: l10n?.translate('orderDetailCreatedAt') ?? 'Created at',
            value: createdLabel,
            icon: const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AColors.neutral400,
            ),
          ),
          if (shipment.tracking != null && shipment.tracking!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: ASpacing.sm),
              child: ALabeledValue(
                label:
                    l10n?.translate('orderDetailTrackingLabel') ?? 'Tracking',
                value: shipment.tracking!,
                icon: const Icon(
                  Icons.local_shipping_outlined,
                  size: 18,
                  color: AColors.neutral400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderDetailLoading extends StatelessWidget {
  const _OrderDetailLoading();

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding =
        context.pagePadding().resolve(Directionality.of(context));
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      children: const [
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ASkeleton(width: 180, height: 22),
              SizedBox(height: ASpacing.sm),
              ASkeleton(width: 140, height: 16),
              SizedBox(height: ASpacing.lg),
              ASkeleton(width: double.infinity, height: 16),
              SizedBox(height: ASpacing.sm),
              ASkeleton(width: double.infinity, height: 16),
            ],
          ),
        ),
        SizedBox(height: ASpacing.xxl),
        ASkeleton(width: 160, height: 20),
        SizedBox(height: ASpacing.md),
        ACard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ASkeleton(width: 220, height: 16),
              SizedBox(height: ASpacing.sm),
              ASkeleton(width: 180, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}

String _resolveLocale(BuildContext context) {
  final Locale locale = Localizations.localeOf(context);
  final String localeName = locale.toString();
  if (intl.DateFormat.localeExists(localeName)) {
    return localeName;
  }
  if (intl.DateFormat.localeExists(locale.languageCode)) {
    return locale.languageCode;
  }
  return 'en';
}
