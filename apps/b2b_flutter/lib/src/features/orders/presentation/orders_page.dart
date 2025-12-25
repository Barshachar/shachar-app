import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/localization/generated/app_localizations.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/widgets/order_status_chip.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:offline_toolkit/offline_toolkit.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? legacyL10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AppLocalizations? l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    final AsyncValue<List<OrderSummary>> ordersAsync =
        ref.watch(ordersControllerProvider);
    final String ordersTitle =
        l10n?.ordersTitle ?? legacyL10n?.translate('ordersTitle') ?? 'Orders';
    final String ordersRfqsTooltip = l10n?.ordersRfqsTooltip ??
        legacyL10n?.translate('ordersRfqsTooltip') ??
        'Requests for quotes';
    final String ordersError = l10n?.ordersError ??
        legacyL10n?.translate('ordersError') ??
        'Failed to load orders';
    final String ordersRetry = l10n?.ordersRetry ??
        legacyL10n?.translate('ordersRetry') ??
        'Try again';
    final String ordersEmptyTitle = l10n?.ordersEmptyTitle ??
        legacyL10n?.translate('ordersEmptyTitle') ??
        'No orders yet';
    final String ordersEmptyMessage = l10n?.ordersEmptyMessage ??
        legacyL10n?.translate('ordersEmptyMessage') ??
        'After you place orders you will see them here.';
    final String ordersEmptyCta = l10n?.ordersEmptyCta ??
        legacyL10n?.translate('ordersEmptyCta') ??
        'Go to catalog';

    return Scaffold(
      key: const ValueKey('orders_list_root'),
      appBar: AppBar(
        title: Text(ordersTitle),
        actions: [
          Semantics(
            label: ordersRfqsTooltip,
            button: true,
            child: IconButton(
              tooltip: ordersRfqsTooltip,
              icon: const Icon(Icons.request_quote_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext _) => const CustomerRfqsPage(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineSyncBanner(),
          Expanded(
            child: RepaintBoundary(
              key: const ValueKey('orders_list_capture'),
              child: ordersAsync.when(
                loading: () => const _OrdersLoading(),
                error: (Object error, _) => AStateMessage(
                  icon: Icons.error_outline,
                  title: ordersError,
                  message: error.toString(),
                  primaryLabel: ordersRetry,
                  onPrimaryPressed: () =>
                      ref.invalidate(ordersControllerProvider),
                ),
                data: (List<OrderSummary> orders) => RefreshIndicator(
                  onRefresh: () => ref.refresh(ordersControllerProvider.future),
                  child: orders.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: context
                              .pagePadding()
                              .resolve(Directionality.of(context)),
                          children: [
                            AStateMessage(
                              icon: Icons.receipt_long_outlined,
                              title: ordersEmptyTitle,
                              message: ordersEmptyMessage,
                              primaryLabel: ordersEmptyCta,
                              onPrimaryPressed: () => context.go('/catalog'),
                            ),
                          ],
                        )
                      : _OrdersList(
                          orders: orders,
                          l10n: l10n,
                          legacyL10n: legacyL10n,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.l10n,
    required this.legacyL10n,
  });

  final List<OrderSummary> orders;
  final AppLocalizations? l10n;
  final MarketplaceLocalizations? legacyL10n;

  @override
  Widget build(BuildContext context) {
    final String localeName = _resolveLocale(context);
    final intl.NumberFormat currencyFormat =
        intl.NumberFormat.simpleCurrency(locale: localeName);
    final intl.DateFormat dateFormat =
        intl.DateFormat.yMMMMd(localeName).add_Hm();
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsetsGeometry padding = context.pagePadding().resolve(
          textDirection,
        );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useTable = constraints.maxWidth >= 840;
        if (!useTable) {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: ASpacing.lg),
            itemBuilder: (BuildContext context, int index) {
              final OrderSummary order = orders[index];
              final String totalLabel = currencyFormat.format(order.total);
              final String createdLabel =
                  dateFormat.format(order.createdAt.toLocal());
              return ACard(
                onTap: () => context.pushNamed(
                  'order-detail',
                  pathParameters: <String, String>{'id': order.id},
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            order.orderNumber,
                            style: ATypography.titleSm,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            textDirection: textDirection,
                          ),
                        ),
                        OrderStatusChip(
                          status: order.status,
                          l10n: legacyL10n,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: ASpacing.md),
                    ALabeledValue(
                      label: l10n?.orderDetailCreatedAt ??
                          legacyL10n?.translate('orderDetailCreatedAt') ??
                          'Created at',
                      value: createdLabel,
                      icon: const Icon(
                        Icons.schedule,
                        size: 18,
                        color: AColors.neutral400,
                      ),
                    ),
                    const SizedBox(height: ASpacing.sm),
                    ALabeledValue(
                      label: l10n?.orderDetailTotal ??
                          legacyL10n?.translate('orderDetailTotal') ??
                          'Total',
                      value: totalLabel,
                      icon: const Icon(
                        Icons.payments_outlined,
                        size: 18,
                        color: AColors.neutral400,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          children: [
            ACard(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: ATypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AColors.mutedForeground,
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) =>
                        states.contains(WidgetState.hovered)
                            ? AColors.surfaceMuted
                            : null,
                  ),
                  columns: <DataColumn>[
                    DataColumn(
                      label: Text(
                        l10n?.ordersTableOrder ??
                            legacyL10n?.translate('ordersTableOrder') ??
                            'Order',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n?.ordersTableCreated ??
                            legacyL10n?.translate('ordersTableCreated') ??
                            'Created',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        l10n?.ordersTableStatus ??
                            legacyL10n?.translate('ordersTableStatus') ??
                            'Status',
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        l10n?.ordersTableTotal ??
                            legacyL10n?.translate('ordersTableTotal') ??
                            'Total',
                      ),
                    ),
                  ],
                  rows: orders.map((OrderSummary order) {
                    final String totalLabel =
                        currencyFormat.format(order.total);
                    final String createdLabel =
                        dateFormat.format(order.createdAt.toLocal());
                    return DataRow(
                      onSelectChanged: (_) => context.pushNamed(
                        'order-detail',
                        pathParameters: <String, String>{'id': order.id},
                      ),
                      cells: [
                        DataCell(
                            Text(order.orderNumber, style: ATypography.bodyMd)),
                        DataCell(Text(createdLabel, style: ATypography.bodySm)),
                        DataCell(OrderStatusChip(
                          status: order.status,
                          l10n: legacyL10n,
                          compact: true,
                        )),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              totalLabel,
                              style: ATypography.bodyMd,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(growable: false),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry padding =
        context.pagePadding().resolve(Directionality.of(context));
    return ListView.builder(
      padding: padding,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 4 ? 0 : ASpacing.lg),
          child: const ACard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ASkeleton(width: 180, height: 18),
                SizedBox(height: ASpacing.sm),
                ASkeleton(width: 140, height: 14),
                SizedBox(height: ASpacing.sm),
                ASkeleton(width: 80, height: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _resolveLocale(BuildContext context) {
  final Locale locale = Localizations.localeOf(context);
  final String localeName = locale.toString();
  if (intl.DateFormat.localeExists(localeName)) {
    return localeName;
  }
  if (intl.DateFormat.localeExists(locale.languageCode)) {
    return locale.languageCode;
  }
  return 'en';
}
