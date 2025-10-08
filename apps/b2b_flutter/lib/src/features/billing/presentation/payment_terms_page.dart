import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/features/billing/data/payment_terms_repository.dart';
import 'package:ashachar_marketplace/src/features/billing/domain/payment_terms_models.dart';
import 'package:ashachar_marketplace/src/features/billing/presentation/payment_terms_controller.dart';

class PaymentTermsPage extends ConsumerStatefulWidget {
  const PaymentTermsPage({super.key});

  @override
  ConsumerState<PaymentTermsPage> createState() => _PaymentTermsPageState();
}

class _PaymentTermsPageState extends ConsumerState<PaymentTermsPage> {
  final TextEditingController _earlyDiscountPctController =
      TextEditingController();
  final TextEditingController _earlyDiscountDaysController =
      TextEditingController();
  final TextEditingController _lateFeeController = TextEditingController();
  final TextEditingController _gracePeriodController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _earlyDiscountPctController.dispose();
    _earlyDiscountDaysController.dispose();
    _lateFeeController.dispose();
    _gracePeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<VendorPaymentTermsProfile> profileAsync =
        ref.watch(vendorPaymentTermsProvider);
    final VendorPaymentTermsProfile? formState =
        ref.watch(paymentTermsFormProvider);

    if (formState != null) {
      final String pct =
          formState.earlyPayDiscountPct?.toStringAsFixed(1) ?? '';
      if (_earlyDiscountPctController.text != pct) {
        _earlyDiscountPctController.text = pct;
      }
      final String days = formState.earlyPayDiscountDays?.toString() ?? '';
      if (_earlyDiscountDaysController.text != days) {
        _earlyDiscountDaysController.text = days;
      }
      final String lateFee =
          formState.lateFeeInterestPct?.toStringAsFixed(1) ?? '';
      if (_lateFeeController.text != lateFee) {
        _lateFeeController.text = lateFee;
      }
      final String grace = formState.gracePeriodDays?.toString() ?? '';
      if (_gracePeriodController.text != grace) {
        _gracePeriodController.text = grace;
      }
    }

    return Scaffold(
      backgroundColor: AColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Payment Terms'),
        elevation: 0,
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => _PaymentTermsError(
            message: error.toString(),
            onRetry: () =>
                ref.read(vendorPaymentTermsProvider.notifier).refresh(),
          ),
          data: (VendorPaymentTermsProfile profile) {
            if (formState == null) {
              return const SizedBox.shrink();
            }
            final bool earlyEnabled = formState.earlyPayDiscountPct != null;
            final bool overridesEnabled = formState.allowOverrides;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(ASpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionCard(
                        title: 'Default payment terms',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration:
                                  _inputDecoration('Use for new vendors'),
                              value: formState.defaultTermsId,
                              items: profile.templates
                                  .map(
                                    (PaymentTermsTemplate template) =>
                                        DropdownMenuItem<String>(
                                      value: template.id,
                                      child: Text(template.displayName),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (String? value) {
                                if (value != null) {
                                  ref
                                      .read(paymentTermsFormProvider.notifier)
                                      .setDefaultTerms(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ASpacing.lg),
                      _SectionCard(
                        title: 'Allowed payment terms',
                        child: Column(
                          children: profile.templates
                              .map(
                                (PaymentTermsTemplate template) =>
                                    CheckboxListTile(
                                  value: formState.isAllowed(template.id),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(template.displayName),
                                  subtitle: template.description != null
                                      ? Text(template.description!)
                                      : null,
                                  onChanged: (bool? value) {
                                    if (value != null) {
                                      ref
                                          .read(
                                              paymentTermsFormProvider.notifier)
                                          .toggleAllowedTerms(
                                              template.id, value);
                                    }
                                  },
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: ASpacing.lg),
                      _SectionCard(
                        title: 'Early-pay discount',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile.adaptive(
                              value: earlyEnabled,
                              title: const Text(
                                  'Percent discount for early payment'),
                              onChanged: (bool value) {
                                ref
                                    .read(paymentTermsFormProvider.notifier)
                                    .setEarlyDiscount(enabled: value);
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _earlyDiscountPctController,
                                    enabled: earlyEnabled,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: _inputDecoration('%'),
                                    onChanged: (String value) {
                                      final double? parsed =
                                          double.tryParse(value);
                                      ref
                                          .read(
                                              paymentTermsFormProvider.notifier)
                                          .setEarlyDiscount(pct: parsed);
                                    },
                                  ),
                                ),
                                const SizedBox(width: ASpacing.md),
                                Expanded(
                                  child: TextField(
                                    controller: _earlyDiscountDaysController,
                                    enabled: earlyEnabled,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration('days'),
                                    onChanged: (String value) {
                                      final int? parsed = int.tryParse(value);
                                      ref
                                          .read(
                                              paymentTermsFormProvider.notifier)
                                          .setEarlyDiscount(days: parsed);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ASpacing.lg),
                      _SectionCard(
                        title: 'Late fee interest',
                        child: TextField(
                          controller: _lateFeeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _inputDecoration('1.5%').copyWith(
                            suffixText: '%',
                          ),
                          onChanged: (String value) {
                            final double? parsed = double.tryParse(value);
                            ref
                                .read(paymentTermsFormProvider.notifier)
                                .setLateFee(parsed);
                          },
                        ),
                      ),
                      const SizedBox(height: ASpacing.lg),
                      _SectionCard(
                        title: 'Grace period',
                        child: TextField(
                          controller: _gracePeriodController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('days'),
                          onChanged: (String value) {
                            final int? parsed = int.tryParse(value);
                            ref
                                .read(paymentTermsFormProvider.notifier)
                                .setGracePeriod(parsed);
                          },
                        ),
                      ),
                      const SizedBox(height: ASpacing.lg),
                      _SectionCard(
                        title: 'Vendor overrides',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile.adaptive(
                              value: overridesEnabled,
                              title: const Text('Set default terms per vendor'),
                              onChanged: (bool value) {
                                ref
                                    .read(paymentTermsFormProvider.notifier)
                                    .setAllowOverrides(value);
                              },
                            ),
                            if (overridesEnabled) ...[
                              const SizedBox(height: ASpacing.md),
                              if (formState.overrides.isEmpty)
                                Text(
                                  'No overrides yet. Add a vendor override to customize payment terms.',
                                  style: ATypography.bodySm.copyWith(
                                    color: AColors.mutedForeground,
                                  ),
                                )
                              else
                                ...formState.overrides.map(
                                  (VendorPaymentTermOverride override) =>
                                      ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(override.customerName),
                                    subtitle: Text(override.termsDisplayName),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () async {
                                        final ScaffoldMessengerState messenger =
                                            ScaffoldMessenger.of(context);
                                        try {
                                          await ref
                                              .read(vendorPaymentTermsProvider
                                                  .notifier)
                                              .removeOverride(override.id);
                                        } catch (error) {
                                          if (!mounted) return;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to remove override: $error'),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(height: ASpacing.md),
                              FilledButton.icon(
                                onPressed: () async {
                                  await _showAddOverrideDialog(
                                      context, formState);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add vendor override'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: ASpacing.xl),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AColors.primary,
                        ),
                        onPressed: _saving
                            ? null
                            : () async {
                                final VendorPaymentTermsProfile? pending =
                                    ref.read(paymentTermsFormProvider);
                                if (pending == null) {
                                  return;
                                }
                                final ScaffoldMessengerState messenger =
                                    ScaffoldMessenger.of(context);
                                setState(() => _saving = true);
                                try {
                                  await ref
                                      .read(vendorPaymentTermsProvider.notifier)
                                      .save(pending);
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Payment terms saved'),
                                    ),
                                  );
                                } catch (error) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Failed to save changes: $error'),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _saving = false);
                                  }
                                }
                              },
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _showAddOverrideDialog(
    BuildContext context,
    VendorPaymentTermsProfile profile,
  ) async {
    final TextEditingController searchController = TextEditingController();
    String? selectedCustomerId;
    String? selectedCustomerName;
    String selectedTermsId = profile.defaultTermsId;
    List<Map<String, dynamic>> results = <Map<String, dynamic>>[];
    final PaymentTermsRepository repository =
        ref.read(paymentTermsRepositoryProvider);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> runSearch(String query) async {
              final List<Map<String, dynamic>> response =
                  await repository.searchCustomers(query);
              setModalState(() => results = response);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: ASpacing.xl,
                right: ASpacing.xl,
                top: ASpacing.xl,
                bottom: MediaQuery.of(context).viewInsets.bottom + ASpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add vendor override',
                    style: ATypography.titleMd,
                  ),
                  const SizedBox(height: ASpacing.md),
                  TextField(
                    controller: searchController,
                    decoration: _inputDecoration('Search customer'),
                    onChanged: (String value) {
                      if (value.length >= 2) {
                        runSearch(value);
                      } else {
                        setModalState(() => results = <Map<String, dynamic>>[]);
                      }
                    },
                  ),
                  const SizedBox(height: ASpacing.md),
                  if (results.isNotEmpty)
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> item = results[index];
                          final bool selected =
                              item['id'] == selectedCustomerId;
                          return ListTile(
                            title: Text(item['name'] as String? ?? ''),
                            selected: selected,
                            onTap: () {
                              setModalState(() {
                                selectedCustomerId = item['id'] as String;
                                selectedCustomerName =
                                    item['name'] as String? ?? '';
                              });
                            },
                          );
                        },
                      ),
                    )
                  else
                    Text(
                      'Type at least two characters to search customers',
                      style: ATypography.bodySm.copyWith(
                        color: AColors.mutedForeground,
                      ),
                    ),
                  const SizedBox(height: ASpacing.lg),
                  DropdownButtonFormField<String>(
                    value: selectedTermsId,
                    decoration: _inputDecoration('Terms'),
                    items: profile.templates
                        .map(
                          (PaymentTermsTemplate template) => DropdownMenuItem(
                            value: template.id,
                            child: Text(template.displayName),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (String? value) {
                      if (value != null) {
                        setModalState(() => selectedTermsId = value);
                      }
                    },
                  ),
                  const SizedBox(height: ASpacing.lg),
                  FilledButton(
                    onPressed: selectedCustomerId == null
                        ? null
                        : () async {
                            final NavigatorState navigator =
                                Navigator.of(context);
                            final ScaffoldMessengerState messenger =
                                ScaffoldMessenger.of(context);
                            try {
                              await ref
                                  .read(vendorPaymentTermsProvider.notifier)
                                  .addOverride(
                                    vendorId: profile.vendorId,
                                    customerId: selectedCustomerId!,
                                    termsId: selectedTermsId,
                                  );
                              if (!mounted) return;
                              navigator.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Override added for $selectedCustomerName',
                                  ),
                                ),
                              );
                            } catch (error) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to create override: $error'),
                                ),
                              );
                            }
                          },
                    child: const Text('Assign'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ASpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.md),
          child,
        ],
      ),
    );
  }
}

class _PaymentTermsError extends StatelessWidget {
  const _PaymentTermsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AColors.danger),
          const SizedBox(height: ASpacing.md),
          Text('Unable to load payment terms',
              style: ATypography.titleSm, textAlign: TextAlign.center),
          const SizedBox(height: ASpacing.sm),
          Text(
            message,
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ASpacing.lg),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
