import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

class AdminOrderApprovalPage extends StatelessWidget {
  const AdminOrderApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    final String title =
        l10n?.translate('adminApprovalTitle') ?? 'Order approval';
    final String cartItemsLabel =
        l10n?.translate('adminApprovalCartItems') ?? 'Cart items';
    final String subtotalLabel =
        l10n?.translate('adminApprovalSubtotal') ?? 'Subtotal';
    final String flagBudget =
        l10n?.translate('adminApprovalFlagOverBudget') ?? 'Over budget';
    final String flagVendor =
        l10n?.translate('adminApprovalFlagNonPreferred') ??
            'Non-preferred vendor';
    final String flagSplit =
        l10n?.translate('adminApprovalFlagSplit') ?? 'Split by warehouse';
    final String budgetHeading =
        l10n?.translate('adminApprovalBudgetHeading') ?? 'Budget utilization';
    final String commentLabel =
        l10n?.translate('adminApprovalAddComment') ?? 'Add a comment...';
    final String approve = l10n?.translate('adminApprovalApprove') ?? 'Approve';
    final String reject = l10n?.translate('adminApprovalReject') ?? 'Reject';
    final String rejectReason = l10n?.translate('adminApprovalRejectReason') ??
        'Reject reason required';
    final String viewCart =
        l10n?.translate('adminApprovalViewCart') ?? 'View cart items';
    final String slaLabel = l10n?.translate('adminApprovalSla') ?? 'SLA';

    return Scaffold(
      backgroundColor: AColors.background,
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ASpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(ASpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: ARadii.lg,
                border: Border.all(color: AColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('David Smith', style: ATypography.titleSm),
                  const SizedBox(height: ASpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _KeyValue(label: cartItemsLabel, value: '7 items'),
                      ),
                      Expanded(
                        child:
                            _KeyValue(label: subtotalLabel, value: '2,750.00'),
                      ),
                    ],
                  ),
                  const SizedBox(height: ASpacing.lg),
                  _FlagRow(
                    icon: Icons.error_outline,
                    label: flagBudget,
                    color: AColors.danger,
                  ),
                  _FlagRow(
                    icon: Icons.warning_amber_rounded,
                    label: flagVendor,
                    color: AColors.warning,
                  ),
                  _FlagRow(
                    icon: Icons.store_mall_directory_outlined,
                    label: flagSplit,
                    color: AColors.primary,
                  ),
                  const SizedBox(height: ASpacing.lg),
                  Text(budgetHeading, style: ATypography.bodySm),
                  const SizedBox(height: ASpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Amount used', style: ATypography.bodySm),
                            SizedBox(height: ASpacing.xs),
                            Text('\$12,800 of \$10,000',
                                style: ATypography.bodyLg),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: 0.78,
                              strokeWidth: 8,
                              color: AColors.danger,
                              backgroundColor:
                                  AColors.danger.withValues(alpha: 0.15),
                            ),
                            Text('28%', style: ATypography.bodyLg),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ASpacing.lg),
                  TextField(
                    decoration: InputDecoration(
                      hintText: commentLabel,
                      border: OutlineInputBorder(
                        borderRadius: ARadii.md,
                        borderSide: const BorderSide(color: AColors.cardBorder),
                      ),
                      contentPadding: const EdgeInsets.all(ASpacing.md),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: ASpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          child: Text(approve),
                        ),
                      ),
                      const SizedBox(width: ASpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AColors.danger,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                          child: Text(reject),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ASpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      rejectReason,
                      style: ATypography.bodyXs.copyWith(color: AColors.danger),
                    ),
                  ),
                  const SizedBox(height: ASpacing.md),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chevron_right, size: 18),
                        const SizedBox(width: ASpacing.xs),
                        Text(viewCart),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ASpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$slaLabel: 02:14:30', style: ATypography.bodySm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground)),
        const SizedBox(height: ASpacing.xs),
        Text(value, style: ATypography.bodyLg),
      ],
    );
  }
}

class _FlagRow extends StatelessWidget {
  const _FlagRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ASpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: ASpacing.xs),
          Expanded(
            child: Text(
              label,
              style: ATypography.bodySm,
            ),
          ),
        ],
      ),
    );
  }
}
