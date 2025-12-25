import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/supabase/supabase_client_provider.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_ui_actions.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_action_keys.dart';

class AdminPriceImportResult {
  const AdminPriceImportResult({required this.message, required this.success});

  final String message;
  final bool success;
}

@visibleForTesting
Future<AdminPriceImportResult> performAdminPriceImport({
  BuildContext? context,
  SupabaseClient? client,
  required String vendorId,
  required String csvContent,
  MarketplaceLocalizations? localizations,
  void Function(String message)? showMessage,
  Future<FunctionResponse> Function()? runInvoke,
}) async {
  final MarketplaceLocalizations? l10n = localizations ??
      (context != null
          ? Localizations.of<MarketplaceLocalizations>(
              context,
              MarketplaceLocalizations,
            )
          : null);
  final ScaffoldMessengerState? messenger =
      showMessage == null && context != null
          ? ScaffoldMessenger.maybeOf(context)
          : null;
  void display(String message) {
    if (showMessage != null) {
      showMessage(message);
    } else if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  final Future<FunctionResponse> Function() invoke = runInvoke ??
      (() async {
        if (client == null) {
          throw StateError('Supabase client required when runInvoke is null');
        }
        return client.functions.invoke(
          'price_lists_import',
          body: <String, dynamic>{
            'vendor_id': vendorId,
            'csv': csvContent,
          },
        );
      });
  try {
    final FunctionResponse response = await invoke();
    final Object? responseData = response.data;
    final Map<String, dynamic>? data =
        responseData is Map ? Map<String, dynamic>.from(responseData) : null;
    final int inserted = data?['inserted'] is num
        ? (data?['inserted'] as num).toInt()
        : responseData is num
            ? responseData.toInt()
            : 0;

    final String template =
        l10n?.translate('adminPriceImportSuccess') ?? 'Rows processed: {count}';
    final String message = template.replaceAll('{count}', inserted.toString());
    display(message);
    return AdminPriceImportResult(message: message, success: true);
  } on FunctionException catch (error) {
    final String details = error.details ?? 'status ${error.status}';
    final String template =
        l10n?.translate('adminPriceImportFailure') ?? 'Import failed: {error}';
    final String message = template.replaceAll('{error}', details);
    display(message);
    return AdminPriceImportResult(message: message, success: false);
  } catch (error) {
    final String template =
        l10n?.translate('adminPriceImportFailure') ?? 'Import failed: {error}';
    final String message = template.replaceAll('{error}', error.toString());
    display(message);
    return AdminPriceImportResult(message: message, success: false);
  }
}

class AdminPriceListsPage extends ConsumerStatefulWidget {
  const AdminPriceListsPage({super.key});

  @override
  ConsumerState<AdminPriceListsPage> createState() =>
      _AdminPriceListsPageState();
}

class _AdminPriceListsPageState extends ConsumerState<AdminPriceListsPage> {
  bool _loadingVendors = true;
  bool _isProcessing = false;
  List<Map<String, String>> _vendors = const <Map<String, String>>[];
  String? _selectedVendorId;
  PlatformFile? _selectedFile;
  List<List<String>> _previewRows = const <List<String>>[];
  String? _importFeedback;
  bool _feedbackSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() => _loadingVendors = true);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    await Future<void>.delayed(Duration.zero);
    try {
      final SupabaseClient client = ref.read(supabaseClientProvider);
      final dynamic response = await client
          .from('companies')
          .select('id, name')
          .eq('type', 'vendor')
          .order('name');

      final List<dynamic> rows =
          response is List<dynamic> ? response : const <dynamic>[];
      final List<Map<String, String>> vendors = rows.map((dynamic row) {
        return {
          'id': row['id']?.toString() ?? '',
          'name': row['name']?.toString() ?? '',
        };
      }).toList(growable: false);

      if (!mounted) return;
      setState(() {
        _vendors = vendors;
        _selectedVendorId = _selectedVendorId ??
            (vendors.isNotEmpty ? vendors.first['id'] : null);
        _loadingVendors = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingVendors = false);
      final String message = l10n?.translate('adminPriceImportVendorsFailed') ??
          'Failed to load vendors';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$message: $error')),
      );
    }
  }

  Future<void> _pickCsv() async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );

    if (result == null || result.files.single.bytes == null) {
      return;
    }

    final PlatformFile file = result.files.single;
    final String csvContent = utf8.decode(file.bytes!);
    final List<List<String>> preview = _previewCsv(csvContent);

    setState(() {
      _selectedFile = file;
      _previewRows = preview;
      _importFeedback = null;
    });

    if (preview.isEmpty && mounted) {
      final String message = l10n?.translate('adminPriceImportPreviewEmpty') ??
          'CSV appears empty.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _importCsv() async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    // Capture UI handles before awaiting async work to avoid stale context warnings.
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (_selectedVendorId == null) {
      final String message =
          l10n?.translate('adminPriceImportSelectVendorFirst') ??
              'Select a vendor before importing.';
      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    if (_selectedFile?.bytes == null) {
      final String message =
          l10n?.translate('adminPriceImportSelectFileFirst') ??
              'Choose a CSV file to import.';
      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    final String csvContent = utf8.decode(_selectedFile!.bytes!);
    setState(() {
      _isProcessing = true;
      _importFeedback = null;
    });

    try {
      final String message = await importPricesUI(
        callImport: () async {
          final SupabaseClient client = ref.read(supabaseClientProvider);
          final FunctionResponse response = await client.functions.invoke(
            'price_lists_import',
            body: {
              'vendor_id': _selectedVendorId,
              'csv': csvContent,
            },
          );
          final Object? responseData = response.data;
          final Map<String, dynamic>? data = responseData is Map
              ? Map<String, dynamic>.from(responseData)
              : null;
          final int inserted = data?['inserted'] is num
              ? (data?['inserted'] as num).toInt()
              : responseData is num
                  ? responseData.toInt()
                  : 0;
          return inserted;
        },
        showMessage: (String msg) {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(content: Text(msg)),
          );
        },
      );
      if (!mounted) return;
      setState(() {
        _importFeedback = message;
        _feedbackSuccess = message.startsWith('Rows processed:');
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _refreshPrices() async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(supabaseClientProvider)
          .rpc<void>('refresh_mv_effective_prices');
      if (!mounted) return;
      final String message =
          l10n?.translate('adminPriceImportRefreshSuccess') ??
              'Effective prices refreshed.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) return;
      final String template =
          l10n?.translate('adminPriceImportRefreshFailure') ??
              'Refresh failed: {error}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(template.replaceAll('{error}', '$error'))),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final EdgeInsetsGeometry padding =
        context.pagePadding().resolve(Directionality.of(context));
    final bool canImport = !_isProcessing &&
        _selectedVendorId != null &&
        _selectedFile?.bytes != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('adminPriceImportTitle') ?? 'Admin • Price import',
        ),
        actions: [
          IconButton(
            tooltip: l10n?.translate('adminPriceImportReloadVendors') ??
                'Reload vendors',
            icon: const Icon(Icons.refresh),
            onPressed: _loadingVendors ? null : _loadVendors,
          ),
        ],
      ),
      body: ListView(
        padding: padding,
        children: [
          _UploadControlsCard(
            vendors: _vendors,
            selectedVendorId: _selectedVendorId,
            loadingVendors: _loadingVendors,
            isProcessing: _isProcessing,
            selectedFile: _selectedFile,
            onVendorChanged: (String? value) {
              setState(() => _selectedVendorId = value);
            },
            onPickCsv: _pickCsv,
            onImport: canImport ? _importCsv : null,
            onRefreshEffective: _isProcessing ? null : _refreshPrices,
            l10n: l10n,
          ),
          const SizedBox(height: ASpacing.xl),
          _PreviewTable(
            rows: _previewRows,
            l10n: l10n,
          ),
          if (_importFeedback != null) ...[
            const SizedBox(height: ASpacing.xl),
            Text(
              _importFeedback!,
              key: adminImportResultKey,
              style: ATypography.bodySm,
            ),
            const SizedBox(height: ASpacing.md),
            _FeedbackBanner(
              message: _importFeedback!,
              success: _feedbackSuccess,
            ),
          ],
        ],
      ),
    );
  }

  List<List<String>> _previewCsv(String csvContent) {
    final List<String> lines = const LineSplitter().convert(csvContent)
      ..removeWhere((String line) => line.trim().isEmpty);
    if (lines.isEmpty) {
      return const <List<String>>[];
    }
    final Iterable<String> limited = lines.take(6);
    final List<List<String>> rows =
        limited.map<List<String>>(_tokenizeCsvLine).toList(growable: false);

    final int maxColumns =
        rows.fold<int>(0, (int previousValue, List<String> row) {
      return math.max(previousValue, row.length);
    });

    return rows.map((List<String> row) {
      if (row.length == maxColumns) return row;
      return List<String>.from(row)
        ..addAll(List<String>.filled(maxColumns - row.length, ''));
    }).toList(growable: false);
  }

  List<String> _tokenizeCsvLine(String line) {
    final List<String> cells = <String>[];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final String char = line[i];
      if (char == '"') {
        final bool nextIsQuote = i + 1 < line.length && line[i + 1] == '"';
        if (inQuotes && nextIsQuote) {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        cells.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    cells.add(current.toString().trim());
    return cells;
  }
}

class _UploadControlsCard extends StatelessWidget {
  const _UploadControlsCard({
    required this.vendors,
    required this.selectedVendorId,
    required this.loadingVendors,
    required this.isProcessing,
    required this.selectedFile,
    required this.onVendorChanged,
    required this.onPickCsv,
    required this.onImport,
    required this.onRefreshEffective,
    required this.l10n,
  });

  final List<Map<String, String>> vendors;
  final String? selectedVendorId;
  final bool loadingVendors;
  final bool isProcessing;
  final PlatformFile? selectedFile;
  final ValueChanged<String?> onVendorChanged;
  final VoidCallback onPickCsv;
  final VoidCallback? onImport;
  final VoidCallback? onRefreshEffective;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String vendorLabel =
        l10n?.translate('adminPriceImportSelectVendor') ?? 'Select vendor';
    final String instructions =
        l10n?.translate('adminPriceImportInstructions') ??
            'Upload a CSV with columns variant_id, min_qty, unit_price.';

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.translate('adminPriceImportHeader') ?? 'Import vendor prices',
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            instructions,
            style: ATypography.bodySm,
          ),
          const SizedBox(height: ASpacing.lg),
          DropdownButtonFormField<String>(
            value: selectedVendorId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: vendorLabel,
              border: OutlineInputBorder(borderRadius: ARadii.md),
            ),
            items: vendors
                .map(
                  (Map<String, String> vendor) => DropdownMenuItem<String>(
                    value: vendor['id'],
                    child: Text(vendor['name'] ?? 'Vendor'),
                  ),
                )
                .toList(),
            onChanged: loadingVendors ? null : onVendorChanged,
          ),
          if (loadingVendors) ...[
            const SizedBox(height: ASpacing.sm),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: ASpacing.lg),
          Wrap(
            spacing: ASpacing.sm,
            runSpacing: ASpacing.sm,
            children: [
              AButton.secondary(
                key: adminImportPickButtonKey,
                label: l10n?.translate('adminPriceImportChooseFile') ??
                    'Choose CSV',
                icon: const Icon(
                  Icons.upload_file,
                  size: 18,
                  color: AColors.primary,
                ),
                onPressed: isProcessing ? null : onPickCsv,
              ),
              AButton.primary(
                key: adminImportUploadButtonKey,
                label: l10n?.translate('adminPriceImportImportButton') ??
                    'Import prices',
                icon: const Icon(
                  Icons.playlist_add_check,
                  size: 18,
                  color: Colors.white,
                ),
                onPressed: onImport,
              ),
              AButton.text(
                label: l10n?.translate('adminPriceImportRefreshButton') ??
                    'Refresh effective prices',
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: AColors.primary,
                ),
                onPressed: onRefreshEffective,
              ),
            ],
          ),
          if (isProcessing) ...[
            const SizedBox(height: ASpacing.md),
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: ASpacing.sm),
                Text(
                  l10n?.translate('adminPriceImportProcessing') ??
                      'Processing…',
                  style: ATypography.bodySm,
                ),
              ],
            ),
          ],
          if (selectedFile != null) ...[
            const SizedBox(height: ASpacing.lg),
            Text(
              l10n?.translate('adminPriceImportSelectedFile') ??
                  'Selected file',
              style: ATypography.bodySm,
            ),
            const SizedBox(height: ASpacing.xs),
            Text(
              '${selectedFile!.name} • ${_formatFileSize(selectedFile!.size)}',
              style: ATypography.bodySm.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    final int exponentRaw =
        (bytes == 0) ? 0 : (math.log(bytes) / math.log(1024)).floor();
    final int exponent = exponentRaw.clamp(0, units.length - 1);
    final double divisor = math.pow(1024, exponent).toDouble();
    final double size = bytes / divisor;
    return '${size.toStringAsFixed(1)} ${units[exponent]}';
  }
}

class _PreviewTable extends StatelessWidget {
  const _PreviewTable({required this.rows, required this.l10n});

  final List<List<String>> rows;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.translate('adminPriceImportPreviewTitle') ??
                'Preview (first rows)',
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.md),
          if (rows.isEmpty)
            Text(
              l10n?.translate('adminPriceImportPreviewHint') ??
                  'Choose a CSV to preview the first rows before importing.',
              style: ATypography.bodySm,
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: rows.first.asMap().entries.map((entry) {
                  final String columnLabel = entry.value.isEmpty
                      ? '${l10n?.translate('adminPriceImportColumn') ?? 'Column'} ${entry.key + 1}'
                      : entry.value;
                  return DataColumn(label: Text(columnLabel));
                }).toList(),
                rows: rows
                    .skip(1)
                    .map(
                      (List<String> row) => DataRow(
                        cells: row
                            .map((String cell) => DataCell(
                                  Text(cell.isEmpty ? '—' : cell),
                                ))
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final Color background = success
        ? AColors.success.withValues(alpha: 0.12)
        : AColors.danger.withValues(alpha: 0.12);
    final Color foreground = success ? AColors.success : AColors.danger;
    final IconData icon = success ? Icons.check_circle : Icons.error_outline;

    return Container(
      padding: const EdgeInsets.all(ASpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: ARadii.lg,
        border: Border.all(color: foreground.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: ASpacing.sm),
          Expanded(
            child: Text(
              message,
              style: ATypography.bodySm.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
