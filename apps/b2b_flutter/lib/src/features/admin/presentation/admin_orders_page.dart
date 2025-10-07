import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_actions_widgets.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/widgets/order_status_chip.dart';

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _loading = true;
  String? _errorMessage;
  List<_AdminOrder> _allOrders = const <_AdminOrder>[];
  List<_AdminOrder> _visibleOrders = const <_AdminOrder>[];
  List<String> _availableStatuses = const <String>[];

  DateTimeRange? _dateFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final List<_AdminOrder> orders = await _loadOrders();
      if (!mounted) return;
      setState(() {
        _allOrders = orders;
        _availableStatuses = _deriveStatuses(orders);
        _visibleOrders = _filterOrders(orders);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _loading = false;
      });
    }
  }

  Future<List<_AdminOrder>> _loadOrders() async {
    final SupabaseClient client = Supabase.instance.client;
    final dynamic response = await client
        .from('orders')
        .select('id, order_number, created_at, total, status')
        .order('created_at', ascending: false)
        .limit(200);

    final List<dynamic> raw =
        response is List<dynamic> ? response : const <dynamic>[];
    return raw
        .map((dynamic row) => _AdminOrder.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  List<String> _deriveStatuses(List<_AdminOrder> orders) {
    final Set<String> values = orders
        .map((order) => order.status)
        .where((status) => status.isNotEmpty)
        .toSet();
    final List<String> sorted = values.toList()..sort();
    return sorted;
  }

  List<_AdminOrder> _filterOrders([List<_AdminOrder>? source]) {
    final List<_AdminOrder> base = source ?? _allOrders;
    final String query = _searchController.text.trim().toLowerCase();

    return base.where((order) {
      final bool matchesStatus =
          _statusFilter == null || order.status == _statusFilter;
      final bool matchesQuery = query.isEmpty
          ? true
          : order.orderNumber.toLowerCase().contains(query) ||
              order.id.toLowerCase().contains(query) ||
              NumberFormat.compact()
                  .format(order.total)
                  .toLowerCase()
                  .contains(query);
      final bool matchesDate = _matchesDate(order.createdAt);
      return matchesStatus && matchesQuery && matchesDate;
    }).toList(growable: false);
  }

  bool _matchesDate(DateTime createdAt) {
    if (_dateFilter == null) {
      return true;
    }
    final DateTime start = DateTime(
      _dateFilter!.start.year,
      _dateFilter!.start.month,
      _dateFilter!.start.day,
    );
    final DateTime end = DateTime(
      _dateFilter!.end.year,
      _dateFilter!.end.month,
      _dateFilter!.end.day,
      23,
      59,
      59,
      999,
    );
    return !createdAt.isBefore(start) && !createdAt.isAfter(end);
  }

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateFilter ??
          DateTimeRange(
            start: DateTime(now.year, now.month, now.day).subtract(
              const Duration(days: 30),
            ),
            end: now,
          ),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _dateFilter = picked;
      _visibleOrders = _filterOrders();
    });
  }

  void _clearDateRange() {
    setState(() {
      _dateFilter = null;
      _visibleOrders = _filterOrders();
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _visibleOrders = _filterOrders());
    });
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _statusFilter = value?.isEmpty ?? true ? null : value;
      _visibleOrders = _filterOrders();
    });
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _statusFilter = null;
      _dateFilter = null;
      _visibleOrders = _filterOrders(_allOrders);
    });
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
    final bool hasActiveFilters = _statusFilter != null ||
        _dateFilter != null ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('adminOrdersTitle') ?? 'Admin • Orders',
        ),
        actions: [
          IconButton(
            tooltip: l10n?.translate('adminOrdersReload') ?? 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _fetchOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          children: [
            _AdminAccessInfoBanner(
                l10n: Localizations.of<MarketplaceLocalizations>(
                    context, MarketplaceLocalizations)),
            const SizedBox(height: ASpacing.lg),
            _OrdersFilterBar(
              controller: _searchController,
              availableStatuses: _availableStatuses,
              selectedStatus: _statusFilter,
              dateFilter: _dateFilter,
              hasActiveFilters: hasActiveFilters,
              onSearchChanged: _onSearchChanged,
              onStatusChanged: _onStatusChanged,
              onDateTap: _selectDateRange,
              onDateClear: _dateFilter != null ? _clearDateRange : null,
              onReset: hasActiveFilters ? _resetFilters : null,
              l10n: l10n,
            ),
            const SizedBox(height: ASpacing.lg),
            _buildContent(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MarketplaceLocalizations? l10n) {
    if (_loading) {
      return const _AdminOrdersLoading();
    }
    if (_errorMessage != null) {
      return AStateMessage(
        icon: Icons.error_outline,
        title:
            l10n?.translate('adminOrdersErrorTitle') ?? 'Unable to load orders',
        message: _errorMessage,
        primaryLabel: l10n?.translate('adminOrdersReload') ?? 'Reload',
        onPrimaryPressed: _fetchOrders,
      );
    }
    if (_visibleOrders.isEmpty) {
      return AStateMessage(
        icon: Icons.receipt_long_outlined,
        title: l10n?.translate('adminOrdersEmptyTitle') ??
            'No orders match your filters',
        message: l10n?.translate('adminOrdersEmptyBody') ??
            'Adjust status, dates, or search to see results.',
        primaryLabel:
            l10n?.translate('adminOrdersFiltersClear') ?? 'Reset filters',
        onPrimaryPressed: _resetFilters,
      );
    }

    return _AdminOrdersTable(
      orders: _visibleOrders,
      l10n: l10n,
    );
  }
}

class _OrdersFilterBar extends StatelessWidget {
  const _OrdersFilterBar({
    required this.controller,
    required this.availableStatuses,
    required this.selectedStatus,
    required this.dateFilter,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onDateTap,
    required this.onDateClear,
    required this.onReset,
    required this.l10n,
  });

  final TextEditingController controller;
  final List<String> availableStatuses;
  final String? selectedStatus;
  final DateTimeRange? dateFilter;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onDateTap;
  final VoidCallback? onDateClear;
  final VoidCallback? onReset;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat dateFormat = DateFormat.yMd(locale.toLanguageTag());
    final String rangeLabel;
    if (dateFilter == null) {
      rangeLabel = l10n?.translate('adminOrdersFiltersRangeAll') ?? 'All dates';
    } else {
      final String start = dateFormat.format(dateFilter!.start);
      final String end = dateFormat.format(dateFilter!.end);
      rangeLabel = '$start – $end';
    }

    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.translate('adminOrdersFiltersTitle') ?? 'Filters',
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.md),
          Wrap(
            spacing: ASpacing.lg,
            runSpacing: ASpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  controller: controller,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.translate('adminOrdersFiltersSearchLabel') ??
                            'Search orders',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: ARadii.md,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String?>(
                  value: selectedStatus,
                  items: _buildStatusItems(),
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText:
                        l10n?.translate('adminOrdersFiltersStatusLabel') ??
                            'Status',
                    border: OutlineInputBorder(
                      borderRadius: ARadii.md,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ASpacing.md,
                      vertical: ASpacing.sm,
                    ),
                  ),
                  onChanged: onStatusChanged,
                ),
              ),
              Wrap(
                spacing: ASpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: onDateTap,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      l10n?.translate('adminOrdersFiltersDateLabel') ??
                          'Date range',
                    ),
                  ),
                  Text(
                    rangeLabel,
                    style: ATypography.bodySm.copyWith(
                      color: AColors.mutedForeground,
                    ),
                  ),
                  if (onDateClear != null)
                    TextButton(
                      onPressed: onDateClear,
                      child: Text(
                        l10n?.translate('adminOrdersFiltersDateClear') ??
                            'Clear',
                      ),
                    ),
                ],
              ),
              if (onReset != null)
                TextButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(
                    l10n?.translate('adminOrdersFiltersClear') ??
                        'Reset filters',
                  ),
                ),
            ],
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: ASpacing.md),
            Text(
              l10n?.translate('adminOrdersFiltersActiveHint') ??
                  'Filters applied to the list below.',
              style: ATypography.bodySm,
            ),
          ],
        ],
      ),
    );
  }

  List<DropdownMenuItem<String?>> _buildStatusItems() {
    final List<DropdownMenuItem<String?>> items = [
      DropdownMenuItem<String?>(
        value: null,
        child: Text(
          l10n?.translate('adminOrdersFiltersStatusAll') ?? 'All statuses',
        ),
      ),
    ];
    for (final String status in availableStatuses) {
      items.add(
        DropdownMenuItem<String>(
          value: status,
          child: Text(_localizedStatus(status)),
        ),
      );
    }
    return items;
  }

  String _localizedStatus(String status) {
    final Map<String, String> mapping = _statusLocalizationKeys;
    final String key = mapping[status] ?? status;
    return l10n?.translate(key) ?? _formatFallback(status);
  }

  String _formatFallback(String status) {
    if (status.isEmpty) return status;
    return status.replaceAll('_', ' ').split(' ').map((segment) {
      if (segment.isEmpty) return segment;
      return segment[0].toUpperCase() + segment.substring(1);
    }).join(' ');
  }
}

class _AdminAccessInfoBanner extends StatelessWidget {
  const _AdminAccessInfoBanner({required this.l10n});

  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String title = l10n?.translate('adminOrdersRlsTitle') ??
        'הנתונים מוצגים בהתאם להרשאות RLS';
    final String body = l10n?.translate('adminOrdersRlsBody') ??
        'מנויים רואים רק הזמנות של החברות המורשות להם. אם הזמנה חסרה, בדקו את הרשאות החברה מול מסמך RLS.';

    return ACard(
      backgroundColor: AColors.surfaceMuted,
      padding: const EdgeInsetsDirectional.all(ASpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.privacy_tip, color: AColors.primary),
          const SizedBox(width: ASpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ATypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  body,
                  style: ATypography.bodySm,
                ),
                const SizedBox(height: ASpacing.xs),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.translate('adminOrdersRlsSnackbar') ??
                              'עיין ב-docs/RLS-matrix.md כדי לאמת הרשאות.',
                        ),
                        action: SnackBarAction(
                          label: l10n?.translate('commonDismiss') ?? 'סגור',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: Text(
                    l10n?.translate('adminOrdersRlsAction') ??
                        'פתיחת מסמך RLS-matrix',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrdersTable extends StatelessWidget {
  const _AdminOrdersTable({
    required this.orders,
    required this.l10n,
  });

  final List<_AdminOrder> orders;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String localeTag = locale.toLanguageTag();
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: localeTag,
      symbol: '₪',
    );
    final DateFormat dateFormat = DateFormat.yMMMd(localeTag).add_Hm();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double minWidth = math.max(constraints.maxWidth, 720);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: ACard(
              padding: EdgeInsets.zero,
              child: DataTable(
                headingTextStyle: ATypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AColors.mutedForeground,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      l10n?.translate('adminOrdersTableOrder') ?? 'Order',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n?.translate('adminOrdersTableCreated') ?? 'Created',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n?.translate('adminOrdersTableStatus') ?? 'Status',
                    ),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Text(
                      l10n?.translate('adminOrdersTableTotal') ?? 'Total',
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      l10n?.translate('adminOrdersTableActions') ?? 'Actions',
                    ),
                  ),
                ],
                rows: orders
                    .map(
                      (_AdminOrder order) => DataRow(
                        cells: [
                          DataCell(
                            Text(order.orderNumber, style: ATypography.bodyMd),
                          ),
                          DataCell(
                            Text(
                              dateFormat.format(order.createdAt.toLocal()),
                              style: ATypography.bodySm,
                            ),
                          ),
                          DataCell(
                            OrderStatusChip(
                              status: order.status,
                              l10n: l10n,
                              compact: true,
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                currencyFormat.format(order.total),
                                style: ATypography.bodyMd,
                              ),
                            ),
                          ),
                          DataCell(
                            AdminSplitActionButton(
                              orderId: order.id,
                              callSplit: () async {
                                final SupabaseClient supa =
                                    Supabase.instance.client;
                                final int rpcResult = await supa.rpc<int?>(
                                        'rpc_split_order',
                                        params: {'p_order_id': order.id}) ??
                                    0;
                                final String baseMessage = (l10n?.translate(
                                            'adminOrdersSplitVendorCount') ??
                                        'Vendors queued: {count}')
                                    .replaceAll(
                                        '{count}', rpcResult.toString());
                                try {
                                  await supa.functions.invoke(
                                    'order_splitter',
                                    body: {'order_id': order.id},
                                  );
                                  return baseMessage;
                                } catch (_) {
                                  final String warning = l10n?.translate(
                                          'adminOrdersSplitEdgeWarning') ??
                                      'Edge sync failed. Shipments were created via RPC.';
                                  return '$baseMessage\n$warning';
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdminOrdersLoading extends StatelessWidget {
  const _AdminOrdersLoading();

  @override
  Widget build(BuildContext context) {
    return ACard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ASkeleton(width: 200, height: 18),
          SizedBox(height: ASpacing.sm),
          ASkeleton(width: 260, height: 14),
          SizedBox(height: ASpacing.md),
          ASkeleton(width: double.infinity, height: 12),
          SizedBox(height: ASpacing.xs),
          ASkeleton(width: double.infinity, height: 12),
          SizedBox(height: ASpacing.xs),
          ASkeleton(width: double.infinity, height: 12),
        ],
      ),
    );
  }
}

class _AdminOrder {
  const _AdminOrder({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.total,
    required this.status,
  });

  factory _AdminOrder.fromJson(Map<String, dynamic> json) {
    final String id = json['id']?.toString() ?? '';
    final String orderNumber = json['order_number']?.toString() ?? id;
    final String status = json['status']?.toString() ?? '';
    final dynamic totalRaw = json['total'];
    final double total = totalRaw is num
        ? totalRaw.toDouble()
        : double.tryParse('$totalRaw') ?? 0;
    final DateTime createdAt = DateTime.tryParse(
          json['created_at']?.toString() ?? '',
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return _AdminOrder(
      id: id,
      orderNumber: orderNumber,
      createdAt: createdAt,
      total: total,
      status: status,
    );
  }

  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final double total;
  final String status;
}

const Map<String, String> _statusLocalizationKeys = <String, String>{
  'draft': 'ordersStatusDraft',
  'submitted': 'ordersStatusSubmitted',
  'processing': 'ordersStatusProcessing',
  'completed': 'ordersStatusCompleted',
  'shipped': 'ordersStatusShipped',
  'in_transit': 'ordersStatusInTransit',
  'cancelled': 'ordersStatusCancelled',
};
