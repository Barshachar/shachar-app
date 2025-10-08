/// Enterprise-grade Card component
/// Professional cards with variants and interactive states
library;

import 'package:flutter/material.dart';
import 'package:design_system/src/tokens/tokens.dart';

/// Card variants
enum CardVariant {
  elevated,
  outlined,
  filled,
}

/// Card component
class AppCard extends StatefulWidget {
  final Widget child;
  final CardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final bool isInteractive;

  const AppCard({
    super.key,
    required this.child,
    this.variant = CardVariant.elevated,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.isInteractive = false,
  });

  const AppCard.elevated({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          child: child,
          variant: CardVariant.elevated,
          onTap: onTap,
          padding: padding,
        );

  const AppCard.outlined({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          child: child,
          variant: CardVariant.outlined,
          onTap: onTap,
          padding: padding,
        );

  const AppCard.filled({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          child: child,
          variant: CardVariant.filled,
          onTap: onTap,
          padding: padding,
        );

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null || widget.isInteractive;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: AnimationDurations.hover,
        curve: Easings.easeOut,
        decoration: _getDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            borderRadius: widget.borderRadius ?? BorderRadii.card,
            child: Padding(
              padding: widget.padding ?? Insets.cardMd,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: widget.backgroundColor ?? SemanticColors.card,
          borderRadius: widget.borderRadius ?? BorderRadii.card,
          boxShadow: widget.shadows ?? (_isHovered ? Shadows.md : Shadows.sm),
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? SemanticColors.card,
          borderRadius: widget.borderRadius ?? BorderRadii.card,
          border: Border.all(
            color:
                _isHovered ? SemanticColors.borderHover : SemanticColors.border,
            width: 1,
          ),
        );

      case CardVariant.filled:
        return BoxDecoration(
          color: widget.backgroundColor ?? SemanticColors.muted,
          borderRadius: widget.borderRadius ?? BorderRadii.card,
        );
    }
  }
}

/// Card header component
class CardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const CardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            Gaps.h3,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TypographyPresets.headingXs(),
                ),
                if (subtitle != null) ...[
                  Gaps.v1,
                  Text(
                    subtitle!,
                    style: TypographyPresets.bodySm(
                      color: SemanticColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            Gaps.h3,
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Card footer component
class CardFooter extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const CardFooter({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Gaps.h2);
      }
    }
    return result;
  }
}

/// Card content component
class CardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CardContent({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
  }
}

/// Complete card with header, content, and footer
class CompleteCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? headerLeading;
  final Widget? headerTrailing;
  final Widget content;
  final List<Widget>? footerActions;
  final CardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const CompleteCard({
    super.key,
    required this.title,
    this.subtitle,
    this.headerLeading,
    this.headerTrailing,
    required this.content,
    this.footerActions,
    this.variant = CardVariant.elevated,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: variant,
      onTap: onTap,
      padding: padding ?? Insets.cardMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CardHeader(
            title: title,
            subtitle: subtitle,
            leading: headerLeading,
            trailing: headerTrailing,
          ),
          Gaps.v4,
          CardContent(child: content),
          if (footerActions != null) ...[
            Gaps.v4,
            CardFooter(children: footerActions!),
          ],
        ],
      ),
    );
  }
}
