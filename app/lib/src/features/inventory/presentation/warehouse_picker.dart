// Warehouse picker component
import 'package:flutter/material.dart';
import 'package:ashachar_marketplace/src/design_system/tokens/tokens.dart';
import 'package:ashachar_marketplace/src/design_system/components/components.dart';

/// Warehouse picker dropdown for order/cart
class WarehousePicker extends StatelessWidget {
  final String? selectedWarehouseId;
  final List<WarehouseOption> warehouses;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const WarehousePicker({
    super.key,
    this.selectedWarehouseId,
    required this.warehouses,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'משלוח מ',
          style: TypographyPresets.labelMd(),
        ),
        Gaps.v2,
        DropdownButtonFormField<String>(
          key: const ValueKey('warehouse_picker'),
          value: selectedWarehouseId,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.s3,
              vertical: Spacing.s2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadii.input,
            ),
          ),
          items: warehouses
              .map((WarehouseOption option) => DropdownMenuItem<String>(
                    value: option.id,
                    child: _WarehouseDropdownTile(option: option),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Warehouse option for picker
class WarehouseOption {
  final String id;
  final String name;
  final String code;
  final double? availableQty;
  final DateTime? eta;

  const WarehouseOption({
    required this.id,
    required this.name,
    required this.code,
    this.availableQty,
    this.eta,
  });

  String get displayName => '$name ($code)';
  bool get hasStock => (availableQty ?? 0) > 0;
}

class _WarehouseDropdownTile extends StatelessWidget {
  const _WarehouseDropdownTile({required this.option});

  final WarehouseOption option;

  @override
  Widget build(BuildContext context) {
    final TextStyle subtitleStyle = TypographyPresets.bodySm(
      color: SemanticColors.mutedForeground,
    );
    final String? etaLabel =
        option.eta != null ? 'ETA: ${_formatEtaLabel(option.eta!)}' : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.displayName,
                style: TypographyPresets.bodyMd().copyWith(
                  fontWeight: FontWeights.semibold,
                ),
              ),
              if (!option.hasStock) ...[
                Gaps.v1,
                Text('אזל מהמלאי', style: subtitleStyle),
              ],
              if (etaLabel != null) ...[
                Gaps.v1,
                Text(etaLabel, style: subtitleStyle),
              ],
            ],
          ),
        ),
        if (option.availableQty != null) ...[
          Gaps.h2,
          Text(
            option.availableQty!.toStringAsFixed(0),
            style: TypographyPresets.bodySm(
              color: SemanticColors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  String _formatEtaLabel(DateTime eta) {
    final int diff = eta.difference(DateTime.now()).inDays;
    if (diff == 0) return 'היום';
    if (diff == 1) return 'מחר';
    if (diff < 0) return 'באיחור';
    return '$diff ימים';
  }
}

/// ETA badge component
class EtaBadge extends StatelessWidget {
  final DateTime eta;
  final BadgeSize size;

  const EtaBadge({
    super.key,
    required this.eta,
    this.size = BadgeSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = eta.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 3;

    return AppBadge(
      key: const ValueKey('eta_badge'),
      text: _getEtaText(daysUntil),
      variant: isUrgent ? BadgeVariant.warning : BadgeVariant.info,
      size: size,
      icon: Icon(
        Icons.schedule,
        size: Sizes.iconXs,
        color: _iconColorForVariant(
          isUrgent ? BadgeVariant.warning : BadgeVariant.info,
        ),
      ),
    );
  }

  String _getEtaText(int days) {
    if (days == 0) return 'היום';
    if (days == 1) return 'מחר';
    if (days < 0) return 'באיחור';
    return 'עוד $days ימים';
  }

  Color _iconColorForVariant(BadgeVariant variant) {
    switch (variant) {
      case BadgeVariant.primary:
        return SemanticColors.primaryForeground;
      case BadgeVariant.secondary:
        return SemanticColors.secondaryForeground;
      case BadgeVariant.success:
        return SemanticColors.successForeground;
      case BadgeVariant.warning:
        return SemanticColors.warningForeground;
      case BadgeVariant.error:
        return SemanticColors.destructiveForeground;
      case BadgeVariant.info:
        return SemanticColors.infoForeground;
      case BadgeVariant.default_:
      case BadgeVariant.outline:
        return SemanticColors.foreground;
    }
  }
}

/// Backorder toggle component
class BackorderToggle extends StatelessWidget {
  final bool allowed;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  const BackorderToggle({
    super.key,
    required this.allowed,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      key: const ValueKey('backorder_toggle'),
      title: Text(
        'אפשר הזמנה עתידית',
        style: TypographyPresets.labelMd(),
      ),
      subtitle: Text(
        allowed ? 'המוצר יישלח כשיגיע למלאי' : 'אין אפשרות להזמנה עתידית',
        style: TypographyPresets.bodySm(
          color: SemanticColors.mutedForeground,
        ),
      ),
      value: allowed,
      onChanged: enabled ? onChanged : null,
      activeColor: SemanticColors.primary,
    );
  }
}

/// Inventory status indicator
class InventoryStatusIndicator extends StatelessWidget {
  final double qty;
  final double lowStockThreshold;
  final DateTime? eta;
  final bool backorderAllowed;

  const InventoryStatusIndicator({
    super.key,
    required this.qty,
    required this.lowStockThreshold,
    this.eta,
    this.backorderAllowed = false,
  });

  @override
  Widget build(BuildContext context) {
    final inStock = qty > 0;
    final lowStock = qty > 0 && qty <= lowStockThreshold;

    if (!inStock && !backorderAllowed) {
      return AppBadge(
        text: 'אזל מהמלאי',
        variant: BadgeVariant.error,
        icon: Icon(
          Icons.warning,
          size: Sizes.iconXs,
          color: SemanticColors.destructiveForeground,
        ),
      );
    }

    if (!inStock && backorderAllowed && eta != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBadge(
            text: 'הזמנה עתידית',
            variant: BadgeVariant.warning,
            icon: Icon(
              Icons.schedule_send,
              size: Sizes.iconXs,
              color: SemanticColors.warningForeground,
            ),
          ),
          Gaps.h2,
          EtaBadge(eta: eta!),
        ],
      );
    }

    if (lowStock) {
      return AppBadge(
        text: 'מלאי נמוך (${qty.toInt()})',
        variant: BadgeVariant.warning,
        icon: Icon(
          Icons.warning_amber,
          size: Sizes.iconXs,
          color: SemanticColors.warningForeground,
        ),
      );
    }

    return AppBadge(
      text: 'במלאי (${qty.toInt()})',
      variant: BadgeVariant.success,
      icon: Icon(
        Icons.check_circle,
        size: Sizes.iconXs,
        color: SemanticColors.successForeground,
      ),
    );
  }
}
