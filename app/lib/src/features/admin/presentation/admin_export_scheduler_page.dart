import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

class AdminExportSchedulerPage extends StatefulWidget {
  const AdminExportSchedulerPage({super.key});

  @override
  State<AdminExportSchedulerPage> createState() =>
      _AdminExportSchedulerPageState();
}

class _AdminExportSchedulerPageState extends State<AdminExportSchedulerPage> {
  int datasetIndex = 0;
  int formatIndex = 0;
  int destinationIndex = 2;
  int frequencyIndex = 0;
  bool includeFilters = true;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    final String title = l10n?.translate('adminExportsTitle') ?? 'Data export';
    final String datasetLabel =
        l10n?.translate('adminExportsDataset') ?? 'Dataset';
    final String dateRange =
        l10n?.translate('adminExportsDateRange') ?? 'Jan 1 – Mar 5, 2024';
    final String selectFields =
        l10n?.translate('adminExportsSelectFields') ?? 'Select fields...';
    final String formatLabel =
        l10n?.translate('adminExportsFormat') ?? 'Format';
    final String destinationLabel =
        l10n?.translate('adminExportsDestination') ?? 'Destination';
    final String frequencyLabel =
        l10n?.translate('adminExportsFrequencyLabel') ?? 'Frequency';
    final String includeFiltersLabel =
        l10n?.translate('adminExportsIncludeFilters') ?? 'Include filters';
    final String lastExportsLabel =
        l10n?.translate('adminExportsLastExports') ?? 'Last exports';
    final String completedLabel =
        l10n?.translate('adminExportsCompleted') ?? 'Completed';
    final String pendingLabel =
        l10n?.translate('adminExportsPending') ?? 'Pending';
    final String downloadLabel =
        l10n?.translate('adminExportsDownload') ?? 'Download';

    final List<String> datasetOptions = [
      'Orders',
      'Products',
      'Customers',
      'Invoices'
    ];
    final List<String> formatOptions = ['CSV', 'Excel', 'JSON', 'Email'];
    final List<String> destinations = ['S3', 'Webhook', 'Email'];
    final List<String> frequencies = [
      l10n?.translate('adminExportsOnce') ?? 'Once',
      l10n?.translate('adminExportsDaily') ?? 'Daily',
      l10n?.translate('adminExportsWeekly') ?? 'Weekly',
    ];

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
                  Text(datasetLabel, style: ATypography.bodySm),
                  const SizedBox(height: ASpacing.xs),
                  ToggleButtons(
                    isSelected: List<bool>.generate(
                      datasetOptions.length,
                      (index) => index == datasetIndex,
                    ),
                    onPressed: (index) {
                      setState(() => datasetIndex = index);
                    },
                    borderRadius: ARadii.pill,
                    selectedColor: Colors.white,
                    fillColor: AColors.primary,
                    children: datasetOptions
                        .map(
                          (option) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ASpacing.md,
                              vertical: ASpacing.sm,
                            ),
                            child: Text(option),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: ASpacing.lg),
                  _ExportField(
                      label: l10n?.translate('adminExportsDateRange') ??
                          'Date range',
                      value: dateRange),
                  const SizedBox(height: ASpacing.md),
                  _ExportField(
                      label: l10n?.translate('adminExportsSelectFields') ??
                          'Select fields...',
                      value: selectFields),
                  const SizedBox(height: ASpacing.lg),
                  Text(formatLabel, style: ATypography.bodySm),
                  const SizedBox(height: ASpacing.xs),
                  ToggleButtons(
                    isSelected: List<bool>.generate(
                      formatOptions.length,
                      (index) => index == formatIndex,
                    ),
                    onPressed: (index) {
                      setState(() => formatIndex = index);
                    },
                    borderRadius: ARadii.pill,
                    selectedColor: AColors.primary,
                    color: AColors.foreground,
                    fillColor: AColors.primaryMuted,
                    children: formatOptions
                        .map(
                          (option) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ASpacing.md,
                              vertical: ASpacing.sm,
                            ),
                            child: Text(option),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: ASpacing.lg),
                  Text(destinationLabel, style: ATypography.bodySm),
                  const SizedBox(height: ASpacing.xs),
                  ToggleButtons(
                    isSelected: List<bool>.generate(
                      destinations.length,
                      (index) => index == destinationIndex,
                    ),
                    onPressed: (index) {
                      setState(() => destinationIndex = index);
                    },
                    borderRadius: ARadii.pill,
                    selectedColor: Colors.white,
                    fillColor: AColors.primary,
                    children: destinations
                        .map(
                          (option) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ASpacing.md,
                              vertical: ASpacing.sm,
                            ),
                            child: Text(option),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: ASpacing.lg),
                  Text(frequencyLabel, style: ATypography.bodySm),
                  const SizedBox(height: ASpacing.xs),
                  ToggleButtons(
                    isSelected: List<bool>.generate(
                      frequencies.length,
                      (index) => index == frequencyIndex,
                    ),
                    onPressed: (index) {
                      setState(() => frequencyIndex = index);
                    },
                    borderRadius: ARadii.pill,
                    selectedColor: Colors.white,
                    fillColor: AColors.primary,
                    children: frequencies
                        .map(
                          (option) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ASpacing.md,
                              vertical: ASpacing.sm,
                            ),
                            child: Text(option),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: ASpacing.lg),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(includeFiltersLabel, style: ATypography.bodySm),
                    value: includeFilters,
                    onChanged: (value) =>
                        setState(() => includeFilters = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ASpacing.lg),
            Text(lastExportsLabel, style: ATypography.bodySm),
            const SizedBox(height: ASpacing.sm),
            Card(
              shape: RoundedRectangleBorder(borderRadius: ARadii.md),
              child: Column(
                children: [
                  _ExportRow(
                    status: completedLabel,
                    timestamp: 'Mar 4, 2024 at 9:00 AM',
                    actionLabel: downloadLabel,
                  ),
                  const Divider(height: 1),
                  _ExportRow(
                    status: pendingLabel,
                    timestamp: 'Mar 1, 2024 at 9:00 AM',
                    actionLabel:
                        l10n?.translate('adminExportsPending') ?? 'Pending',
                    showButton: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportField extends StatelessWidget {
  const _ExportField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
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
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    );
  }
}

class _ExportRow extends StatelessWidget {
  const _ExportRow({
    required this.status,
    required this.timestamp,
    required this.actionLabel,
    this.showButton = true,
  });

  final String status;
  final String timestamp;
  final String actionLabel;
  final bool showButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.lg,
        vertical: ASpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: ATypography.bodyLg),
                const SizedBox(height: ASpacing.xs),
                Text(timestamp, style: ATypography.bodySm),
              ],
            ),
          ),
          if (showButton)
            TextButton(
              onPressed: () {},
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}
