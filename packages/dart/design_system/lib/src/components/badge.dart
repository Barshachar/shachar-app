/// Enterprise-grade Badge & Chip components
/// Professional badges and chips with variants and states
library;

import 'package:flutter/material.dart';
import 'package:design_system/src/tokens/tokens.dart';

/// Badge variants
enum BadgeVariant {
  default_,
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  outline,
}

/// Badge sizes
enum BadgeSize { sm, md, lg }

/// Badge component
class AppBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final BadgeSize size;
  final Widget? icon;
  final Color? customColor;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.default_,
    this.size = BadgeSize.md,
    this.icon,
    this.customColor,
  });

  const AppBadge.primary({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    Widget? icon,
  }) : this(
            key: key,
            text: text,
            variant: BadgeVariant.primary,
            size: size,
            icon: icon);

  const AppBadge.success({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    Widget? icon,
  }) : this(
            key: key,
            text: text,
            variant: BadgeVariant.success,
            size: size,
            icon: icon);

  const AppBadge.warning({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    Widget? icon,
  }) : this(
            key: key,
            text: text,
            variant: BadgeVariant.warning,
            size: size,
            icon: icon);

  const AppBadge.error({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    Widget? icon,
  }) : this(
            key: key,
            text: text,
            variant: BadgeVariant.error,
            size: size,
            icon: icon);

  const AppBadge.info({
    Key? key,
    required String text,
    BadgeSize size = BadgeSize.md,
    Widget? icon,
  }) : this(
            key: key,
            text: text,
            variant: BadgeVariant.info,
            size: size,
            icon: icon);

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadii.badge,
        border: variant == BadgeVariant.outline
            ? Border.all(color: colors['foreground']!, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SizedBox(
              width: _getIconSize(),
              height: _getIconSize(),
              child: icon,
            ),
            SizedBox(width: _getIconSpacing()),
          ],
          Text(
            text,
            style: textStyle.copyWith(color: colors['foreground']),
          ),
        ],
      ),
    );
  }

  Map<String, Color?> _getColors() {
    if (customColor != null) {
      return {
        'background': customColor,
        'foreground': ColorUtils.getContrastingTextColor(customColor!),
      };
    }

    switch (variant) {
      case BadgeVariant.default_:
        return {
          'background': SemanticColors.muted,
          'foreground': SemanticColors.foreground,
        };
      case BadgeVariant.primary:
        return {
          'background': SemanticColors.primary,
          'foreground': SemanticColors.primaryForeground,
        };
      case BadgeVariant.secondary:
        return {
          'background': SemanticColors.secondary,
          'foreground': SemanticColors.secondaryForeground,
        };
      case BadgeVariant.success:
        return {
          'background': SemanticColors.success,
          'foreground': SemanticColors.successForeground,
        };
      case BadgeVariant.warning:
        return {
          'background': SemanticColors.warning,
          'foreground': SemanticColors.warningForeground,
        };
      case BadgeVariant.error:
        return {
          'background': SemanticColors.destructive,
          'foreground': SemanticColors.destructiveForeground,
        };
      case BadgeVariant.info:
        return {
          'background': SemanticColors.info,
          'foreground': SemanticColors.infoForeground,
        };
      case BadgeVariant.outline:
        return {
          'background': Colors.transparent,
          'foreground': SemanticColors.foreground,
        };
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case BadgeSize.sm:
        return const EdgeInsets.symmetric(
            horizontal: Spacing.s2, vertical: Spacing.s0_5);
      case BadgeSize.md:
        return const EdgeInsets.symmetric(
            horizontal: Spacing.s2_5, vertical: Spacing.s1);
      case BadgeSize.lg:
        return const EdgeInsets.symmetric(
            horizontal: Spacing.s3, vertical: Spacing.s1_5);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.sm:
        return TypographyPresets.labelSm();
      case BadgeSize.md:
        return TypographyPresets.labelMd();
      case BadgeSize.lg:
        return TypographyPresets.labelLg();
    }
  }

  double _getIconSize() {
    switch (size) {
      case BadgeSize.sm:
        return 10;
      case BadgeSize.md:
        return 12;
      case BadgeSize.lg:
        return 14;
    }
  }

  double _getIconSpacing() {
    return size == BadgeSize.sm ? Spacing.s1 : Spacing.s1_5;
  }
}

/// Dot Badge - for notifications
class DotBadge extends StatelessWidget {
  final BadgeVariant variant;
  final double size;

  const DotBadge({
    super.key,
    this.variant = BadgeVariant.error,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor(),
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getColor() {
    switch (variant) {
      case BadgeVariant.primary:
        return SemanticColors.primary;
      case BadgeVariant.success:
        return SemanticColors.success;
      case BadgeVariant.warning:
        return SemanticColors.warning;
      case BadgeVariant.error:
        return SemanticColors.destructive;
      case BadgeVariant.info:
        return SemanticColors.info;
      default:
        return SemanticColors.muted;
    }
  }
}

/// Chip component - interactive badge
class AppChip extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final BadgeSize size;
  final Widget? avatar;
  final Widget? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AppChip({
    super.key,
    required this.text,
    this.variant = BadgeVariant.default_,
    this.size = BadgeSize.md,
    this.avatar,
    this.icon,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadii.chip,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colors['background'],
            borderRadius: BorderRadii.chip,
            border: variant == BadgeVariant.outline
                ? Border.all(color: colors['foreground']!, width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (avatar != null) ...[
                SizedBox(
                  width: _getAvatarSize(),
                  height: _getAvatarSize(),
                  child: ClipOval(child: avatar),
                ),
                SizedBox(width: _getIconSpacing()),
              ],
              if (icon != null && avatar == null) ...[
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: icon,
                ),
                SizedBox(width: _getIconSpacing()),
              ],
              Text(
                text,
                style: textStyle.copyWith(color: colors['foreground']),
              ),
              if (onDelete != null) ...[
                SizedBox(width: _getIconSpacing()),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadii.full,
                  child: Icon(
                    Icons.close,
                    size: _getIconSize(),
                    color: colors['foreground'],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Color?> _getColors() {
    switch (variant) {
      case BadgeVariant.default_:
        return {
          'background': SemanticColors.muted,
          'foreground': SemanticColors.foreground,
        };
      case BadgeVariant.primary:
        return {
          'background': SemanticColors.primary,
          'foreground': SemanticColors.primaryForeground,
        };
      case BadgeVariant.secondary:
        return {
          'background': SemanticColors.secondary,
          'foreground': SemanticColors.secondaryForeground,
        };
      case BadgeVariant.success:
        return {
          'background': SemanticColors.successSubtle,
          'foreground': SemanticColors.success,
        };
      case BadgeVariant.warning:
        return {
          'background': SemanticColors.warningSubtle,
          'foreground': SemanticColors.warning,
        };
      case BadgeVariant.error:
        return {
          'background': SemanticColors.destructive.withValues(alpha: 0.1),
          'foreground': SemanticColors.destructive,
        };
      case BadgeVariant.info:
        return {
          'background': SemanticColors.infoSubtle,
          'foreground': SemanticColors.info,
        };
      case BadgeVariant.outline:
        return {
          'background': Colors.transparent,
          'foreground': SemanticColors.foreground,
        };
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case BadgeSize.sm:
        return const EdgeInsets.symmetric(
            horizontal: Spacing.s2, vertical: Spacing.s1);
      case BadgeSize.md:
        return const EdgeInsets.symmetric(
            horizontal: Spacing.s3, vertical: Spacing.s1_5);
      case BadgeSize.lg:
        return const EdgeInsets.symmetric(
            horizontal: Spacing.s4, vertical: Spacing.s2);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.sm:
        return TypographyPresets.labelSm();
      case BadgeSize.md:
        return TypographyPresets.labelMd();
      case BadgeSize.lg:
        return TypographyPresets.labelLg();
    }
  }

  double _getIconSize() {
    switch (size) {
      case BadgeSize.sm:
        return 12;
      case BadgeSize.md:
        return 14;
      case BadgeSize.lg:
        return 16;
    }
  }

  double _getAvatarSize() {
    switch (size) {
      case BadgeSize.sm:
        return 16;
      case BadgeSize.md:
        return 20;
      case BadgeSize.lg:
        return 24;
    }
  }

  double _getIconSpacing() {
    return size == BadgeSize.sm ? Spacing.s1 : Spacing.s1_5;
  }
}

/// Status Badge - for order/item status
class StatusBadge extends StatelessWidget {
  final String status;
  final BadgeSize size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final variant = _getVariantForStatus(status);
    return AppBadge(
      text: status,
      variant: variant,
      size: size,
      icon: _getIconForStatus(status),
    );
  }

  BadgeVariant _getVariantForStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('success') ||
        normalized.contains('completed') ||
        normalized.contains('delivered') ||
        normalized.contains('active')) {
      return BadgeVariant.success;
    }
    if (normalized.contains('pending') ||
        normalized.contains('processing') ||
        normalized.contains('in progress')) {
      return BadgeVariant.warning;
    }
    if (normalized.contains('error') ||
        normalized.contains('failed') ||
        normalized.contains('cancelled') ||
        normalized.contains('rejected')) {
      return BadgeVariant.error;
    }
    if (normalized.contains('info') || normalized.contains('new')) {
      return BadgeVariant.info;
    }
    return BadgeVariant.default_;
  }

  Widget? _getIconForStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('success') || normalized.contains('completed')) {
      return const Icon(Icons.check_circle, size: 12);
    }
    if (normalized.contains('pending')) {
      return const Icon(Icons.access_time, size: 12);
    }
    if (normalized.contains('error') || normalized.contains('failed')) {
      return const Icon(Icons.error, size: 12);
    }
    return null;
  }
}
