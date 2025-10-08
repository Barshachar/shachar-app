import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_keys.dart';

const List<String> _shipmentStatusOptions = <String>[
  'pending',
  'ready',
  'in_transit',
  'delivered',
  'cancelled',
];

final vendorShipmentsFiltersProvider =
    StateNotifierProvider<ShipmentsFiltersNotifier, ShipmentsFilters>(
  (ref) => ShipmentsFiltersNotifier(),
);

final vendorShipmentsControllerProvider =
    AsyncNotifierProvider<VendorShipmentsController, List<VendorShipment>>(
        VendorShipmentsController.new);

class ShipmentsFilters {
  const ShipmentsFilters({
    this.statuses = const <String>{},
    this.dateRange,
    this.query = '',
  });

  final Set<String> statuses;
  final DateTimeRange? dateRange;
  final String query;

  ShipmentsFilters copyWith({
    Set<String>? statuses,
    DateTimeRange? Function()? dateRange,
    String? query,
  }) {
    return ShipmentsFilters(
      statuses: statuses ?? this.statuses,
      dateRange: dateRange != null ? dateRange() : this.dateRange,
      query: query ?? this.query,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ShipmentsFilters &&
        other.query == query &&
        other.dateRange == dateRange &&
        setEquals(other.statuses, statuses);
  }

  @override
  int get hashCode => Object.hash(
        query,
        dateRange,
        Object.hashAllUnordered(statuses),
      );
}

class ShipmentsFiltersNotifier extends StateNotifier<ShipmentsFilters> {
  ShipmentsFiltersNotifier() : super(const ShipmentsFilters());

  void toggleStatus(String status) {
    final Set<String> next = Set<String>.from(state.statuses);
    if (next.contains(status)) {
      next.remove(status);
    } else {
      next.add(status);
    }
    state = state.copyWith(statuses: next);
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: () => range);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void reset() {
    state = const ShipmentsFilters();
  }
}

class VendorShipment {
  const VendorShipment({
    required this.id,
    required this.orderId,
    required this.vendorCompanyId,
    required this.status,
    required this.createdAt,
    this.tracking,
    this.vendorName,
  });

  final String id;
  final String orderId;
  final String vendorCompanyId;
  final String status;
  final DateTime createdAt;
  final String? tracking;
  final String? vendorName;

  String get displayVendor =>
      vendorName?.trim().isNotEmpty == true ? vendorName! : vendorCompanyId;

  VendorShipment copyWith({
    String? status,
    String? tracking,
  }) {
    return VendorShipment(
      id: id,
      orderId: orderId,
      vendorCompanyId: vendorCompanyId,
      status: status ?? this.status,
      createdAt: createdAt,
      tracking: tracking ?? this.tracking,
      vendorName: vendorName,
    );
  }

  static VendorShipment fromJson(Map<String, dynamic> json) {
    final String? vendorName;
    if (json['companies'] is Map<String, dynamic>) {
      vendorName =
          (json['companies'] as Map<String, dynamic>)['name']?.toString();
    } else {
      vendorName = null;
    }
    final createdAtString = json['created_at']?.toString();
    final DateTime createdAt = createdAtString != null
        ? DateTime.parse(createdAtString).toUtc()
        : DateTime.now().toUtc();
    return VendorShipment(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      vendorCompanyId: json['vendor_company_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      tracking: json['tracking']?.toString(),
      createdAt: createdAt,
      vendorName: vendorName,
    );
  }
}

class VendorShipmentsController extends AsyncNotifier<List<VendorShipment>> {
  @override
  Future<List<VendorShipment>> build() async {
    final filters = ref.watch(vendorShipmentsFiltersProvider);
    return _fetchShipments(filters);
  }

  Future<List<VendorShipment>> _fetchShipments(
    ShipmentsFilters filters,
  ) async {
    final SupabaseClient client = Supabase.instance.client;
    final String select =
        'id,order_id,vendor_company_id,status,tracking,created_at,companies!shipments_vendor_company_id_fkey(name)';
    dynamic query = client
        .from('shipments')
        .select(select)
        .order('created_at', ascending: false);

    if (filters.statuses.isNotEmpty) {
      query = query.in_('status', filters.statuses.toList());
    }
    final DateTimeRange? range = filters.dateRange;
    if (range != null) {
      query = query
          .gte('created_at', range.start.toUtc().toIso8601String())
          .lte('created_at', range.end.toUtc().toIso8601String());
    }
    final String trimmedQuery = filters.query.trim();
    if (trimmedQuery.isNotEmpty) {
      final String escaped = trimmedQuery
          .replaceAll("'", "''")
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      final String pattern = '%$escaped%';
      query = query.or(
        'vendor_company_id.ilike.$pattern,tracking.ilike.$pattern,companies.name.ilike.$pattern',
      );
    }

    final dynamic response = await query.limit(200);
    if (response is List) {
      return response
          .map((dynamic e) => VendorShipment.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
          .toList();
    }
    return const <VendorShipment>[];
  }
}

class VendorShipmentsPage extends ConsumerStatefulWidget {
  const VendorShipmentsPage({super.key});

  @override
  ConsumerState<VendorShipmentsPage> createState() =>
      _VendorShipmentsPageState();
}

class _VendorShipmentsPageState extends ConsumerState<VendorShipmentsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _handleSearchControllerChanged() {
    setState(() {});
  }

  ShipmentsFilters get _filters => ref.read(vendorShipmentsFiltersProvider);

  @override
  void initState() {
    super.initState();
    _searchController.text = _filters.query;
    _searchController.addListener(_handleSearchControllerChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_handleSearchControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ShipmentsFilters filters = ref.watch(vendorShipmentsFiltersProvider);
    final AsyncValue<List<VendorShipment>> shipments =
        ref.watch(vendorShipmentsControllerProvider);

    return Column(
      children: <Widget>[
        _ShipmentsFiltersBar(
          filters: filters,
          controller: _searchController,
          onStatusToggle: _onToggleStatus,
          onDateRangeTap: () => _selectDateRange(context, filters),
          onClearDateRange:
              filters.dateRange != null ? () => _clearDateRange() : null,
          onSearchChanged: _onSearchChanged,
          onClearSearch: _onClearSearch,
          onReset: _onResetFilters,
          l10n: l10n,
        ),
        Expanded(
          child: shipments.when(
            data: (List<VendorShipment> items) {
              if (items.isEmpty) {
                return _EmptyShipmentsView(
                  l10n: l10n,
                  onRefresh: _refreshShipments,
                );
              }
              return RefreshIndicator(
                onRefresh: _refreshShipments,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final VendorShipment shipment = items[index];
                    return _ShipmentTile(
                      shipment: shipment,
                      onUpdate: () =>
                          _showUpdateDialog(context, shipment, l10n),
                      l10n: l10n,
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace? stackTrace) =>
                _ShipmentsErrorView(
              l10n: l10n,
              onRetry: _refreshShipments,
            ),
          ),
        ),
      ],
    );
  }

  void _onToggleStatus(String status) {
    ref.read(vendorShipmentsFiltersProvider.notifier).toggleStatus(status);
  }

  void _clearDateRange() {
    ref.read(vendorShipmentsFiltersProvider.notifier).setDateRange(null);
  }

  Future<void> _selectDateRange(
    BuildContext context,
    ShipmentsFilters filters,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: filters.dateRange,
    );
    if (!mounted) {
      return;
    }
    ref.read(vendorShipmentsFiltersProvider.notifier).setDateRange(picked);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(vendorShipmentsFiltersProvider.notifier).setQuery(value);
    });
  }

  void _onClearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(vendorShipmentsFiltersProvider.notifier).setQuery('');
  }

  void _onResetFilters() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(vendorShipmentsFiltersProvider.notifier).reset();
  }

  Future<void> _refreshShipments() async {
    ref.invalidate(vendorShipmentsControllerProvider);
    await ref.read(vendorShipmentsControllerProvider.future);
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    VendorShipment shipment,
    MarketplaceLocalizations? l10n,
  ) async {
    final BuildContext rootContext = context;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ShipmentUpdateDialog(
          shipment: shipment,
          l10n: l10n,
          onSave: (String status, String? tracking) async {
            return _submitUpdate(
              shipmentId: shipment.id,
              status: status,
              tracking: tracking,
            );
          },
        );
      },
    );
    if (!mounted || !rootContext.mounted || result == null) {
      return;
    }
    FocusScope.of(rootContext).unfocus();
    await _refreshShipments();
    if (!mounted || !rootContext.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(rootContext);
    if (result) {
      messenger.showSnackBar(
        SnackBar(
          key: VendorKeys.shipmentUpdateSuccessSnackBar,
          content: Text(
            l10n?.translate('vendorShipmentsUpdated') ?? 'Shipment updated',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          key: VendorKeys.shipmentUpdateErrorSnackBar,
          content: Text(
            l10n?.translate('vendorShipmentsUpdateFailed') ??
                'Failed to update shipment',
          ),
        ),
      );
    }
  }

  Future<bool> _submitUpdate({
    required String shipmentId,
    required String status,
    String? tracking,
  }) async {
    final SupabaseClient client = Supabase.instance.client;
    try {
      await client.rpc<void>('rpc_update_shipment', params: <String, dynamic>{
        'p_shipment_id': shipmentId,
        'p_status': status,
        'p_tracking': tracking,
      });
      ref.invalidate(vendorShipmentsControllerProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _ShipmentUpdateDialog extends StatefulWidget {
  const _ShipmentUpdateDialog({
    required this.shipment,
    required this.l10n,
    required this.onSave,
  });

  final VendorShipment shipment;
  final MarketplaceLocalizations? l10n;
  final Future<bool> Function(String status, String? tracking) onSave;

  @override
  State<_ShipmentUpdateDialog> createState() => _ShipmentUpdateDialogState();
}

class _ShipmentUpdateDialogState extends State<_ShipmentUpdateDialog> {
  late final TextEditingController _trackingController;
  late String _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _trackingController =
        TextEditingController(text: widget.shipment.tracking ?? '');
    _selectedStatus = widget.shipment.status;
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n = widget.l10n;
    return AlertDialog(
      title: Text(
        l10n?.translate('vendorShipmentsUpdateTitle') ?? 'Update shipment',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButtonFormField<String>(
            key: VendorKeys.shipmentStatusField,
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: l10n?.translate('vendorShipmentsUpdateStatusLabel') ??
                  'Status',
            ),
            items: _shipmentStatusOptions
                .map(
                  (String status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(_localizedStatus(status, l10n)),
                  ),
                )
                .toList(),
            onChanged: _isSubmitting
                ? null
                : (String? value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: VendorKeys.shipmentTrackingField,
            controller: _trackingController,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText:
                  l10n?.translate('vendorShipmentsUpdateTrackingLabel') ??
                      'Tracking number',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          key: const ValueKey('shipment_update_cancel'),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            l10n?.translate('vendorShipmentsUpdateCancel') ?? 'Cancel',
          ),
        ),
        FilledButton(
          key: VendorKeys.shipmentUpdateSaveButton,
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() => _isSubmitting = true);
                  final navigator = Navigator.of(context);
                  final focusScope = FocusScope.of(context);
                  final String tracking = _trackingController.text.trim();
                  final bool success = await widget.onSave(
                    _selectedStatus,
                    tracking.isEmpty ? null : tracking,
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(() => _isSubmitting = false);
                  focusScope.unfocus();
                  navigator.pop(success);
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  l10n?.translate('vendorShipmentsUpdateSave') ?? 'Save',
                ),
        ),
      ],
    );
  }
}

class _ShipmentsFiltersBar extends StatelessWidget {
  const _ShipmentsFiltersBar({
    required this.filters,
    required this.controller,
    required this.onStatusToggle,
    required this.onDateRangeTap,
    required this.onSearchChanged,
    required this.onReset,
    this.onClearDateRange,
    this.onClearSearch,
    this.l10n,
  });

  final ShipmentsFilters filters;
  final TextEditingController controller;
  final VoidCallback? onClearDateRange;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClearSearch;
  final VoidCallback onDateRangeTap;
  final VoidCallback onReset;
  final void Function(String) onStatusToggle;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final String dateLabel;
    if (filters.dateRange == null) {
      dateLabel = l10n?.translate('vendorShipmentsDateRangePlaceholder') ??
          'Date range';
    } else {
      final String start =
          materialLocalizations.formatMediumDate(filters.dateRange!.start);
      final String end =
          materialLocalizations.formatMediumDate(filters.dateRange!.end);
      dateLabel = '$start – $end';
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stack = constraints.maxWidth < 360;
                final Widget title = Text(
                  l10n?.translate('vendorShipmentsFiltersStatus') ?? 'Status',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                );
                final Widget resetButton = TextButton(
                  onPressed: onReset,
                  child: Text(
                    l10n?.translate('vendorShipmentsFiltersReset') ?? 'Reset',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      title,
                      const SizedBox(height: 8),
                      resetButton,
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(child: title),
                    const SizedBox(width: 8),
                    resetButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _shipmentStatusOptions
                  .map(
                    (String status) => FilterChip(
                      label: Text(_localizedStatus(status, l10n)),
                      selected: filters.statuses.contains(status),
                      onSelected: (_) => onStatusToggle(status),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stack = constraints.maxWidth < 360;
                final Widget dateButton = OutlinedButton.icon(
                  onPressed: onDateRangeTap,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                );
                final Widget? clearButton = filters.dateRange != null
                    ? IconButton(
                        tooltip:
                            l10n?.translate('vendorShipmentsDateRangeClear') ??
                                'Clear',
                        onPressed: onClearDateRange,
                        icon: const Icon(Icons.clear),
                      )
                    : null;
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      dateButton,
                      if (clearButton != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: clearButton,
                        ),
                      ],
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(child: dateButton),
                    if (clearButton != null) ...<Widget>[
                      const SizedBox(width: 8),
                      clearButton,
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n?.translate(
                        'vendorShipmentsFiltersSearchPlaceholder') ??
                    'Search shipments',
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip:
                            l10n?.translate('vendorShipmentsSearchClear') ??
                                'Clear search',
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShipmentsView extends StatelessWidget {
  const _EmptyShipmentsView({
    required this.onRefresh,
    this.l10n,
  });

  final MarketplaceLocalizations? l10n;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.translate('vendorShipmentsEmptyTitle') ??
                      'No shipments yet',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.translate('vendorShipmentsEmptyBody') ??
                      'Shipments will appear once orders are fulfilled.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentsErrorView extends StatelessWidget {
  const _ShipmentsErrorView({
    required this.onRetry,
    this.l10n,
  });

  final MarketplaceLocalizations? l10n;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n?.translate('vendorShipmentsError') ??
                  'Failed to load shipments',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onRetry(),
              child: Text(
                l10n?.translate('vendorShipmentsRetry') ?? 'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShipmentTile extends StatelessWidget {
  const _ShipmentTile({
    required this.shipment,
    required this.onUpdate,
    this.l10n,
  });

  final VendorShipment shipment;
  final VoidCallback onUpdate;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final DateTime localDate = shipment.createdAt.toLocal();
    final String createdLabel =
        '${materialLocalizations.formatMediumDate(localDate)} · '
        '${intl.DateFormat.Hm().format(localDate)}';
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final TextStyle? labelStyle = textTheme.labelSmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final bool hasTracking = shipment.tracking?.trim().isNotEmpty == true;
    final AlignmentDirectional actionAlignment =
        Directionality.of(context) == TextDirection.ltr
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stack = constraints.maxWidth < 360;
                final Widget contentColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n?.translate('vendorShipmentsOrderLabel') ??
                          'Order ID',
                      style: labelStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      shipment.orderId,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n?.translate('vendorShipmentsCreatedLabel') ??
                          'Created',
                      style: labelStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdLabel,
                      style: textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ],
                );
                final Widget statusPill = Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _localizedStatus(shipment.status, l10n),
                    style: textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                );
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      contentColumn,
                      const SizedBox(height: 12),
                      statusPill,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: contentColumn),
                    const SizedBox(width: 12),
                    statusPill,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.translate('vendorShipmentsRowTracking') ?? 'Tracking',
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            const SizedBox(height: 4),
            if (hasTracking)
              SelectableText(
                shipment.tracking!,
                style: textTheme.bodyMedium,
              )
            else
              Text(
                l10n?.translate('vendorShipmentsTrackingPlaceholder') ??
                    'No tracking number yet',
                style: textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            const SizedBox(height: 16),
            Align(
              alignment: actionAlignment,
              child: Tooltip(
                message: 'Edit', // l10n optional; tests not text bound
                child: TextButton.icon(
                  key: VendorKeys.shipmentEditButton,
                  onPressed: onUpdate,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(
                    l10n?.translate('vendorShipmentsUpdateAction') ?? 'Update',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localizedStatus(String status, MarketplaceLocalizations? l10n) {
  final String keySuffix = status
      .split(RegExp(r'[_\s-]+'))
      .where((String part) => part.isNotEmpty)
      .map((String part) =>
          part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join();
  final String key = 'shipmentStatus$keySuffix';
  return l10n?.translate(key) ?? _fallbackStatus(status);
}

String _fallbackStatus(String status) {
  switch (status) {
    case 'pending':
      return 'Pending';
    case 'ready':
      return 'Ready';
    case 'in_transit':
      return 'In transit';
    case 'delivered':
      return 'Delivered';
    case 'cancelled':
      return 'Cancelled';
    default:
      return status;
  }
}
