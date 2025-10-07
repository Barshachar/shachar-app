// Shipping method picker component
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Shipping method picker for checkout
class ShippingMethodPicker extends StatelessWidget {
  final String? selectedMethodId;
  final List<ShippingMethodOption> methods;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const ShippingMethodPicker({
    super.key,
    this.selectedMethodId,
    required this.methods,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('shipping_method_picker'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'שיטת משלוח',
          style: TypographyPresets.labelMd(),
        ),
        Gaps.v3,
        ...methods.map(
          (ShippingMethodOption method) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s2),
            child: _ShippingMethodTile(
              method: method,
              selected: selectedMethodId == method.id,
              onTap: enabled ? () => onChanged(method.id) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShippingMethodTile extends StatelessWidget {
  final ShippingMethodOption method;
  final bool selected;
  final VoidCallback? onTap;

  const _ShippingMethodTile({
    required this.method,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: ValueKey('shipping_method_${method.id}'),
      variant: selected ? CardVariant.outlined : CardVariant.elevated,
      padding: Insets.all3,
      onTap: onTap,
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: selected,
            onChanged: onTap != null ? (_) => onTap!() : null,
            activeColor: SemanticColors.primary,
          ),
          Gaps.h3,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  style: TypographyPresets.labelMd(),
                ),
                if (method.estimatedDays != null) ...[
                  Gaps.v1,
                  Text(
                    method.estimatedDays!,
                    style: TypographyPresets.bodySm(
                      color: SemanticColors.mutedForeground,
                    ),
                  ),
                ],
                if (method.carrier != null) ...[
                  Gaps.v1,
                  AppBadge(
                    text: method.carrier!,
                    variant: BadgeVariant.secondary,
                    size: BadgeSize.sm,
                  ),
                ],
              ],
            ),
          ),
          Gaps.h3,
          Text(
            method.formattedRate,
            style: TypographyPresets.headingXs(),
          ),
        ],
      ),
    );
  }
}

/// Shipping method option
class ShippingMethodOption {
  final String id;
  final String name;
  final String code;
  final double rate;
  final String currency;
  final String? estimatedDays;
  final String? carrier;

  const ShippingMethodOption({
    required this.id,
    required this.name,
    required this.code,
    required this.rate,
    this.currency = 'ILS',
    this.estimatedDays,
    this.carrier,
  });

  String get formattedRate => '₪${rate.toStringAsFixed(2)}';
}

/// Shipment tracking link
class ShipmentTrackingLink extends StatelessWidget {
  final String? trackingNumber;
  final String? carrier;
  final VoidCallback? onTap;

  const ShipmentTrackingLink({
    super.key,
    this.trackingNumber,
    this.carrier,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (trackingNumber == null) {
      return const SizedBox.shrink();
    }

    return AppCard.filled(
      key: const ValueKey('shipment_tracking_link'),
      padding: Insets.all3,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.local_shipping,
            color: SemanticColors.primary,
          ),
          Gaps.h3,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'מעקב משלוח',
                  style: TypographyPresets.labelSm(),
                ),
                Gaps.v1,
                Text(
                  trackingNumber!,
                  style: TypographyPresets.bodySm(
                    color: SemanticColors.mutedForeground,
                  ),
                ),
                if (carrier != null) ...[
                  Gaps.v1,
                  Text(
                    carrier!,
                    style: TypographyPresets.bodyXs(
                      color: SemanticColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            size: Sizes.iconSm,
            color: SemanticColors.primary,
          ),
        ],
      ),
    );
  }
}

/// ASN creation button
class AsnCreateButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const AsnCreateButton({
    super.key,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      key: const ValueKey('asn_create_btn'),
      text: 'צור הודעת משלוח (ASN)',
      onPressed: onPressed,
      isLoading: loading,
      leadingIcon: const Icon(Icons.notification_add),
    );
  }
}

/// POD confirmation button
class PodConfirmButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const PodConfirmButton({
    super.key,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      key: const ValueKey('pod_confirm_btn'),
      text: 'אשר קבלת משלוח (POD)',
      onPressed: onPressed,
      isLoading: loading,
      leadingIcon: const Icon(Icons.check_circle),
    );
  }
}

/// Shipment status badge
class ShipmentStatusBadge extends StatelessWidget {
  final String status;

  const ShipmentStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return AppBadge(
      text: config.label,
      variant: config.variant,
      icon: Icon(
        config.icon,
        size: Sizes.iconXs,
        color: _iconColorForVariant(config.variant),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return _StatusConfig('ממתין', BadgeVariant.secondary, Icons.pending);
      case 'ready':
        return _StatusConfig(
            'מוכן למשלוח', BadgeVariant.info, Icons.inventory_2);
      case 'in_transit':
        return _StatusConfig(
            'בדרך', BadgeVariant.warning, Icons.local_shipping);
      case 'delivered':
        return _StatusConfig('נמסר', BadgeVariant.success, Icons.check_circle);
      case 'cancelled':
        return _StatusConfig('בוטל', BadgeVariant.error, Icons.cancel);
      default:
        return _StatusConfig(status, BadgeVariant.secondary, Icons.help);
    }
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

class _StatusConfig {
  final String label;
  final BadgeVariant variant;
  final IconData icon;

  const _StatusConfig(this.label, this.variant, this.icon);
}
