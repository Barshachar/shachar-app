// Payment terms picker component
library;

import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Payment terms picker for checkout
class PaymentTermsPicker extends StatelessWidget {
  final String? selectedTermsId;
  final List<PaymentTermsOption> termsOptions;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const PaymentTermsPicker({
    super.key,
    this.selectedTermsId,
    required this.termsOptions,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('payment_terms_select'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'תנאי תשלום',
          style: TypographyPresets.labelMd(),
        ),
        Gaps.v3,
        ...termsOptions.map((terms) => _PaymentTermsTile(
              terms: terms,
              selected: selectedTermsId == terms.id,
              onTap: enabled ? () => onChanged(terms.id) : null,
            )),
      ],
    );
  }
}

class _PaymentTermsTile extends StatelessWidget {
  final PaymentTermsOption terms;
  final bool selected;
  final VoidCallback? onTap;

  const _PaymentTermsTile({
    required this.terms,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: ValueKey('payment_terms_${terms.id}'),
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
                  terms.name,
                  style: TypographyPresets.labelMd(),
                ),
                Gaps.v1,
                Text(
                  terms.description,
                  style: TypographyPresets.bodySm(
                    color: SemanticColors.mutedForeground,
                  ),
                ),
                if (terms.requiresApproval) ...[
                  Gaps.v2,
                  AppBadge(
                    text: 'דורש אישור',
                    variant: BadgeVariant.warning,
                    size: BadgeSize.sm,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment terms option
class PaymentTermsOption {
  final String id;
  final String code;
  final String name;
  final String description;
  final int netDays;
  final bool requiresApproval;

  const PaymentTermsOption({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.netDays,
    this.requiresApproval = false,
  });
}

/// Escrow badge for orders/invoices
class EscrowBadge extends StatelessWidget {
  final double amount;
  final String currency;
  final EscrowStatus status;

  const EscrowBadge({
    super.key,
    required this.amount,
    this.currency = 'ILS',
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return AppBadge(
      key: const ValueKey('escrow_badge'),
      text: '${config.label}: ${_formatAmount(amount, currency)}',
      variant: config.variant,
      icon: Icon(
        config.icon,
        size: Sizes.iconXs,
        color: _badgeIconColor(config.variant),
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    if (currency == 'ILS') {
      return '₪${amount.toStringAsFixed(2)}';
    }
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  _StatusConfig _getStatusConfig(EscrowStatus status) {
    switch (status) {
      case EscrowStatus.held:
        return _StatusConfig('בנאמנות', BadgeVariant.warning, Icons.lock);
      case EscrowStatus.released:
        return _StatusConfig('שוחרר', BadgeVariant.success, Icons.check_circle);
      case EscrowStatus.disputed:
        return _StatusConfig('במחלוקת', BadgeVariant.error, Icons.warning);
    }
  }
}

enum EscrowStatus { held, released, disputed }

class _StatusConfig {
  final String label;
  final BadgeVariant variant;
  final IconData icon;

  const _StatusConfig(this.label, this.variant, this.icon);
}

Color _badgeIconColor(BadgeVariant variant) {
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

/// Statement export button
class StatementExportButton extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback? onPressed;
  final bool loading;

  const StatementExportButton({
    super.key,
    required this.startDate,
    required this.endDate,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.secondary(
      key: const ValueKey('statement_export_btn'),
      text: 'ייצוא דוח',
      onPressed: onPressed,
      isLoading: loading,
      leadingIcon: const Icon(Icons.download),
    );
  }
}

/// Payout run button (vendor only)
class PayoutRunButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const PayoutRunButton({
    super.key,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      key: const ValueKey('payout_run_btn'),
      text: 'הפעל תשלום',
      onPressed: onPressed,
      isLoading: loading,
      leadingIcon: const Icon(Icons.account_balance),
    );
  }
}

/// Net terms calculator helper
class NetTermsCalculator {
  /// Calculate due date based on invoice date and net days
  static DateTime calculateDueDate(DateTime invoiceDate, int netDays) {
    return invoiceDate.add(Duration(days: netDays));
  }

  /// Check if payment is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Calculate days until/past due
  static int daysUntilDue(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Format due date status
  static String formatDueStatus(DateTime dueDate) {
    final days = daysUntilDue(dueDate);
    if (days < 0) {
      return 'באיחור ${days.abs()} ימים';
    } else if (days == 0) {
      return 'מועד תשלום היום';
    } else if (days <= 7) {
      return 'נותרו $days ימים';
    } else {
      return 'מועד: ${_formatDate(dueDate)}';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Due date badge
class DueDateBadge extends StatelessWidget {
  final DateTime dueDate;

  const DueDateBadge({
    super.key,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = NetTermsCalculator.isOverdue(dueDate);
    final days = NetTermsCalculator.daysUntilDue(dueDate);
    final isUrgent = days <= 7 && days >= 0;

    return AppBadge(
      text: NetTermsCalculator.formatDueStatus(dueDate),
      variant: isOverdue
          ? BadgeVariant.error
          : isUrgent
              ? BadgeVariant.warning
              : BadgeVariant.info,
      icon: Icon(
        isOverdue ? Icons.error : Icons.schedule,
        size: Sizes.iconXs,
        color: _badgeIconColor(isOverdue
            ? BadgeVariant.error
            : (isUrgent ? BadgeVariant.warning : BadgeVariant.info)),
      ),
    );
  }
}
