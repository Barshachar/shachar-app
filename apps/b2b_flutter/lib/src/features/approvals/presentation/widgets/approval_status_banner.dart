import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';

class ApprovalStatusBanner extends StatelessWidget {
  const ApprovalStatusBanner({
    super.key,
    required this.state,
    required this.l10n,
    this.margin,
  });

  final OrderApprovalState state;
  final MarketplaceLocalizations? l10n;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final _BannerStyle style = _resolveStyle(state.stage);
    final String message = _resolveMessage(context);
    final List<Widget> children = <Widget>[
      Icon(style.icon, color: style.foreground, size: 20),
      const SizedBox(width: ASpacing.sm),
      Expanded(
        child: Text(
          message,
          style: ATypography.bodySm.copyWith(color: style.foreground),
        ),
      ),
    ];

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(ASpacing.md),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: ARadii.md,
        border: Border.all(color: style.border),
      ),
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  String _resolveMessage(BuildContext context) {
    final MarketplaceLocalizations? localizations = l10n;

    switch (state.stage) {
      case OrderApprovalStage.notRequired:
        return localizations?.translate('approvalBannerNotRequired') ??
            'No approval required. Continue to submit when ready.';
      case OrderApprovalStage.readyToRequest:
        return localizations?.translate('approvalBannerRequires') ??
            'This order requires approval before submission.';
      case OrderApprovalStage.pending:
        return localizations?.translate('approvalBannerPending') ??
            'Awaiting approval from your approvers.';
      case OrderApprovalStage.approved:
        return localizations?.translate('approvalBannerApproved') ??
            'Approved — ready to submit.';
      case OrderApprovalStage.rejected:
        final String? note = state.note?.trim();
        if (note != null && note.isNotEmpty) {
          final String template =
              localizations?.translate('approvalBannerRejectedWithReason') ??
                  'Approval rejected: {reason}';
          return template.replaceFirst('{reason}', note);
        }
        return localizations?.translate('approvalBannerRejected') ??
            'Approval was rejected. Update and resend.';
    }
  }

  _BannerStyle _resolveStyle(OrderApprovalStage stage) {
    switch (stage) {
      case OrderApprovalStage.notRequired:
      case OrderApprovalStage.readyToRequest:
        return const _BannerStyle(
          background: AColors.surfaceSubtle,
          border: AColors.cardBorder,
          foreground: AColors.neutral600,
          icon: Icons.info_outline,
        );
      case OrderApprovalStage.pending:
        return _BannerStyle(
          background: AColors.warning.withValues(alpha: 0.12),
          border: AColors.warning.withValues(alpha: 0.4),
          foreground: const Color(0xFF8A6100),
          icon: Icons.hourglass_bottom,
        );
      case OrderApprovalStage.approved:
        return _BannerStyle(
          background: AColors.success.withValues(alpha: 0.12),
          border: AColors.success.withValues(alpha: 0.4),
          foreground: AColors.success,
          icon: Icons.check_circle_outline,
        );
      case OrderApprovalStage.rejected:
        return _BannerStyle(
          background: AColors.dangerSurface,
          border: AColors.dangerBorder,
          foreground: AColors.danger,
          icon: Icons.error_outline,
        );
    }
  }
}

class _BannerStyle {
  const _BannerStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;
}
