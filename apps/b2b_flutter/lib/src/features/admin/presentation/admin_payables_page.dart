import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

class AdminPayablesPage extends StatelessWidget {
  const AdminPayablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    final String title =
        l10n?.translate('adminPayablesTitle') ?? 'Accounts payable run';
    final String bankAccountLabel =
        l10n?.translate('adminPayablesBankAccount') ?? 'Bank account';
    final String scheduleDateLabel =
        l10n?.translate('adminPayablesScheduleDate') ?? 'Schedule date';
    final String filterVendorsLabel =
        l10n?.translate('adminPayablesFilterVendors') ?? 'Filter invoices';
    final String paymentMethodLabel =
        l10n?.translate('adminPayablesPaymentMethod') ?? 'Payment method';
    final String checksumLabel =
        l10n?.translate('adminPayablesChecksum') ?? 'Checksum';
    final String scheduleButton =
        l10n?.translate('adminPayablesSchedule') ?? 'Schedule payments';
    final String totalLabel =
        l10n?.translate('adminPayablesTotal') ?? 'Total invoice';
    final String dueDatesLabel =
        l10n?.translate('adminPayablesDueDates') ?? 'Due dates';

    return Scaffold(
      backgroundColor: AColors.background,
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ASpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: ARadii.lg,
                border: Border.all(color: AColors.cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ASpacing.lg),
                child: Wrap(
                  spacing: ASpacing.lg,
                  runSpacing: ASpacing.lg,
                  children: [
                    _PayablesDropdown(
                        label: bankAccountLabel, value: 'Business Checking'),
                    _PayablesDropdown(
                        label: scheduleDateLabel, value: 'Jun 14, 2024'),
                    _PayablesDropdown(
                        label: filterVendorsLabel, value: 'All vendors'),
                    _PayablesDropdown(
                        label: paymentMethodLabel, value: 'All accounts'),
                    SizedBox(
                      width: 240,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape:
                              RoundedRectangleBorder(borderRadius: ARadii.md),
                        ),
                        onPressed: () {},
                        child: Text('$checksumLabel: 3C9A'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ASpacing.xl),
            Card(
              shape: RoundedRectangleBorder(borderRadius: ARadii.lg),
              child: Padding(
                padding: const EdgeInsets.all(ASpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _InvoiceRow(
                      selected: true,
                      vendor: 'Horizon Supplies',
                      invoice: 'INV-01001',
                      amount: '\$4,200.00',
                    ),
                    Divider(),
                    _InvoiceRow(
                      selected: true,
                      vendor: 'Acme Manufacturing',
                      invoice: 'INV-2078',
                      amount: '\$5,750.00',
                    ),
                    Divider(),
                    _InvoiceRow(
                      selected: true,
                      vendor: 'Stark Distributors',
                      invoice: 'INV-1822',
                      amount: '\$1,365.00',
                    ),
                    Divider(),
                    _InvoiceRow(
                      selected: false,
                      vendor: 'Travis Paper Co.',
                      invoice: 'INV-00279',
                      amount: '\$2,135.00',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: ASpacing.md),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: totalLabel,
                    value: '\$10,450.00',
                    badge: 'ACH',
                  ),
                ),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: _SummaryTile(
                    label: dueDatesLabel,
                    value: 'Jun 04, 2024',
                    badge: 'ACH',
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: ARadii.md),
                ),
                onPressed: () {},
                child: Text(scheduleButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayablesDropdown extends StatelessWidget {
  const _PayablesDropdown({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 240),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: ARadii.md,
            borderSide: const BorderSide(color: AColors.cardBorder),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ASpacing.md,
            vertical: ASpacing.sm,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value, style: ATypography.bodySm)),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.selected,
    required this.vendor,
    required this.invoice,
    required this.amount,
  });

  final bool selected;
  final String vendor;
  final String invoice;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: selected, onChanged: (_) {}),
        Expanded(
          child: Text(vendor, style: ATypography.bodyLg),
        ),
        SizedBox(
          width: 80,
          child: Text(invoice, style: ATypography.bodySm),
        ),
        const SizedBox(width: ASpacing.md),
        Text(amount, style: ATypography.bodyLg),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    this.badge,
  });

  final String label;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ASpacing.md),
      decoration: BoxDecoration(
        color: AColors.surface,
        borderRadius: ARadii.md,
        border: Border.all(color: AColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ATypography.bodySm),
          const SizedBox(height: ASpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: ATypography.titleSm,
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ASpacing.sm,
                    vertical: ASpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AColors.primary.withValues(alpha: 0.12),
                    borderRadius: ARadii.pill,
                  ),
                  child: Text(
                    badge!,
                    style: ATypography.bodyXs.copyWith(color: AColors.primary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
