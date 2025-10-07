/// Enterprise-grade Button component
/// Professional button with multiple variants, sizes, and states
library;

import 'package:flutter/material.dart';
import 'package:ashachar_marketplace/src/design_system/tokens/tokens.dart';

/// Button variants
enum ButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  link,
  destructive,
}

/// Button sizes
enum ButtonSize {
  sm,
  md,
  lg,
  xl,
}

/// Enterprise Button Component
class AppButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Color? customColor;
  final EdgeInsetsGeometry? customPadding;
  final BorderRadius? customRadius;
  final double? elevation;

  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.onLongPress,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.customColor,
    this.customPadding,
    this.customRadius,
    this.elevation,
  }) : assert(text != null || child != null,
            'Either text or child must be provided');

  /// Primary button constructor
  const AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.primary,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
        );

  /// Secondary button constructor
  const AppButton.secondary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.secondary,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
        );

  /// Outline button constructor
  const AppButton.outline({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.outline,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
        );

  /// Ghost button constructor
  const AppButton.ghost({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.ghost,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
        );

  /// Link button constructor
  const AppButton.link({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.link,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
        );

  /// Destructive button constructor
  const AppButton.destructive({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    ButtonSize size = ButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.destructive,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
        );

  /// Icon button constructor
  const AppButton.icon({
    Key? key,
    required Widget icon,
    required VoidCallback? onPressed,
    ButtonVariant variant = ButtonVariant.ghost,
    ButtonSize size = ButtonSize.md,
    bool isLoading = false,
    bool isDisabled = false,
  }) : this(
          key: key,
          child: icon,
          onPressed: onPressed,
          variant: variant,
          size: size,
          isLoading: isLoading,
          isDisabled: isDisabled,
        );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MicroInteractions.buttonPress.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
          parent: _controller, curve: MicroInteractions.buttonPress.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isInteractive =>
      !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  void _handleTapDown(TapDownDetails details) {
    if (_isInteractive) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isInteractive) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isInteractive) {
      _controller.reverse();
    }
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();
    final borderRadius = widget.customRadius ?? BorderRadii.button;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors['disabledBackground'];
        }
        if (states.contains(WidgetState.pressed)) {
          return colors['activeBackground'];
        }
        if (states.contains(WidgetState.hovered)) {
          return colors['hoverBackground'];
        }
        return colors['background'];
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors['disabledForeground'];
        }
        return colors['foreground'];
      }),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(widget.elevation ?? 0),
      padding: WidgetStateProperty.all(widget.customPadding ?? padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: _getBorderSide(colors),
        ),
      ),
      textStyle: WidgetStateProperty.all(textStyle),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Map<String, Color?> _getColors() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return {
          'background': widget.customColor ?? SemanticColors.primary,
          'hoverBackground': widget.customColor?.withValues(alpha: 0.9) ??
              SemanticColors.primaryHover,
          'activeBackground': widget.customColor?.withValues(alpha: 0.8) ??
              SemanticColors.primaryActive,
          'foreground': SemanticColors.primaryForeground,
          'disabledBackground': SemanticColors.muted,
          'disabledForeground': SemanticColors.mutedForeground,
        };

      case ButtonVariant.secondary:
        return {
          'background': SemanticColors.secondary,
          'hoverBackground': SemanticColors.secondaryHover,
          'activeBackground': SemanticColors.secondaryActive,
          'foreground': SemanticColors.secondaryForeground,
          'disabledBackground': SemanticColors.muted,
          'disabledForeground': SemanticColors.mutedForeground,
        };

      case ButtonVariant.outline:
        return {
          'background': Colors.transparent,
          'hoverBackground': SemanticColors.accent,
          'activeBackground': SemanticColors.accent,
          'foreground': SemanticColors.foreground,
          'disabledBackground': Colors.transparent,
          'disabledForeground': SemanticColors.mutedForeground,
        };

      case ButtonVariant.ghost:
        return {
          'background': Colors.transparent,
          'hoverBackground': SemanticColors.accent,
          'activeBackground': SemanticColors.accent.withValues(alpha: 0.8),
          'foreground': SemanticColors.foreground,
          'disabledBackground': Colors.transparent,
          'disabledForeground': SemanticColors.mutedForeground,
        };

      case ButtonVariant.link:
        return {
          'background': Colors.transparent,
          'hoverBackground': Colors.transparent,
          'activeBackground': Colors.transparent,
          'foreground': SemanticColors.primary,
          'disabledBackground': Colors.transparent,
          'disabledForeground': SemanticColors.mutedForeground,
        };

      case ButtonVariant.destructive:
        return {
          'background': SemanticColors.destructive,
          'hoverBackground': SemanticColors.destructiveHover,
          'activeBackground': SemanticColors.destructiveActive,
          'foreground': SemanticColors.destructiveForeground,
          'disabledBackground': SemanticColors.muted,
          'disabledForeground': SemanticColors.mutedForeground,
        };
    }
  }

  BorderSide _getBorderSide(Map<String, Color?> colors) {
    if (widget.variant == ButtonVariant.outline) {
      return BorderSide(
        color: widget.isDisabled
            ? SemanticColors.border
            : _isHovered
                ? SemanticColors.borderHover
                : SemanticColors.border,
        width: 1.5,
      );
    }
    return BorderSide.none;
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case ButtonSize.sm:
        return Insets.buttonSm;
      case ButtonSize.md:
        return Insets.buttonMd;
      case ButtonSize.lg:
        return Insets.buttonLg;
      case ButtonSize.xl:
        return EdgeInsets.symmetric(
          horizontal: Spacing.s8,
          vertical: Spacing.s4,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.sm:
        return TypographyPresets.buttonSm();
      case ButtonSize.md:
        return TypographyPresets.buttonMd();
      case ButtonSize.lg:
        return TypographyPresets.buttonLg();
      case ButtonSize.xl:
        return TypographyPresets.buttonLg().copyWith(fontSize: FontSizes.lg);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.sm:
        return Sizes.iconSm;
      case ButtonSize.md:
        return Sizes.iconMd;
      case ButtonSize.lg:
        return Sizes.iconLg;
      case ButtonSize.xl:
        return Sizes.iconXl;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (widget.isLoading) {
      content = _buildLoadingContent();
    } else if (widget.child != null) {
      content = widget.child!;
    } else {
      content = _buildTextContent();
    }

    Widget button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: _isInteractive
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ElevatedButton(
            onPressed: _isInteractive ? widget.onPressed : null,
            onLongPress: widget.onLongPress,
            style: _getButtonStyle(),
            child: content,
          ),
        ),
      ),
    );

    if (widget.isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildLoadingContent() {
    final iconSize = _getIconSize();
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(
              _getColors()['foreground'] ?? SemanticColors.primary,
            ),
          ),
        ),
        if (widget.text != null) ...[
          Gaps.h2,
          Text(widget.text!),
        ],
      ],
    );
  }

  Widget _buildTextContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: widget.leadingIcon,
          ),
          if (widget.text != null) Gaps.h2,
        ],
        if (widget.text != null)
          Flexible(
            child: Text(
              widget.text!,
              textAlign: TextAlign.center,
            ),
          ),
        if (widget.trailingIcon != null) ...[
          if (widget.text != null) Gaps.h2,
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: widget.trailingIcon,
          ),
        ],
      ],
    );
  }
}

/// Button Group - for grouping buttons together
class ButtonGroup extends StatelessWidget {
  final List<Widget> buttons;
  final Axis direction;
  final double spacing;

  const ButtonGroup({
    super.key,
    required this.buttons,
    this.direction = Axis.horizontal,
    this.spacing = Spacing.s2,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildChildren(),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> children = [];
    for (int i = 0; i < buttons.length; i++) {
      children.add(buttons[i]);
      if (i < buttons.length - 1) {
        children.add(direction == Axis.horizontal ? Gaps.h2 : Gaps.v2);
      }
    }
    return children;
  }
}
