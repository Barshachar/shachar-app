import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/presentation/status_tokens.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.status,
    this.l10n,
    this.compact = false,
  });

  final String status;
  final MarketplaceLocalizations? l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? effectiveL10n = l10n ??
        Localizations.of<MarketplaceLocalizations>(
          context,
          MarketplaceLocalizations,
        );
    final StatusChipStyle style = resolveStatusChipStyle(
      status: status,
      l10n: effectiveL10n,
    );
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: compact ? ASpacing.sm : ASpacing.md,
      vertical: compact ? ASpacing.xs : ASpacing.sm,
    );
    final TextStyle textStyle =
        (compact ? ATypography.bodySm : ATypography.chip)
            .copyWith(color: style.foreground);

    return Semantics(
      label: style.label,
      container: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: ARadii.sm,
            border: Border.all(
              color: style.foreground.withValues(alpha: 0.4),
            ),
            boxShadow: compact ? null : AElevation.shadowSoft,
          ),
          child: Padding(
            padding: padding,
            child: Text(
              style.label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
