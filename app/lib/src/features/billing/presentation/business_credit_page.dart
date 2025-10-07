import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/features/billing/data/business_credit_providers.dart';
import 'package:ashachar_marketplace/src/features/billing/domain/entities/business_credit_models.dart';

class BusinessCreditPage extends ConsumerWidget {
  const BusinessCreditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<BusinessCreditSettings> settingsAsync =
        ref.watch(businessCreditSettingsProvider);
    final EdgeInsets padding =
        context.pagePadding().resolve(Directionality.of(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Credit'),
      ),
      backgroundColor: AColors.background,
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Text('Failed to load credit details.\n$error'),
        ),
        data: (BusinessCreditSettings settings) {
          final intl.NumberFormat currency =
              intl.NumberFormat.simpleCurrency(name: 'USD');
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x140F1A2E),
                        blurRadius: 32,
                        offset: Offset(0, 24),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CreditHeader(
                          snapshot: settings.snapshot,
                          formatter: currency,
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        _PaymentMethodsSection(
                          paymentMethods: settings.paymentMethods,
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        _PaymentTermsSection(
                          selectedTerm: settings.selectedTerm,
                          purchaseOrdersEnabled: settings.purchaseOrdersEnabled,
                          automaticPaymentsEnabled:
                              settings.automaticPaymentsEnabled,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: ATypography.button,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Credit preferences saved'),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CreditHeader extends StatelessWidget {
  const _CreditHeader({
    required this.snapshot,
    required this.formatter,
  });

  final BusinessCreditSnapshot snapshot;
  final intl.NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Credit',
          style: ATypography.titleLg.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Credit limit',
                value: formatter.format(snapshot.creditLimit),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _SummaryTile(
                label: 'Available balance',
                value: formatter.format(snapshot.availableBalance),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ATypography.bodySm.copyWith(
            color: AColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: ATypography.headline2.copyWith(fontSize: 22),
        ),
      ],
    );
  }
}

class _PaymentMethodsSection extends StatelessWidget {
  const _PaymentMethodsSection({
    required this.paymentMethods,
  });

  final List<PaymentMethod> paymentMethods;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Methods',
          style: ATypography.titleMd,
        ),
        const SizedBox(height: 16),
        ...List.generate(paymentMethods.length, (int index) {
          final PaymentMethod method = paymentMethods[index];
          return Column(
            children: [
              _PaymentMethodTile(method: method),
              if (index != paymentMethods.length - 1)
                const Divider(height: 24, thickness: 0.6),
            ],
          );
        }),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Add payment method flow coming soon')),
            );
          },
          icon: const Icon(Icons.add, color: Colors.red),
          label: const Text(
            'Add payment method',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
  });

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = method.type == PaymentMethodType.card
        ? AColors.primary
        : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _MethodBadge(
              label: method.type.label.toUpperCase(),
              color: accentColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                method.displayLabel,
                style: ATypography.bodyLg,
              ),
            ),
            const Icon(Icons.chevron_right, color: AColors.neutral400),
          ],
        ),
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: ATypography.label.copyWith(color: color),
      ),
    );
  }
}

class _PaymentTermsSection extends StatefulWidget {
  const _PaymentTermsSection({
    required this.selectedTerm,
    required this.purchaseOrdersEnabled,
    required this.automaticPaymentsEnabled,
  });

  final PaymentTermOption selectedTerm;
  final bool purchaseOrdersEnabled;
  final bool automaticPaymentsEnabled;

  @override
  State<_PaymentTermsSection> createState() => _PaymentTermsSectionState();
}

class _PaymentTermsSectionState extends State<_PaymentTermsSection> {
  late bool _purchaseOrdersEnabled = widget.purchaseOrdersEnabled;
  late bool _automaticPaymentsEnabled = widget.automaticPaymentsEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Terms & Options',
          style: ATypography.titleMd,
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.selectedTerm.name,
              style: ATypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _ToggleRow(
          label: 'Enable purchase order',
          value: _purchaseOrdersEnabled,
          onChanged: (bool value) {
            setState(() => _purchaseOrdersEnabled = value);
          },
        ),
        const SizedBox(height: 16),
        _ToggleRow(
          label: 'Automatic payments',
          value: _automaticPaymentsEnabled,
          activeColor: AColors.primary,
          onChanged: (bool value) {
            setState(() => _automaticPaymentsEnabled = value);
          },
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: ATypography.bodyLg,
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: activeColor ?? AColors.neutral400,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
