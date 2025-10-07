/// Enterprise-grade Dialog/Modal components
/// Professional dialogs with animations and variants
library;

import 'package:flutter/material.dart';
import 'package:ashachar_marketplace/src/design_system/tokens/tokens.dart';
import 'package:ashachar_marketplace/src/design_system/components/button.dart';

/// Dialog sizes
enum DialogSize { sm, md, lg, xl, fullscreen }

/// Show custom dialog
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color? barrierColor,
  DialogSize size = DialogSize.md,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? Colors.black54,
    builder: (context) => AppDialog(
      size: size,
      child: child,
    ),
  );
}

/// App Dialog component
class AppDialog extends StatelessWidget {
  final Widget child;
  final DialogSize size;
  final EdgeInsetsGeometry? padding;

  const AppDialog({
    super.key,
    required this.child,
    this.size = DialogSize.md,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: _getInsetPadding(),
      child: Container(
        constraints: _getConstraints(),
        decoration: BoxDecoration(
          color: SemanticColors.background,
          borderRadius: BorderRadii.dialog,
          boxShadow: Shadows.xl,
        ),
        child: ClipRRect(
          borderRadius: BorderRadii.dialog,
          child: Padding(
            padding: padding ?? Insets.dialogMd,
            child: child,
          ),
        ),
      ),
    );
  }

  BoxConstraints _getConstraints() {
    switch (size) {
      case DialogSize.sm:
        return Constraints.constraintsSm;
      case DialogSize.md:
        return Constraints.constraintsMd;
      case DialogSize.lg:
        return Constraints.constraintsLg;
      case DialogSize.xl:
        return Constraints.constraintsXl;
      case DialogSize.fullscreen:
        return const BoxConstraints.expand();
    }
  }

  EdgeInsets _getInsetPadding() {
    if (size == DialogSize.fullscreen) {
      return EdgeInsets.zero;
    }
    return const EdgeInsets.symmetric(
      horizontal: Spacing.s6,
      vertical: Spacing.s6,
    );
  }
}

/// Alert Dialog - for confirmations and alerts
class AlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? icon;
  final Color? confirmColor;
  final bool isDestructive;

  const AlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.confirmColor,
    this.isDestructive = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Widget? icon,
    bool isDestructive = false,
  }) {
    return showAppDialog<bool>(
      context: context,
      size: DialogSize.sm,
      child: AlertDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (icon != null) ...[
          Center(child: icon!),
          Gaps.v4,
        ],
        Text(
          title,
          style: TypographyPresets.headingSm(),
          textAlign: TextAlign.center,
        ),
        Gaps.v3,
        Text(
          message,
          style: TypographyPresets.bodyMd(
            color: SemanticColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
        Gaps.v6,
        Row(
          children: [
            if (cancelText != null || onCancel != null)
              Expanded(
                child: AppButton.outline(
                  text: cancelText ?? 'ביטול',
                  onPressed: onCancel ?? () => Navigator.of(context).pop(false),
                ),
              ),
            if ((cancelText != null || onCancel != null) &&
                (confirmText != null || onConfirm != null))
              Gaps.h2,
            if (confirmText != null || onConfirm != null)
              Expanded(
                child: isDestructive
                    ? AppButton.destructive(
                        text: confirmText ?? 'אישור',
                        onPressed:
                            onConfirm ?? () => Navigator.of(context).pop(true),
                      )
                    : AppButton.primary(
                        text: confirmText ?? 'אישור',
                        onPressed:
                            onConfirm ?? () => Navigator.of(context).pop(true),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Dialog header component
class DialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const DialogHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TypographyPresets.headingSm(),
              ),
            ),
            if (showCloseButton) ...[
              Gaps.h2,
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose ?? () => Navigator.of(context).pop(),
                iconSize: Sizes.iconMd,
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          Gaps.v2,
          Text(
            subtitle!,
            style: TypographyPresets.bodySm(
              color: SemanticColors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}

/// Dialog content component
class DialogContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DialogContent({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: Spacing.s4),
      child: child,
    );
  }
}

/// Dialog footer component
class DialogFooter extends StatelessWidget {
  final List<Widget> actions;
  final MainAxisAlignment alignment;

  const DialogFooter({
    super.key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    final List<Widget> result = [];
    for (int i = 0; i < actions.length; i++) {
      result.add(actions[i]);
      if (i < actions.length - 1) {
        result.add(Gaps.h2);
      }
    }
    return result;
  }
}

/// Bottom Sheet - mobile-friendly modal
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showCloseButton;
  final bool isDismissible;
  final double? maxHeight;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showCloseButton = true,
    this.isDismissible = true,
    this.maxHeight,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showCloseButton = true,
    bool isDismissible = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        showCloseButton: showCloseButton,
        isDismissible: isDismissible,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultMaxHeight = screenHeight * 0.9;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? defaultMaxHeight,
      ),
      decoration: BoxDecoration(
        color: SemanticColors.background,
        borderRadius: BorderRadii.topLg,
        boxShadow: Shadows.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDismissible)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: Spacing.s3),
                width: Spacing.s12,
                height: Spacing.s1,
                decoration: BoxDecoration(
                  color: SemanticColors.border,
                  borderRadius: BorderRadii.full,
                ),
              ),
            ),
          if (title != null)
            Padding(
              padding: Insets.horizontalMd.add(Insets.verticalSm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: TypographyPresets.headingSm(),
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      iconSize: Sizes.iconMd,
                    ),
                ],
              ),
            ),
          Flexible(
            child: Padding(
              padding: Insets.horizontalMd.add(Insets.bottomMd),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer component
class AppDrawer extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? header;
  final double? width;

  const AppDrawer({
    super.key,
    required this.child,
    this.title,
    this.header,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            header!
          else if (title != null)
            Padding(
              padding: Insets.all4,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: TypographyPresets.headingSm(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
