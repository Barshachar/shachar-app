import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/design_system/components/components.dart';
import 'package:ashachar_marketplace/src/features/finance/domain/cost_center.dart';
import 'package:ashachar_marketplace/src/features/finance/presentation/cost_centers_controller.dart';

class CostCentersPage extends ConsumerWidget {
  const CostCentersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CostCenter>> centersAsync =
        ref.watch(costCenterListProvider);
    final CostCenterFilterState filters = ref.watch(costCenterFilterProvider);

    return Scaffold(
      backgroundColor: AColors.background,
      appBar: AppBar(
        title: const Text('GL / Cost Centers'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AColors.foreground,
      ),
      body: SafeArea(
        child: centersAsync.when(
          loading: () => const _CostCentersLoading(),
          error: (Object error, StackTrace stackTrace) => _CostCentersError(
            message: error.toString(),
            onRetry: () => ref.read(costCenterListProvider.notifier).refresh(),
          ),
          data: (List<CostCenter> data) {
            final List<CostCenter> filtered = _applyFilters(data, filters);
            final Set<String> businessUnits =
                data.map((CostCenter center) => center.businessUnit).toSet();
            final Set<String> codes = data
                .where((CostCenter center) =>
                    filters.businessUnit == null ||
                    center.businessUnit == filters.businessUnit)
                .map((CostCenter center) => center.code)
                .toSet();

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(costCenterListProvider.notifier).refresh();
              },
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(
                    start: constraints.maxWidth >= 768 ? 120 : ASpacing.page,
                    end: constraints.maxWidth >= 768 ? 120 : ASpacing.page,
                    top: ASpacing.xl,
                    bottom: ASpacing.xl,
                  );
                  return ListView(
                    padding: padding,
                    children: [
                      _FiltersRow(
                        businessUnits: businessUnits.toList()..sort(),
                        codes: codes.toList()..sort(),
                      ),
                      const SizedBox(height: ASpacing.xl),
                      if (filtered.isEmpty)
                        const _EmptyState()
                      else
                        ...filtered.map(
                          (CostCenter center) => Padding(
                            padding: const EdgeInsets.only(bottom: ASpacing.lg),
                            child: CostCenterCard(center: center),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New cost center form coming soon.')),
          );
        },
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
        label: const Text('New'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  List<CostCenter> _applyFilters(
    List<CostCenter> centers,
    CostCenterFilterState filters,
  ) {
    return centers.where((CostCenter center) {
      final bool businessUnitMatches = filters.businessUnit == null ||
          center.businessUnit == filters.businessUnit;
      final bool costCenterMatches = filters.costCenterCode == null ||
          center.code == filters.costCenterCode;
      final bool statusMatches = switch (filters.status) {
        CostCenterStatusFilter.all => true,
        CostCenterStatusFilter.active =>
          center.status == CostCenterStatus.active,
        CostCenterStatusFilter.archived =>
          center.status == CostCenterStatus.archived,
        CostCenterStatusFilter.requiresApprover => center.requiresApprover,
      };
      return businessUnitMatches && costCenterMatches && statusMatches;
    }).toList(growable: false);
  }
}

class _CostCentersLoading extends StatelessWidget {
  const _CostCentersLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _CostCentersError extends StatelessWidget {
  const _CostCentersError({required this.message, required this.onRetry});

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
          Text(
            'Unable to load cost centers',
            style: ATypography.titleSm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            message,
            style: ATypography.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ASpacing.lg),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ASpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ARadii.lg,
        boxShadow: AElevation.shadowSoft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 48, color: AColors.mutedForeground),
          const SizedBox(height: ASpacing.md),
          Text(
            'No cost centers yet',
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            'Create a cost center to start tracking GL rules.',
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FiltersRow extends ConsumerWidget {
  const _FiltersRow({required this.businessUnits, required this.codes});

  final List<String> businessUnits;
  final List<String> codes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CostCenterFilterNotifier notifier =
        ref.read(costCenterFilterProvider.notifier);
    final CostCenterFilterState state = ref.watch(costCenterFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: ASpacing.lg,
          runSpacing: ASpacing.md,
          children: [
            _DropdownFilter<String>(
              label: 'Business Unit',
              value: state.businessUnit,
              items: businessUnits,
              placeholder: 'All units',
              onChanged: notifier.setBusinessUnit,
            ),
            _DropdownFilter<String>(
              label: 'Cost Center',
              value: state.costCenterCode,
              items: codes,
              placeholder: 'All cost centers',
              onChanged: notifier.setCostCenterCode,
            ),
            _DropdownFilter<CostCenterStatusFilter>(
              label: 'Status',
              value: state.status,
              items: CostCenterStatusFilter.values,
              placeholder: 'All statuses',
              displayStringForOption: (CostCenterStatusFilter filter) {
                return switch (filter) {
                  CostCenterStatusFilter.all => 'All',
                  CostCenterStatusFilter.active => 'Active',
                  CostCenterStatusFilter.archived => 'Archived',
                  CostCenterStatusFilter.requiresApprover =>
                    'Requires Approver',
                };
              },
              onChanged: (value) {
                if (value != null) {
                  notifier.setStatus(value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: ASpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filtered results',
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export queued')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
                const SizedBox(width: ASpacing.md),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AColors.primary,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New cost center workflow in progress'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _DropdownFilter<T> extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder,
    this.displayStringForOption,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? placeholder;
  final String Function(T value)? displayStringForOption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            hint: Text(placeholder ?? 'Select'),
            items: [
              if (placeholder != null)
                DropdownMenuItem<T>(
                  value: null,
                  child: Text(placeholder!),
                ),
              ...items.map(
                (T option) => DropdownMenuItem<T>(
                  value: option,
                  child: Text(
                    displayStringForOption?.call(option) ?? option.toString(),
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class CostCenterCard extends ConsumerWidget {
  const CostCenterCard({required this.center, super.key});

  final CostCenter center;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NumberFormat currencyFormat = NumberFormat.currency(symbol: '₪');
    final String budgetRemaining =
        currencyFormat.format(center.remainingBudget.abs());
    final String budgetAllocated = currencyFormat.format(center.ytdBudget);
    final CostCenterListController controller =
        ref.read(costCenterListProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(color: AColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost Center Code',
                        style: ATypography.bodySm,
                      ),
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        center.code,
                        style: ATypography.titleSm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (center.requiresApprover)
                      AppBadge(
                        text: 'Requires Approver',
                        variant: BadgeVariant.warning,
                        icon: const Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: AColors.warning,
                        ),
                      ),
                    const SizedBox(height: ASpacing.sm),
                    Row(
                      children: [
                        Text(
                          center.status == CostCenterStatus.active
                              ? 'Active'
                              : 'Archived',
                          style: ATypography.bodySm,
                        ),
                        Switch.adaptive(
                          value: center.status == CostCenterStatus.active,
                          activeColor: AColors.success,
                          onChanged: (bool value) async {
                            try {
                              await controller.toggleActive(
                                id: center.id,
                                active: value,
                              );
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to update: $error')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: ASpacing.lg),
            Wrap(
              spacing: ASpacing.xl,
              runSpacing: ASpacing.md,
              children: [
                _InfoBlock(
                  label: 'Department',
                  value: center.name,
                ),
                _InfoBlock(
                  label: 'Business Unit',
                  value: center.businessUnit,
                ),
                _InfoBlock(
                  label: 'YTD Budget',
                  value: center.isOverBudget
                      ? 'Over budget by $budgetRemaining'
                      : '$budgetRemaining remaining',
                  helper: 'Allocated $budgetAllocated',
                  helperStyle: center.isOverBudget
                      ? ATypography.bodySm.copyWith(color: AColors.danger)
                      : ATypography.bodySm.copyWith(
                          color: AColors.mutedForeground,
                        ),
                  leading: Icon(
                    center.isOverBudget
                        ? Icons.warning_amber_outlined
                        : Icons.trending_up,
                    color:
                        center.isOverBudget ? AColors.danger : AColors.success,
                  ),
                ),
                if (center.approverName != null)
                  _InfoBlock(
                    label: 'Approver',
                    value: center.approverName!,
                  ),
                if (center.autoAssignRules.isNotEmpty)
                  _InfoBlock(
                    label: 'Auto Assign Rules',
                    value: center.autoAssignRules
                        .map((CostCenterRule rule) =>
                            '${rule.label} = ${rule.value}')
                        .join('\n'),
                  ),
              ],
            ),
            if (center.notes != null) ...[
              const SizedBox(height: ASpacing.md),
              Text(
                center.notes!,
                style:
                    ATypography.bodySm.copyWith(color: AColors.mutedForeground),
              ),
            ],
            const SizedBox(height: ASpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: ASpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Edit ${center.code} coming soon')),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final bool newValue = !center.requiresApprover;
                        try {
                          await controller.toggleRequiresApprover(
                            id: center.id,
                            requires: newValue,
                          );
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to update: $error')),
                            );
                          }
                        }
                      },
                      child: Text(
                        center.requiresApprover
                            ? 'Mark as auto-approved'
                            : 'Require approver',
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Opening mapping for ${center.code}')),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  label: const Text('View Mapping'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    required this.value,
    this.helper,
    this.helperStyle,
    this.leading,
  });

  final String label;
  final String value;
  final String? helper;
  final TextStyle? helperStyle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
          ),
          const SizedBox(height: ASpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: ASpacing.xs),
              ],
              Expanded(
                child: Text(
                  value,
                  style: ATypography.bodyMd,
                ),
              ),
            ],
          ),
          if (helper != null) ...[
            const SizedBox(height: ASpacing.xs),
            Text(
              helper!,
              style: helperStyle ??
                  ATypography.caption.copyWith(color: AColors.mutedForeground),
            ),
          ],
        ],
      ),
    );
  }
}
