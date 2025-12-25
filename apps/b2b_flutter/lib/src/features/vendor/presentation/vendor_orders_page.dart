import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ashachar_marketplace/src/core/async_value_x.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/supabase/supabase_client_provider.dart';
import 'package:ashachar_marketplace/src/features/vendor/presentation/vendor_shipments_page.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/vendor_rfq_page.dart';

class VendorOrderSummary {
  const VendorOrderSummary({
    required this.orderId,
    required this.orderNumber,
    required this.createdAt,
    required this.vendorTotal,
  });

  final String orderId;
  final String orderNumber;
  final DateTime createdAt;
  final double vendorTotal;

  String get displayNumber => orderNumber.isNotEmpty ? orderNumber : orderId;

  factory VendorOrderSummary.fromPrimary(Map<String, dynamic> json) {
    final String orderId = json['order_id']?.toString() ?? '';
    final String orderNumber = json['order_number']?.toString() ?? orderId;
    final DateTime createdAt = DateTime.tryParse(
          json['created_at']?.toString() ?? '',
        )?.toUtc() ??
        DateTime.now().toUtc();
    final double vendorTotal = json['vendor_total'] is num
        ? (json['vendor_total'] as num).toDouble()
        : double.tryParse(json['vendor_total']?.toString() ?? '') ?? 0.0;
    return VendorOrderSummary(
      orderId: orderId,
      orderNumber: orderNumber,
      createdAt: createdAt,
      vendorTotal: vendorTotal,
    );
  }
}

final vendorOrdersProvider =
    FutureProvider.autoDispose<List<VendorOrderSummary>>((ref) async {
  final SupabaseClient client = ref.read(supabaseClientProvider);
  try {
    final dynamic response = await client
        .from('v_vendor_orders')
        .select('order_id,order_number,created_at,vendor_total')
        .order('created_at', ascending: false)
        .limit(100);
    if (response is List) {
      return response
          .map((dynamic row) => VendorOrderSummary.fromPrimary(
              Map<String, dynamic>.from(row as Map<dynamic, dynamic>)))
          .toList();
    }
  } catch (error, stackTrace) {
    debugPrint('Vendor orders materialized view unavailable: $error');
    try {
      final dynamic response = await client
          .from('order_items')
          .select('order_id,orders(order_number,created_at),line_total')
          .order('created_at', referencedTable: 'orders', ascending: false)
          .limit(200);
      if (response is List) {
        final Map<String, Map<String, dynamic>> aggregated =
            <String, Map<String, dynamic>>{};
        for (final dynamic row in response) {
          final Map<String, dynamic> map =
              Map<String, dynamic>.from(row as Map<dynamic, dynamic>);
          final String orderId = (map['order_id'] ?? '').toString();
          final Map<String, dynamic> orderMap = map['orders'] is Map
              ? Map<String, dynamic>.from(map['orders'] as Map)
              : <String, dynamic>{};
          final String orderNumber =
              (orderMap['order_number'] ?? orderId).toString();
          final DateTime createdAt = DateTime.tryParse(
                orderMap['created_at']?.toString() ?? '',
              )?.toUtc() ??
              DateTime.now().toUtc();
          final double lineTotal = map['line_total'] is num
              ? (map['line_total'] as num).toDouble()
              : 0.0;
          final Map<String, dynamic> current = aggregated[orderId] ??
              <String, dynamic>{
                'order_id': orderId,
                'order_number': orderNumber,
                'created_at': createdAt,
                'vendor_total': 0.0,
              };
          current['vendor_total'] =
              (current['vendor_total'] as double) + lineTotal;
          aggregated[orderId] = current;
        }
        final List<VendorOrderSummary> fallback = aggregated.values
            .map(
              (Map<String, dynamic> map) => VendorOrderSummary(
                orderId: map['order_id']?.toString() ?? '',
                orderNumber: map['order_number']?.toString() ?? '',
                createdAt:
                    (map['created_at'] as DateTime?) ?? DateTime.now().toUtc(),
                vendorTotal: (map['vendor_total'] as double?) ?? 0.0,
              ),
            )
            .toList()
          ..sort((VendorOrderSummary a, VendorOrderSummary b) =>
              b.createdAt.compareTo(a.createdAt));
        return fallback.take(100).toList();
      }
    } catch (fallbackError, fallbackStackTrace) {
      Error.throwWithStackTrace(fallbackError, fallbackStackTrace);
    }
    Error.throwWithStackTrace(error, stackTrace);
  }
  return const <VendorOrderSummary>[];
});

class VendorOrdersPage extends ConsumerWidget {
  const VendorOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    final String title =
        l10n?.translate('vendorConsoleTitle') ?? 'Vendor Console';
    final String ordersTab = l10n?.translate('vendorOrdersTab') ?? 'Orders';
    final String rfqsTab = l10n?.translate('vendorRfqsTab') ?? 'RFQs';
    final String shipmentsTab =
        l10n?.translate('vendorShipmentsTab') ?? 'Shipments';
    final String signOutLabel = l10n?.translate('signOut') ?? 'Sign out';
    final String signInLabel = l10n?.translate('authSignIn') ?? 'Sign in';
    final sessionState = ref.watch(sessionControllerProvider);
    final bool isAuthenticated = sessionState.valueOrNull != null;
    final Color actionColor = Theme.of(context).colorScheme.onPrimary;
    const String logoutActionKey = 'logout';

    Widget? buildAuthAction() {
      if (isAuthenticated) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: PopupMenuButton<String>(
            tooltip: signOutLabel,
            onSelected: (selected) async {
              if (selected != logoutActionKey) {
                return;
              }
              try {
                await ref.read(supabaseClientProvider).auth.signOut();
                debugPrint('[AUTH_FLOW] logout=ok');
                if (!context.mounted) {
                  return;
                }
                context.go('/home');
              } catch (error) {
                debugPrint('[AUTH_FLOW] logout=fail error=$error');
              }
            },
            itemBuilder: (BuildContext _) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: logoutActionKey,
                child: Text(signOutLabel),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                signOutLabel,
                style: TextStyle(color: actionColor),
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: actionColor,
          ),
          onPressed: () {
            context.go('/login');
          },
          child: Text(signInLabel),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            buildAuthAction(),
          ].whereType<Widget>().toList(),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: ordersTab),
              Tab(text: rfqsTab),
              Tab(text: shipmentsTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _VendorOrdersTab(),
            VendorRfqsPage(),
            VendorShipmentsPage(),
          ],
        ),
      ),
    );
  }
}

class _VendorOrdersTab extends ConsumerWidget {
  const _VendorOrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<List<VendorOrderSummary>> ordersValue =
        ref.watch(vendorOrdersProvider);

    Future<void> refresh() async {
      ref.invalidate(vendorOrdersProvider);
      await ref.read(vendorOrdersProvider.future);
    }

    return ordersValue.when(
      data: (List<VendorOrderSummary> orders) {
        if (orders.isEmpty) {
          return _VendorOrdersEmptyView(
            l10n: l10n,
            onRefresh: refresh,
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) =>
                _VendorOrderCard(order: orders[index], l10n: l10n),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace? stackTrace) => _VendorOrdersErrorView(
        l10n: l10n,
        onRetry: refresh,
      ),
    );
  }
}

class _VendorOrdersEmptyView extends StatelessWidget {
  const _VendorOrdersEmptyView({
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
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.translate('vendorOrdersEmptyTitle') ??
                      'No vendor orders yet',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.translate('vendorOrdersEmptyBody') ??
                      'Orders assigned to your company will appear here.',
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

class _VendorOrdersErrorView extends StatelessWidget {
  const _VendorOrdersErrorView({
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
              l10n?.translate('vendorOrdersError') ??
                  'Failed to load vendor orders',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => onRetry(),
              child: Text(
                l10n?.translate('vendorOrdersRetry') ?? 'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorOrderCard extends StatelessWidget {
  const _VendorOrderCard({
    required this.order,
    this.l10n,
  });

  final VendorOrderSummary order;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Locale locale = Localizations.localeOf(context);
    final String localeName = intl.Intl.canonicalizedLocale(locale.toString());
    final intl.NumberFormat currencyFormatter =
        intl.NumberFormat.simpleCurrency(locale: localeName);
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final DateTime localCreatedAt = order.createdAt.toLocal();
    final String createdLabel =
        '${materialLocalizations.formatMediumDate(localCreatedAt)} · '
        '${intl.DateFormat.Hm().format(localCreatedAt)}';

    final TextStyle? labelStyle = textTheme.labelSmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n?.translate('vendorOrdersOrderLabel') ?? 'Order',
                        style: labelStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.displayNumber,
                        style: textTheme.titleMedium,
                      ),
                      if (order.orderId != order.displayNumber) ...<Widget>[
                        const SizedBox(height: 4),
                        SelectableText(
                          order.orderId,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      l10n?.translate('vendorOrdersAmountLabel') ?? 'Amount',
                      style: labelStyle,
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(order.vendorTotal),
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.translate('vendorShipmentsCreatedLabel') ?? 'Created',
              style: labelStyle,
            ),
            const SizedBox(height: 4),
            Text(
              createdLabel,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
