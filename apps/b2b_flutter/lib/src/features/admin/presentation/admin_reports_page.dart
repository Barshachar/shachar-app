import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/supabase/supabase_client_provider.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_ui_actions.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_action_keys.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_actions_widgets.dart';

String describeAdminReportRange(
  DateTimeRange? range,
  Locale? locale,
  MarketplaceLocalizations? l10n,
) {
  if (range == null) {
    return l10n?.translate('adminReportsRangeAll') ?? 'All dates';
  }
  final String formatLocale = locale?.toLanguageTag() ?? 'en';
  final DateFormat formatter = DateFormat.yMd(formatLocale);
  final String start = formatter.format(range.start);
  final String end = formatter.format(range.end);
  return '$start – $end';
}

class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});

  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage> {
  String? _latestReportUrl;
  DateTimeRange? _range;
  bool _loading = false;
  final List<AdminGeneratedReport> _reports = [];

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final EdgeInsetsGeometry padding =
        context.pagePadding().resolve(Directionality.of(context));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.translate('adminReportsTitle') ?? 'Admin • Reports'),
      ),
      body: ListView(
        padding: padding,
        children: [
          _ReportsControlCard(
            range: _range,
            loading: _loading,
            onPickRange: _pickRange,
            onClearRange: _range != null ? _clearRange : null,
            l10n: l10n,
            generateButton: AdminReportActionButton(
              callReport: () => _callReport('csv', l10n),
              onMessage: (String message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              onSuccess: (ReportRecord record) =>
                  _handleReportSuccess(record, 'csv', l10n),
            ),
          ),
          const SizedBox(height: ASpacing.xl),
          if (_latestReportUrl != null) ...[
            SelectableText(
              _latestReportUrl!,
              key: adminReportUrlKey,
              style: ATypography.bodySm.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: ASpacing.sm),
            Row(
              children: [
                TextButton(
                  key: adminReportCopyButtonKey,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _latestReportUrl!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.translate('adminReportsCopySuccess') ??
                              'Link copied to clipboard',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    l10n?.translate('adminReportsCopyLink') ?? 'Copy link',
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.xl),
          ],
          _buildRecentExportsSection(l10n),
        ],
      ),
    );
  }

  Widget _buildRecentExportsSection(MarketplaceLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.translate('adminReportsRecentTitle') ?? 'Recent exports',
              style: ATypography.titleSm,
            ),
            if (_loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: ASpacing.md),
        if (_reports.isEmpty)
          AStateMessage(
            icon: Icons.insert_drive_file_outlined,
            title:
                l10n?.translate('adminReportsEmptyTitle') ?? 'No reports yet',
            message: l10n?.translate('adminReportsEmptyBody') ??
                'Generate a report to receive a signed download link.',
            primaryLabel:
                l10n?.translate('adminReportsGenerateCsv') ?? 'Generate CSV',
            onPrimaryPressed:
                _loading ? null : () => _triggerReport('csv', l10n),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: ASpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final AdminGeneratedReport report = _reports[index];
              return _ReportTile(
                report: report,
                onOpen: () => _openSignedUrl(report.url),
                onCopy: () => _copyLink(report.url, l10n),
                l10n: l10n,
              );
            },
          ),
      ],
    );
  }

  Future<void> _pickRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange initial = _range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 30)),
          end: now,
        );
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
    );
    if (range != null) {
      setState(() => _range = range);
    }
  }

  void _clearRange() {
    setState(() => _range = null);
  }

  Future<void> _handleReportSuccess(
    ReportRecord record,
    String format,
    MarketplaceLocalizations? l10n,
  ) async {
    final AdminGeneratedReport report = AdminGeneratedReport(
      format: format,
      url: record.url,
      generatedAt: DateTime.now(),
      rangeLabel: describeAdminReportRange(
        _range,
        Localizations.maybeLocaleOf(context),
        l10n,
      ),
    );
    if (!mounted) return;
    setState(() {
      _latestReportUrl = record.url;
      _reports.insert(0, report);
    });
    await _showSignedUrlDialog(report, l10n);
  }

  Future<void> _triggerReport(
      String format, MarketplaceLocalizations? l10n) async {
    try {
      final ReportRecord record = await _callReport(format, l10n);
      await _handleReportSuccess(record, format, l10n);
      if (mounted) {
        final String successMessage =
            l10n?.translate('adminReportsSuccess') ?? 'Report ready.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<ReportRecord> _callReport(
      String format, MarketplaceLocalizations? l10n) async {
    setState(() => _loading = true);
    try {
      final SupabaseClient client = ref.read(supabaseClientProvider);
      final FunctionResponse response = await client.functions.invoke(
        'report_generator',
        body: {
          'from_date': _range?.start.toIso8601String(),
          'to_date': _range?.end.toIso8601String(),
          'format': format,
        },
      );
      final Object? responseData = response.data;
      final Map<String, dynamic>? payload =
          responseData is Map ? Map<String, dynamic>.from(responseData) : null;
      final String? signedUrl = payload?['signed_url'] as String?;
      if (signedUrl == null || signedUrl.isEmpty) {
        throw Exception(
          (l10n?.translate('adminReportsFailure') ?? 'Report failed: {error}')
              .replaceAll('{error}', 'missing URL'),
        );
      }
      return (url: signedUrl, filename: 'report.$format');
    } on FunctionException catch (error) {
      final String details = error.details ?? 'status ${error.status}';
      throw Exception(
        (l10n?.translate('adminReportsFailure') ?? 'Report failed: {error}')
            .replaceAll('{error}', details),
      );
    } catch (error) {
      throw Exception(
        (l10n?.translate('adminReportsFailure') ?? 'Report failed: {error}')
            .replaceAll('{error}', error.toString()),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _showSignedUrlDialog(
    AdminGeneratedReport report,
    MarketplaceLocalizations? l10n,
  ) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            l10n?.translate('adminReportsSignedUrlTitle') ?? 'Report ready',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.translate('adminReportsSignedUrlBody') ??
                    'Copy the signed URL or open it in a new tab.',
                style: ATypography.bodySm,
              ),
              const SizedBox(height: ASpacing.md),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(ASpacing.md),
                decoration: BoxDecoration(
                  color: AColors.surfaceMuted,
                  borderRadius: ARadii.md,
                ),
                child: SelectableText(
                  report.url,
                  style: ATypography.bodySm.copyWith(
                    color: AColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                l10n?.translate('adminReportsSignedUrlClose') ?? 'Close',
              ),
            ),
            TextButton(
              onPressed: () {
                _copyLink(report.url, l10n);
              },
              child: Text(
                l10n?.translate('adminReportsCopyLink') ?? 'Copy link',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _openSignedUrl(report.url);
              },
              child: Text(
                l10n?.translate('adminReportsOpenLink') ?? 'Open link',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSignedUrl(String url) async {
    try {
      final bool didLaunch = await launchUrlString(url);
      if (!didLaunch && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.of<MarketplaceLocalizations>(
                    context,
                    MarketplaceLocalizations,
                  )?.translate('adminReportsOpenFailed') ??
                  'Could not open report link.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open report: $error')),
        );
      }
    }
  }

  Future<void> _copyLink(String url, MarketplaceLocalizations? l10n) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    final String message = l10n?.translate('adminReportsCopySuccess') ??
        'Link copied to clipboard';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ReportsControlCard extends StatelessWidget {
  const _ReportsControlCard({
    required this.range,
    required this.loading,
    required this.onPickRange,
    required this.onClearRange,
    required this.l10n,
    required this.generateButton,
  });

  final DateTimeRange? range;
  final bool loading;
  final VoidCallback onPickRange;
  final VoidCallback? onClearRange;
  final MarketplaceLocalizations? l10n;
  final Widget generateButton;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat formatter = DateFormat.yMd(locale.toLanguageTag());
    final String rangeDescription;
    if (range == null) {
      rangeDescription = l10n?.translate('adminReportsRangeAll') ?? 'All dates';
    } else {
      final String start = formatter.format(range!.start);
      final String end = formatter.format(range!.end);
      rangeDescription = '$start – $end';
    }

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.translate('adminReportsDescriptionTitle') ??
                'Generate export files',
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            l10n?.translate('adminReportsDescriptionBody') ??
                'Choose a date range and export format to receive a signed URL. '
                    'Links remain active for a limited time.',
            style: ATypography.bodySm,
          ),
          const SizedBox(height: ASpacing.lg),
          Wrap(
            spacing: ASpacing.md,
            runSpacing: ASpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: loading ? null : onPickRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  l10n?.translate('adminReportsPickRange') ?? 'Select range',
                ),
              ),
              Text(
                rangeDescription,
                style: ATypography.bodySm.copyWith(
                  color: AColors.mutedForeground,
                ),
              ),
              if (onClearRange != null)
                TextButton(
                  onPressed: loading ? null : onClearRange,
                  child: Text(
                    l10n?.translate('adminReportsClearRange') ?? 'Clear',
                  ),
                ),
              const SizedBox(width: ASpacing.md),
              AbsorbPointer(
                absorbing: loading,
                child: generateButton,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.report,
    required this.onOpen,
    required this.onCopy,
    required this.l10n,
  });

  final AdminGeneratedReport report;
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat timeFormat =
        DateFormat.yMMMd(locale.toLanguageTag()).add_Hm();
    final String generatedLabel = timeFormat.format(report.generatedAt);
    final String formatLabel = report.format.toUpperCase();

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insert_drive_file,
                color: AColors.primary,
              ),
              const SizedBox(width: ASpacing.sm),
              Expanded(
                child: Text(
                  '$formatLabel • ${report.rangeLabel}',
                  style: ATypography.bodyMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            l10n?.translate('adminReportsGeneratedAt') ?? 'Generated at:',
            style: ATypography.bodySm,
          ),
          Text(
            generatedLabel,
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
          ),
          const SizedBox(height: ASpacing.lg),
          Wrap(
            spacing: ASpacing.sm,
            runSpacing: ASpacing.sm,
            children: [
              AButton.secondary(
                label: l10n?.translate('adminReportsCopyLink') ?? 'Copy link',
                icon: const Icon(
                  Icons.copy,
                  size: 18,
                  color: AColors.primary,
                ),
                onPressed: onCopy,
              ),
              AButton.primary(
                label: l10n?.translate('adminReportsOpenLink') ?? 'Open link',
                icon: const Icon(Icons.open_in_new,
                    color: Colors.white, size: 18),
                onPressed: onOpen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminGeneratedReport {
  const AdminGeneratedReport({
    required this.format,
    required this.url,
    required this.generatedAt,
    required this.rangeLabel,
  });

  final String format;
  final String url;
  final DateTime generatedAt;
  final String rangeLabel;
}
