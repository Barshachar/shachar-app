import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/core/errors/user_friendly_error_handler.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/admin/data/audit_log_providers.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/audit_log_entry.dart';

class AdminAuditLogPage extends ConsumerStatefulWidget {
  const AdminAuditLogPage({super.key});

  @override
  ConsumerState<AdminAuditLogPage> createState() => _AdminAuditLogPageState();
}

class _AdminAuditLogPageState extends ConsumerState<AdminAuditLogPage> {
  final TextEditingController _dateRangeController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _moduleController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  @override
  void dispose() {
    _dateRangeController.dispose();
    _userController.dispose();
    _moduleController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  void _applyFilters(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _export(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title = l10n?.translate('adminAuditLogTitle') ?? 'Audit Log';
    final String filtersApplied =
        l10n?.translate('adminAuditLogFiltersApplied') ??
            'Filters applied to audit log.';
    final String exportStarted =
        l10n?.translate('adminAuditLogExportStarted') ??
            'Export started in the background.';
    final String loadError = l10n?.translate('adminAuditLogLoadError') ??
        'Failed to load audit log.';
    final String emptyMessage =
        l10n?.translate('adminAuditLogEmpty') ?? 'No audit activity recorded.';
    final String filterDateLabel =
        l10n?.translate('adminAuditLogFilterDateRangeLabel') ?? 'Date range';
    final String filterDateHint =
        l10n?.translate('adminAuditLogFilterDateRangeHint') ?? 'Last 7 days';
    final String filterUserLabel =
        l10n?.translate('adminAuditLogFilterUserLabel') ?? 'User';
    final String filterUserHint =
        l10n?.translate('adminAuditLogFilterUserHint') ?? 'Search by user';
    final String filterModuleLabel =
        l10n?.translate('adminAuditLogFilterModuleLabel') ?? 'Module';
    final String filterModuleHint =
        l10n?.translate('adminAuditLogFilterModuleHint') ?? 'Any module';
    final String filterActionLabel =
        l10n?.translate('adminAuditLogFilterActionLabel') ?? 'Action';
    final String filterActionHint =
        l10n?.translate('adminAuditLogFilterActionHint') ?? 'Action type';
    final String exportLabel =
        l10n?.translate('adminAuditLogExport') ?? 'Export';
    final String applyFiltersLabel =
        l10n?.translate('adminAuditLogApplyFilters') ?? 'Apply filters';
    final AsyncValue<List<AuditLogEntry>> entriesAsync =
        ref.watch(auditLogEntriesProvider);
    final EdgeInsets padding =
        context.pagePadding().resolve(Directionality.of(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AColors.background,
      body: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FiltersCard(
              dateRangeController: _dateRangeController,
              userController: _userController,
              moduleController: _moduleController,
              actionController: _actionController,
              onApplyFilters: () => _applyFilters(filtersApplied),
              onExport: () => _export(exportStarted),
              dateRangeLabel: filterDateLabel,
              dateRangeHint: filterDateHint,
              userLabel: filterUserLabel,
              userHint: filterUserHint,
              moduleLabel: filterModuleLabel,
              moduleHint: filterModuleHint,
              actionLabel: filterActionLabel,
              actionHint: filterActionHint,
              exportLabel: exportLabel,
              applyFiltersLabel: applyFiltersLabel,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: entriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace stackTrace) => Center(
                  child: Text(
                    '$loadError\n${error.userFriendlyMessage}',
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (List<AuditLogEntry> entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        emptyMessage,
                        style: ATypography.bodyLg.copyWith(
                          color: AColors.mutedForeground,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (BuildContext context, int index) {
                      return _AuditLogTile(entry: entries[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.dateRangeController,
    required this.userController,
    required this.moduleController,
    required this.actionController,
    required this.onApplyFilters,
    required this.onExport,
    required this.dateRangeLabel,
    required this.dateRangeHint,
    required this.userLabel,
    required this.userHint,
    required this.moduleLabel,
    required this.moduleHint,
    required this.actionLabel,
    required this.actionHint,
    required this.exportLabel,
    required this.applyFiltersLabel,
  });

  final TextEditingController dateRangeController;
  final TextEditingController userController;
  final TextEditingController moduleController;
  final TextEditingController actionController;
  final VoidCallback onApplyFilters;
  final VoidCallback onExport;
  final String dateRangeLabel;
  final String dateRangeHint;
  final String userLabel;
  final String userHint;
  final String moduleLabel;
  final String moduleHint;
  final String actionLabel;
  final String actionHint;
  final String exportLabel;
  final String applyFiltersLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F1A2E),
            blurRadius: 24,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _FilterField(
                  controller: dateRangeController,
                  label: dateRangeLabel,
                  hint: dateRangeHint,
                  icon: Icons.calendar_today,
                ),
                _FilterField(
                  controller: userController,
                  label: userLabel,
                  hint: userHint,
                  icon: Icons.person_outline,
                ),
                _FilterField(
                  controller: moduleController,
                  label: moduleLabel,
                  hint: moduleHint,
                  icon: Icons.view_module_outlined,
                ),
                _FilterField(
                  controller: actionController,
                  label: actionLabel,
                  hint: actionHint,
                  icon: Icons.timeline_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                OutlinedButton(
                  onPressed: onExport,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: Text(exportLabel),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onApplyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: Text(applyFiltersLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  const _AuditLogTile({required this.entry});

  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final Locale locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('he');
    final intl.DateFormat timeFormat =
        intl.DateFormat.jm(locale.toLanguageTag());
    final String timeLabel = timeFormat.format(entry.timestamp);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 20,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        timeLabel,
                        style: ATypography.bodySm.copyWith(
                          color: AColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.userName,
                        style: ATypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        entry.userEmail,
                        style: ATypography.bodySm,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: entry.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              entry.action,
              style: ATypography.bodyLg,
            ),
            const SizedBox(height: 8),
            Text(
              '${entry.module} • ${entry.context}',
              style: ATypography.bodySm.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AuditLogStatus status;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String successLabel =
        l10n?.translate('adminAuditLogStatusSuccess') ?? 'Success';
    final String warningLabel =
        l10n?.translate('adminAuditLogStatusWarning') ?? 'Warning';
    final String errorLabel =
        l10n?.translate('adminAuditLogStatusError') ?? 'Error';
    final (Color color, String label) = switch (status) {
      AuditLogStatus.success => (AColors.success, successLabel),
      AuditLogStatus.warning => (AColors.warning, warningLabel),
      AuditLogStatus.error => (AColors.danger, errorLabel),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: ATypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
