import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';

enum AButtonVariant { primary, secondary, ghost, destructive }

enum AButtonSize { compact, md, lg }

class AButton extends StatelessWidget {
  const AButton._({
    super.key,
    required this.label,
    this.icon,
    this.expand = false,
    this.size = AButtonSize.md,
    this.loading = false,
    this.semanticsLabel,
    required this.variant,
    required this.onPressed,
  });

  factory AButton.primary({
    Key? key,
    required String label,
    Widget? icon,
    bool expand = false,
    AButtonSize size = AButtonSize.md,
    bool loading = false,
    String? semanticsLabel,
    required VoidCallback? onPressed,
  }) =>
      AButton._(
        key: key,
        label: label,
        icon: icon,
        expand: expand,
        size: size,
        loading: loading,
        semanticsLabel: semanticsLabel,
        variant: AButtonVariant.primary,
        onPressed: onPressed,
      );

  factory AButton.secondary({
    Key? key,
    required String label,
    Widget? icon,
    bool expand = false,
    AButtonSize size = AButtonSize.md,
    bool loading = false,
    String? semanticsLabel,
    required VoidCallback? onPressed,
  }) =>
      AButton._(
        key: key,
        label: label,
        icon: icon,
        expand: expand,
        size: size,
        loading: loading,
        semanticsLabel: semanticsLabel,
        variant: AButtonVariant.secondary,
        onPressed: onPressed,
      );

  factory AButton.text({
    Key? key,
    required String label,
    Widget? icon,
    bool expand = false,
    AButtonSize size = AButtonSize.md,
    bool loading = false,
    String? semanticsLabel,
    required VoidCallback? onPressed,
  }) =>
      AButton._(
        key: key,
        label: label,
        icon: icon,
        expand: expand,
        size: size,
        loading: loading,
        semanticsLabel: semanticsLabel,
        variant: AButtonVariant.ghost,
        onPressed: onPressed,
      );

  factory AButton.ghost({
    Key? key,
    required String label,
    Widget? icon,
    bool expand = false,
    AButtonSize size = AButtonSize.md,
    bool loading = false,
    String? semanticsLabel,
    required VoidCallback? onPressed,
  }) =>
      AButton._(
        key: key,
        label: label,
        icon: icon,
        expand: expand,
        size: size,
        loading: loading,
        semanticsLabel: semanticsLabel,
        variant: AButtonVariant.ghost,
        onPressed: onPressed,
      );

  factory AButton.destructive({
    Key? key,
    required String label,
    Widget? icon,
    bool expand = false,
    AButtonSize size = AButtonSize.md,
    bool loading = false,
    String? semanticsLabel,
    required VoidCallback? onPressed,
  }) =>
      AButton._(
        key: key,
        label: label,
        icon: icon,
        expand: expand,
        size: size,
        loading: loading,
        semanticsLabel: semanticsLabel,
        variant: AButtonVariant.destructive,
        onPressed: onPressed,
      );

  final String label;
  final Widget? icon;
  final bool expand;
  final AButtonSize size;
  final bool loading;
  final String? semanticsLabel;
  final AButtonVariant variant;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !loading;
    final ButtonStyle style = _styleFor();
    final Widget content = _buildContent(style, enabled);
    final VoidCallback? effectiveOnPressed = enabled ? onPressed : null;

    final Widget button = switch (variant) {
      AButtonVariant.primary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      AButtonVariant.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      AButtonVariant.ghost => TextButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      AButtonVariant.destructive => FilledButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
    };

    final Widget semanticButton = Semantics(
      button: true,
      label: semanticsLabel ?? label,
      enabled: enabled,
      child: ExcludeSemantics(child: button),
    );

    if (!expand) {
      return semanticButton;
    }
    return SizedBox(width: double.infinity, child: semanticButton);
  }

  ButtonStyle _styleFor() {
    final BorderRadius borderRadius = ARadii.md;
    final double targetHeight = switch (size) {
      AButtonSize.compact => 36,
      AButtonSize.md => 44,
      AButtonSize.lg => 48,
    };
    final double verticalPadding = switch (size) {
      AButtonSize.compact => ASpacing.xs,
      AButtonSize.md => ASpacing.sm,
      AButtonSize.lg => ASpacing.md,
    };
    final EdgeInsetsGeometry resolvedPadding = EdgeInsetsDirectional.symmetric(
      horizontal: expand ? ASpacing.lg : ASpacing.xl,
      vertical: verticalPadding,
    );
    final WidgetStateProperty<Size?> minimumSize =
        WidgetStateProperty.all<Size?>(
      Size(ASpacing.interactive, targetHeight),
    );

    final _AButtonPalette palette = _resolvePalette();

    return ButtonStyle(
      animationDuration: const Duration(milliseconds: 160),
      elevation: WidgetStateProperty.resolveWith<double?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return palette.disabledElevation;
        }
        if (states.contains(WidgetState.pressed)) {
          return palette.pressedElevation;
        }
        return palette.elevation;
      }),
      shadowColor: WidgetStateProperty.all<Color?>(palette.shadowColor),
      textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (states) {
          final TextStyle base = palette.textStyle;
          if (states.contains(WidgetState.disabled)) {
            return base.copyWith(color: palette.foregroundDisabled);
          }
          return base.copyWith(color: palette.foreground);
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return palette.backgroundDisabled;
          }
          if (states.contains(WidgetState.pressed)) {
            return palette.backgroundPressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return palette.backgroundHovered;
          }
          return palette.background;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return palette.foregroundDisabled;
          }
          return palette.foreground;
        },
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.focused)) {
            return palette.focusOverlay;
          }
          if (states.contains(WidgetState.pressed)) {
            return palette.overlayPressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return palette.overlayHovered;
          }
          return null;
        },
      ),
      minimumSize: minimumSize,
      padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(resolvedPadding),
      shape: WidgetStateProperty.all<OutlinedBorder?>(
        RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      side: WidgetStateProperty.resolveWith<BorderSide?>(
        (states) {
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: palette.focusRing, width: 2);
          }
          if (states.contains(WidgetState.disabled)) {
            return palette.borderDisabled;
          }
          return palette.border;
        },
      ),
    );
  }

  Widget _buildContent(ButtonStyle style, bool enabled) {
    final TextStyle resolvedTextStyle =
        _resolveTextStyle(style, enabled) ?? ATypography.button;
    final Set<WidgetState> iconStates = enabled
        ? const <WidgetState>{}
        : const <WidgetState>{WidgetState.disabled};
    final Color iconColor = style.foregroundColor?.resolve(iconStates) ??
        resolvedTextStyle.color ??
        AColors.foreground;

    final List<Widget> children = <Widget>[];

    if (loading) {
      children.add(SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.25,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      ));
    } else if (icon != null) {
      children.add(IconTheme.merge(
        data: IconThemeData(size: 18, color: iconColor),
        child: icon!,
      ));
    }

    if ((loading || icon != null) && label.isNotEmpty) {
      children.add(const SizedBox(width: ASpacing.sm));
    }

    children.add(Flexible(
      fit: expand ? FlexFit.tight : FlexFit.loose,
      child: Text(
        label,
        style: resolvedTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: TextAlign.center,
      ),
    ));

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  TextStyle? _resolveTextStyle(ButtonStyle style, bool enabled) {
    final Set<WidgetState> states = enabled
        ? const <WidgetState>{}
        : const <WidgetState>{WidgetState.disabled};
    return style.textStyle?.resolve(states) ?? ATypography.button;
  }

  _AButtonPalette _resolvePalette() {
    switch (variant) {
      case AButtonVariant.primary:
        return _AButtonPalette.primary();
      case AButtonVariant.secondary:
        return _AButtonPalette.secondary();
      case AButtonVariant.ghost:
        return _AButtonPalette.ghost();
      case AButtonVariant.destructive:
        return _AButtonPalette.destructive();
    }
  }
}

class _AButtonPalette {
  const _AButtonPalette({
    required this.textStyle,
    required this.background,
    required this.backgroundHovered,
    required this.backgroundPressed,
    required this.backgroundDisabled,
    required this.foreground,
    required this.foregroundDisabled,
    required this.overlayHovered,
    required this.overlayPressed,
    required this.focusOverlay,
    required this.focusRing,
    required this.border,
    required this.borderDisabled,
    required this.shadowColor,
    required this.elevation,
    required this.pressedElevation,
    required this.disabledElevation,
  });

  final TextStyle textStyle;
  final Color background;
  final Color backgroundHovered;
  final Color backgroundPressed;
  final Color backgroundDisabled;
  final Color foreground;
  final Color foregroundDisabled;
  final Color overlayHovered;
  final Color overlayPressed;
  final Color focusOverlay;
  final Color focusRing;
  final BorderSide border;
  final BorderSide borderDisabled;
  final Color shadowColor;
  final double elevation;
  final double pressedElevation;
  final double disabledElevation;

  static _AButtonPalette primary() {
    return _AButtonPalette(
      textStyle: ATypography.button,
      background: AColors.primary,
      backgroundHovered: AColors.primaryDark.withValues(alpha: 0.92),
      backgroundPressed: AColors.primaryDark,
      backgroundDisabled: AColors.neutral300,
      foreground: Colors.white,
      foregroundDisabled: AColors.neutral500,
      overlayHovered: AColors.primaryDark.withValues(alpha: 0.08),
      overlayPressed: Colors.transparent,
      focusOverlay: Colors.transparent,
      focusRing: AColors.primaryMuted,
      border: const BorderSide(color: Colors.transparent, width: 0),
      borderDisabled: const BorderSide(color: Colors.transparent, width: 0),
      shadowColor: AColors.primary.withValues(alpha: 0.25),
      elevation: AElevation.level2,
      pressedElevation: AElevation.level1,
      disabledElevation: AElevation.level0,
    );
  }

  static _AButtonPalette secondary() {
    return _AButtonPalette(
      textStyle: ATypography.button.copyWith(color: AColors.primary),
      background: AColors.surface,
      backgroundHovered: AColors.primaryLight.withValues(alpha: 0.35),
      backgroundPressed: AColors.primaryLight.withValues(alpha: 0.5),
      backgroundDisabled: AColors.neutral200,
      foreground: AColors.primary,
      foregroundDisabled: AColors.neutral500,
      overlayHovered: AColors.primary.withValues(alpha: 0.08),
      overlayPressed: AColors.primary.withValues(alpha: 0.12),
      focusOverlay: Colors.transparent,
      focusRing: AColors.primary,
      border: const BorderSide(color: AColors.primary, width: 1.2),
      borderDisabled: const BorderSide(color: AColors.neutral400, width: 1),
      shadowColor: Colors.transparent,
      elevation: AElevation.level1,
      pressedElevation: AElevation.level0,
      disabledElevation: AElevation.level0,
    );
  }

  static _AButtonPalette ghost() {
    return _AButtonPalette(
      textStyle: ATypography.button.copyWith(color: AColors.primary),
      background: Colors.transparent,
      backgroundHovered: AColors.primaryMuted.withValues(alpha: 0.2),
      backgroundPressed: AColors.primaryMuted.withValues(alpha: 0.3),
      backgroundDisabled: AColors.neutral200,
      foreground: AColors.primary,
      foregroundDisabled: AColors.neutral500,
      overlayHovered: AColors.primaryMuted.withValues(alpha: 0.12),
      overlayPressed: AColors.primaryMuted.withValues(alpha: 0.22),
      focusOverlay: Colors.transparent,
      focusRing: AColors.primaryMuted,
      border: const BorderSide(color: Colors.transparent, width: 0),
      borderDisabled: const BorderSide(color: Colors.transparent, width: 0),
      shadowColor: Colors.transparent,
      elevation: AElevation.level0,
      pressedElevation: AElevation.level0,
      disabledElevation: AElevation.level0,
    );
  }

  static _AButtonPalette destructive() {
    return _AButtonPalette(
      textStyle: ATypography.button,
      background: AColors.danger,
      backgroundHovered: AColors.danger.withValues(alpha: 0.92),
      backgroundPressed: AColors.danger,
      backgroundDisabled: AColors.neutral300,
      foreground: Colors.white,
      foregroundDisabled: AColors.neutral500,
      overlayHovered: AColors.dangerBorder.withValues(alpha: 0.12),
      overlayPressed: AColors.dangerBorder.withValues(alpha: 0.18),
      focusOverlay: Colors.transparent,
      focusRing: AColors.dangerBorder,
      border: const BorderSide(color: Colors.transparent, width: 0),
      borderDisabled: const BorderSide(color: Colors.transparent, width: 0),
      shadowColor: AColors.danger.withValues(alpha: 0.2),
      elevation: AElevation.level2,
      pressedElevation: AElevation.level1,
      disabledElevation: AElevation.level0,
    );
  }
}

enum AQtyStepperSize { small, large }

class AQtyStepper extends StatelessWidget {
  const AQtyStepper({
    super.key,
    required this.qty,
    required this.onChanged,
    this.min = 1,
    this.step = 1,
    this.enabled = true,
    this.compact = true,
    @Deprecated('Use compact instead') AQtyStepperSize? size,
    @Deprecated('Max handling moved to caller') num? max,
    String? semanticLabel,
    this.incrementTooltip,
    this.decrementTooltip,
  })  : _legacySize = size,
        _legacyMax = max,
        _semanticLabel = semanticLabel;

  final num qty;
  final num min;
  final num step;
  final bool enabled;
  final bool compact;
  final ValueChanged<num> onChanged;
  final AQtyStepperSize? _legacySize;
  final num? _legacyMax;
  final String? _semanticLabel;
  final String? incrementTooltip;
  final String? decrementTooltip;

  @override
  Widget build(BuildContext context) {
    final bool isCompact =
        _legacySize != null ? _legacySize == AQtyStepperSize.small : compact;
    final num delta = step <= 0 ? 1 : step;
    final num? legacyMax = _legacyMax;
    final bool canDec = enabled && (qty - delta) >= min;
    final bool canInc =
        enabled && (legacyMax == null || (qty + delta) <= legacyMax);
    final double iconSize = isCompact ? 22 : 28;
    final EdgeInsets pad =
        isCompact ? const EdgeInsets.all(4) : const EdgeInsets.all(8);

    String qtyText(num v) {
      final double d = v.toDouble();
      if (d == d.roundToDouble()) {
        return d.toInt().toString();
      }
      return d
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          iconSize: iconSize,
          padding: pad,
          onPressed: canInc
              ? () {
                  final num next = qty + delta;
                  if (legacyMax != null && next > legacyMax) {
                    onChanged(legacyMax);
                  } else {
                    onChanged(next);
                  }
                }
              : null,
          tooltip: incrementTooltip ?? '+',
        ),
        Semantics(
          label: _semanticLabel ?? 'quantity',
          value: qtyText(qty),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              qtyText(qty),
              key: const ValueKey('a_qty_stepper_value'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: iconSize,
          padding: pad,
          onPressed: canDec
              ? () {
                  final num next = qty - delta;
                  onChanged(next < min ? min : next);
                }
              : null,
          tooltip: decrementTooltip ?? '-',
        ),
      ],
    );
  }
}

class AChip extends StatelessWidget {
  const AChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.backgroundColor,
    this.selectedColor,
    this.foregroundColor,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = foregroundColor ?? AColors.primary;
    final Color resolvedForeground = foregroundColor ??
        (selected ? AColors.primaryDark : AColors.foreground);
    final TextStyle textStyle = ATypography.bodyXs.copyWith(
      fontWeight: FontWeight.w600,
      color: resolvedForeground,
    );
    final Color resolvedBackground = backgroundColor ?? AColors.surfaceMuted;
    final Color resolvedSelectedColor =
        selectedColor ?? baseColor.withValues(alpha: 0.16);
    final Color resolvedBorderColor =
        selected ? baseColor : AColors.borderSubtle;

    final List<InlineSpan> spans = <InlineSpan>[];
    if (icon != null) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: ASpacing.xs),
            child: Icon(icon, size: 16, color: textStyle.color),
          ),
        ),
      );
    }
    spans.add(TextSpan(text: label));

    return ChoiceChip(
      labelPadding: const EdgeInsets.symmetric(
        horizontal: ASpacing.xs,
        vertical: ASpacing.xs,
      ),
      label: Text.rich(
        TextSpan(children: spans),
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: resolvedBackground,
      selectedColor: resolvedSelectedColor,
      side: BorderSide(color: resolvedBorderColor, width: 1),
      pressElevation: AElevation.level1,
      shape: const StadiumBorder(),
      showCheckmark: false,
    );
  }
}

class AStatusChip extends StatelessWidget {
  const AStatusChip({
    super.key,
    required this.statusCode,
    required this.label,
    this.dense = false,
    this.icon,
  });

  final String statusCode;
  final String label;
  final bool dense;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final _AStatusChipVisual visual = _resolveStatusVisual(statusCode);
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: dense ? ASpacing.sm : ASpacing.md,
      vertical: dense ? ASpacing.xs : ASpacing.sm,
    );

    final List<Widget> contents = <Widget>[];
    if (icon != null) {
      contents.add(Icon(icon, size: 18, color: visual.foreground));
    }
    if (icon != null) {
      contents.add(const SizedBox(width: ASpacing.xs));
    }
    contents.add(
      Text(
        label,
        style: ATypography.chip.copyWith(color: visual.foreground),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );

    final Widget contentRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: contents,
    );

    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: visual.background,
            borderRadius: ARadii.sm,
            border: Border.all(color: visual.border, width: 1),
            boxShadow: dense ? null : AElevation.shadowSoft,
          ),
          child: Padding(
            padding: padding,
            child: contentRow,
          ),
        ),
      ),
    );
  }
}

class _AStatusChipVisual {
  const _AStatusChipVisual({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;

  static _AStatusChipVisual success() => _tone(
        tone: AColors.success,
        foreground: AColors.success,
      );

  static _AStatusChipVisual pending() => _AStatusChipVisual(
        background: AColors.warning.withValues(alpha: 0.18),
        border: AColors.warning.withValues(alpha: 0.6),
        foreground: AColors.foreground,
      );

  static _AStatusChipVisual info() => _AStatusChipVisual(
        background: AColors.info.withValues(alpha: 0.16),
        border: AColors.info.withValues(alpha: 0.5),
        foreground: AColors.info,
      );

  static _AStatusChipVisual danger() => _AStatusChipVisual(
        background: AColors.dangerSurface,
        border: AColors.dangerBorder,
        foreground: AColors.danger,
      );

  static _AStatusChipVisual draft() => _AStatusChipVisual(
        background: AColors.surfaceSubtle,
        border: AColors.neutral300,
        foreground: AColors.neutral600,
      );

  static _AStatusChipVisual expired() => _AStatusChipVisual(
        background: AColors.neutral200,
        border: AColors.neutral400,
        foreground: AColors.neutral600,
      );

  static _AStatusChipVisual contract() => _tone(
        tone: AColors.accent,
        foreground: AColors.accent,
        backgroundAlpha: 0.18,
      );

  static _AStatusChipVisual fallback() => _tone(
        tone: AColors.primary,
        foreground: AColors.primary,
      );

  static _AStatusChipVisual _tone({
    required Color tone,
    required Color foreground,
    double backgroundAlpha = 0.16,
    double borderAlpha = 0.5,
  }) {
    return _AStatusChipVisual(
      background: tone.withValues(alpha: backgroundAlpha),
      border: tone.withValues(alpha: borderAlpha),
      foreground: foreground,
    );
  }
}

_AStatusChipVisual _resolveStatusVisual(String statusCode) {
  final String normalized = _normalizeStatusCode(statusCode);
  if (_statusContractCodes.contains(normalized)) {
    return _AStatusChipVisual.contract();
  }
  if (_statusSuccessCodes.contains(normalized)) {
    return _AStatusChipVisual.success();
  }
  if (_statusInfoCodes.contains(normalized)) {
    return _AStatusChipVisual.info();
  }
  if (_statusPendingCodes.contains(normalized)) {
    return _AStatusChipVisual.pending();
  }
  if (_statusDangerCodes.contains(normalized)) {
    return _AStatusChipVisual.danger();
  }
  if (_statusExpiredCodes.contains(normalized)) {
    return _AStatusChipVisual.expired();
  }
  if (_statusDraftCodes.contains(normalized)) {
    return _AStatusChipVisual.draft();
  }
  return _AStatusChipVisual.fallback();
}

String _normalizeStatusCode(String raw) {
  return raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

const Set<String> _statusSuccessCodes = <String>{
  'approved',
  'approval_approved',
  'accepted',
  'completed',
  'fulfilled',
  'delivered',
  'quoted',
  'rfq_status_quoted',
  'placed',
  'submitted',
};

const Set<String> _statusPendingCodes = <String>{
  'pending',
  'pending_approval',
  'awaiting_approval',
  'approval_pending',
  'needs_approval',
  'in_progress',
  'processing',
};

const Set<String> _statusDangerCodes = <String>{
  'rejected',
  'approval_rejected',
  'denied',
};

const Set<String> _statusExpiredCodes = <String>{
  'expired',
  'rfq_status_expired',
};

const Set<String> _statusDraftCodes = <String>{
  'draft',
  'rfq_status_draft',
  'cancelled',
  'canceled',
  'rfq_status_cancelled',
};

const Set<String> _statusContractCodes = <String>{
  'contract',
  'contract_signed',
  'rfq_status_contract',
};

const Set<String> _statusInfoCodes = <String>{
  'awaiting_quotes',
  'rfq_status_awaiting_quotes',
  'awaiting_quote',
  'open',
};

class AProductImage extends StatelessWidget {
  const AProductImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.inventory_2_outlined,
  });

  factory AProductImage.square({
    Key? key,
    String? imageUrl,
    double size = 72,
    BorderRadius? borderRadius,
    BoxFit fit = BoxFit.cover,
    IconData placeholderIcon = Icons.inventory_2_outlined,
  }) {
    return AProductImage(
      key: key,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: borderRadius,
      fit: fit,
      placeholderIcon: placeholderIcon,
    );
  }

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? ARadii.md;
    final String? url = imageUrl?.trim();

    Widget buildSurface(Widget child, {Color? color}) {
      return Container(
        width: width,
        height: height,
        color: color ?? AColors.surfaceMuted,
        alignment: Alignment.center,
        child: child,
      );
    }

    Widget wrap(Widget child) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      );
    }

    if (url == null || url.isEmpty) {
      return wrap(
        buildSurface(
          Icon(
            placeholderIcon,
            color: AColors.neutral500,
            size: 28,
          ),
        ),
      );
    }

    return wrap(
      Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => buildSurface(
          Icon(
            placeholderIcon,
            color: AColors.neutral500,
            size: 28,
          ),
        ),
        loadingBuilder: (
          BuildContext context,
          Widget child,
          ImageChunkEvent? loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }
          return buildSurface(
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            color: AColors.surfaceMuted,
          );
        },
      ),
    );
  }
}

// _SquareProductImage no longer required; factory above returns a configured instance.

class ALabeledValue extends StatelessWidget {
  const ALabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final Widget? icon;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final EdgeInsets padding = direction == TextDirection.rtl
        ? const EdgeInsets.only(right: ASpacing.sm)
        : const EdgeInsets.only(left: ASpacing.sm);

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (icon != null) icon!,
          if (icon != null)
            SizedBox(width: direction == TextDirection.rtl ? 0 : ASpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ATypography.bodySm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  value,
                  style: ATypography.bodyMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ASkeleton extends StatelessWidget {
  const ASkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AColors.neutral200.withValues(alpha: 0.25),
            AColors.neutral200.withValues(alpha: 0.55),
            AColors.neutral200.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: borderRadius ?? ARadii.md,
      ),
    );
  }
}

class ACard extends StatelessWidget {
  const ACard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.elevation = AElevation.level1,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? ARadii.lg;
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? const EdgeInsets.all(ASpacing.lg);
    final Widget content = Padding(padding: resolvedPadding, child: child);

    Widget materialChild = content;
    if (onTap != null) {
      materialChild = InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: content,
      );
    }

    Widget card = Material(
      color: backgroundColor ?? AColors.surface,
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: radius,
      child: materialChild,
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }
    return card;
  }
}

class AStateMessage extends StatelessWidget {
  const AStateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.primaryLabel,
    this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];
    if (primaryLabel != null && onPrimaryPressed != null) {
      actions.add(AButton.primary(
        label: primaryLabel!,
        onPressed: onPrimaryPressed,
      ));
    }
    if (secondaryLabel != null && onSecondaryPressed != null) {
      actions.add(AButton.text(
        label: secondaryLabel!,
        onPressed: onSecondaryPressed,
      ));
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool constrainedVertically =
            constraints.hasBoundedHeight && constraints.maxHeight < 360;
        final EdgeInsetsGeometry padding = constrainedVertically
            ? const EdgeInsetsDirectional.symmetric(
                horizontal: ASpacing.lg,
                vertical: ASpacing.lg,
              )
            : const EdgeInsetsDirectional.symmetric(
                horizontal: ASpacing.xxl,
                vertical: ASpacing.lg,
              );

        Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: AColors.primary),
            const SizedBox(height: ASpacing.lg),
            Text(
              title,
              style: ATypography.titleMd,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: ASpacing.sm),
              Text(
                message!,
                style: ATypography.bodySm,
                textAlign: TextAlign.center,
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: ASpacing.lg),
              Wrap(
                spacing: ASpacing.sm,
                runSpacing: ASpacing.sm,
                alignment: WrapAlignment.center,
                children: actions,
              ),
            ],
          ],
        );

        content = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: content,
        );

        if (constrainedVertically) {
          return Align(
            alignment: AlignmentDirectional.topCenter,
            child: SingleChildScrollView(
              padding: padding,
              child: content,
            ),
          );
        }

        return Center(
          child: Padding(
            padding: padding,
            child: content,
          ),
        );
      },
    );
  }
}
