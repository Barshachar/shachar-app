/// Enterprise-grade Toast/Notification system
/// Professional toast messages with animations and variants
library;

import 'package:flutter/material.dart';
import 'package:design_system/src/tokens/tokens.dart';

/// Toast variant types
enum ToastVariant {
  info,
  success,
  warning,
  error,
}

/// Toast position on screen
enum ToastPosition {
  top,
  topRight,
  topLeft,
  bottom,
  bottomRight,
  bottomLeft,
}

/// Toast manager - singleton for showing toasts
class ToastManager {
  static final ToastManager _instance = ToastManager._internal();
  factory ToastManager() => _instance;
  ToastManager._internal();

  OverlayEntry? _currentOverlay;

  /// Show a toast message
  void show({
    required BuildContext context,
    required String message,
    String? title,
    ToastVariant variant = ToastVariant.info,
    ToastPosition position = ToastPosition.topRight,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    // Remove existing toast if any
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        title: title,
        variant: variant,
        position: position,
        duration: duration,
        onTap: onTap,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
          onDismiss?.call();
        },
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);
  }

  /// Show info toast
  void info(BuildContext context, String message, {String? title}) {
    show(
      context: context,
      message: message,
      title: title,
      variant: ToastVariant.info,
    );
  }

  /// Show success toast
  void success(BuildContext context, String message, {String? title}) {
    show(
      context: context,
      message: message,
      title: title,
      variant: ToastVariant.success,
    );
  }

  /// Show warning toast
  void warning(BuildContext context, String message, {String? title}) {
    show(
      context: context,
      message: message,
      title: title,
      variant: ToastVariant.warning,
    );
  }

  /// Show error toast
  void error(BuildContext context, String message, {String? title}) {
    show(
      context: context,
      message: message,
      title: title,
      variant: ToastVariant.error,
    );
  }
}

/// Toast overlay widget
class _ToastOverlay extends StatefulWidget {
  final String message;
  final String? title;
  final ToastVariant variant;
  final ToastPosition position;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    this.title,
    required this.variant,
    required this.position,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.toast,
    );

    _slideAnimation = Tween<Offset>(
      begin: _getInitialOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Easings.fastOutSlowIn,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Easings.easeOut,
    ));

    _controller.forward();

    // Auto dismiss after duration
    Future<void>.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Offset _getInitialOffset() {
    switch (widget.position) {
      case ToastPosition.top:
      case ToastPosition.topLeft:
      case ToastPosition.topRight:
        return const Offset(0, -1);
      case ToastPosition.bottom:
      case ToastPosition.bottomLeft:
      case ToastPosition.bottomRight:
        return const Offset(0, 1);
    }
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _isTop() ? Spacing.s4 : null,
      bottom: _isBottom() ? Spacing.s4 : null,
      left: _isLeft() ? Spacing.s4 : null,
      right: _isRight() ? Spacing.s4 : null,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _Toast(
              message: widget.message,
              title: widget.title,
              variant: widget.variant,
              onTap: widget.onTap,
              onDismiss: _dismiss,
            ),
          ),
        ),
      ),
    );
  }

  bool _isTop() {
    return widget.position == ToastPosition.top ||
        widget.position == ToastPosition.topLeft ||
        widget.position == ToastPosition.topRight;
  }

  bool _isBottom() {
    return widget.position == ToastPosition.bottom ||
        widget.position == ToastPosition.bottomLeft ||
        widget.position == ToastPosition.bottomRight;
  }

  bool _isLeft() {
    return widget.position == ToastPosition.topLeft ||
        widget.position == ToastPosition.bottomLeft;
  }

  bool _isRight() {
    return widget.position == ToastPosition.top ||
        widget.position == ToastPosition.topRight ||
        widget.position == ToastPosition.bottom ||
        widget.position == ToastPosition.bottomRight;
  }
}

/// Toast widget
class _Toast extends StatelessWidget {
  final String message;
  final String? title;
  final ToastVariant variant;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _Toast({
    required this.message,
    this.title,
    required this.variant,
    this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          minWidth: 300,
        ),
        margin: const EdgeInsets.symmetric(horizontal: Spacing.s4),
        decoration: BoxDecoration(
          color: SemanticColors.card,
          borderRadius: BorderRadii.lg,
          border: Border.all(
            color: colors['border']!,
            width: 1,
          ),
          boxShadow: Shadows.lg,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadii.lg,
          child: Padding(
            padding: Insets.all4,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.s2),
                  decoration: BoxDecoration(
                    color: colors['iconBackground'],
                    borderRadius: BorderRadii.md,
                  ),
                  child: Icon(
                    _getIcon(),
                    color: colors['iconColor'],
                    size: Sizes.iconMd,
                  ),
                ),
                Gaps.h3,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null) ...[
                        Text(
                          title!,
                          style: TypographyPresets.labelMd(
                            color: SemanticColors.foreground,
                          ),
                        ),
                        Gaps.v1,
                      ],
                      Text(
                        message,
                        style: TypographyPresets.bodySm(
                          color: SemanticColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.h2,
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: Sizes.iconSm,
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (variant) {
      case ToastVariant.info:
        return Icons.info_outline;
      case ToastVariant.success:
        return Icons.check_circle_outline;
      case ToastVariant.warning:
        return Icons.warning_amber_outlined;
      case ToastVariant.error:
        return Icons.error_outline;
    }
  }

  Map<String, Color> _getColors() {
    switch (variant) {
      case ToastVariant.info:
        return {
          'border': SemanticColors.info,
          'iconBackground': SemanticColors.infoSubtle,
          'iconColor': SemanticColors.info,
        };
      case ToastVariant.success:
        return {
          'border': SemanticColors.success,
          'iconBackground': SemanticColors.successSubtle,
          'iconColor': SemanticColors.success,
        };
      case ToastVariant.warning:
        return {
          'border': SemanticColors.warning,
          'iconBackground': SemanticColors.warningSubtle,
          'iconColor': SemanticColors.warning,
        };
      case ToastVariant.error:
        return {
          'border': SemanticColors.destructive,
          'iconBackground': SemanticColors.destructive.withValues(alpha: 0.1),
          'iconColor': SemanticColors.destructive,
        };
    }
  }
}

/// Snackbar - simpler alternative to toast
class AppSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadii.lg,
        ),
      ),
    );
  }
}
