// ignore_for_file: avoid_print

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/catalog_recommendations_provider.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/customer_rfq_pages.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_create_dialog.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:ashachar_marketplace/src/features/pricing/presentation/contract_price_badge.dart';
import 'package:offline_toolkit/offline_toolkit.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  Future<void>? _bootstrapDraftFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapDraftFuture = Future<void>.value(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _bootstrapDraftFuture = _ensureOpenDraftFuture();
      });
    });
  }

  Future<void> _ensureOpenDraftFuture() {
    return ref
        .read(cartControllerProvider.notifier)
        .ensureOpenDraft()
        .then<void>((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final CartState cartState = ref.watch(cartControllerProvider);
    final String? draftOrderId = cartState.draftOrderId;
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.translate('cartTitle') ?? 'Cart')),
      body: Column(
        children: [
          const OfflineSyncBanner(),
          if (cartState.isLoading) const LinearProgressIndicator(minHeight: 2),
          if (draftOrderId != null)
            Padding(
              padding: const EdgeInsets.all(ASpacing.md),
              child: _CartTotalsFooter(draftOrderId: draftOrderId),
            ),
          Expanded(
            child: draftOrderId == null
                ? _buildLoading()
                : _CartLinesList(draftOrderId: draftOrderId),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: QuickOrderNavBar(
          currentTab: QuickNavTab.cart,
          checkoutOrderId: draftOrderId,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return FutureBuilder<void>(
      future: _bootstrapDraftFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        final MarketplaceLocalizations? l10n =
            Localizations.of<MarketplaceLocalizations>(
          context,
          MarketplaceLocalizations,
        );
        final String retryLabel = l10n?.translate('commonRetry') ?? 'Try again';
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final String errorLabel = l10n?.translate('cartDraftLoadError') ??
              "Couldn't load your draft cart.";
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('$errorLabel\n${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _bootstrapDraftFuture = _ensureOpenDraftFuture();
                      });
                    },
                    child: Text(retryLabel),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _CartLinesList extends ConsumerWidget {
  const _CartLinesList({required this.draftOrderId});

  final String draftOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CartLine>> linesAsync =
        ref.watch(cartLinesProvider(draftOrderId));
    final String companyId = ref.watch(quickOrderCompanyIdProvider);
    final Set<String>? companyCatalog = companyId.isEmpty
        ? null
        : ref.watch(quickOrderCompanyCatalogProvider(companyId)).maybeWhen(
              data: (value) => value,
              orElse: () => null,
            );
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    return linesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, _) => _CartErrorState(
        message:
            '${l10n?.translate('cartLoadError') ?? "We couldn't load the cart."}\n$error',
        onRetry: () => ref.invalidate(cartLinesProvider(draftOrderId)),
      ),
      data: (List<CartLine> lines) {
        if (lines.isEmpty) {
          return const _CartEmptyState();
        }
        final List<MapEntry<String, List<CartLine>>> groups =
            groupBy<CartLine, String>(
          lines,
          (CartLine line) => line.vendorCompanyId,
        ).entries.toList()
              ..sort((MapEntry<String, List<CartLine>> a,
                      MapEntry<String, List<CartLine>> b) =>
                  a.key.compareTo(b.key));

        final Set<String> excludedVariantIds = {
          for (final CartLine line in lines)
            if (line.variantId.isNotEmpty) line.variantId,
        };
        final CatalogRecommendationRequest recommendationsRequest =
            CatalogRecommendationRequest(
          excludedVariantIds: excludedVariantIds,
          allowedVariantIds: companyCatalog,
          limit: 4,
          seed: companyId,
        );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: groups.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == groups.length) {
              return Padding(
                padding: const EdgeInsets.only(top: ASpacing.xl),
                child: _CartRecommendationsSection(
                  request: recommendationsRequest,
                ),
              );
            }
            final MapEntry<String, List<CartLine>> entry = groups[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: ASpacing.xl,
              ),
              child: _CartVendorSection(
                vendorId: entry.key,
                lines: entry.value,
                companyId: companyId,
                companyCatalog: companyCatalog,
              ),
            );
          },
        );
      },
    );
  }
}

Future<String?> _launchRfqRequest(
  BuildContext context,
  WidgetRef ref,
  List<CartLine> lines,
) async {
  if (lines.isEmpty) {
    return null;
  }
  final String? rfqId = await showRfqCreateDialog(
    context: context,
    ref: ref,
    cartLines: lines,
  );
  if (rfqId == null) {
    return null;
  }
  ref.invalidate(customerRfqsProvider);
  return rfqId;
}

Future<void> _handleRfqResult({
  required NavigatorState navigator,
  required ScaffoldMessengerState messenger,
  required WidgetRef ref,
  required String rfqId,
  String? successMessage,
}) async {
  if (successMessage != null && successMessage.trim().isNotEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
  }
  await navigator.push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext _) => CustomerRfqDetailPage(rfqId: rfqId),
    ),
  );
  ref.invalidate(rfqDetailProvider(rfqId));
}

class _CartVendorSection extends ConsumerWidget {
  const _CartVendorSection({
    required this.vendorId,
    required this.lines,
    required this.companyId,
    required this.companyCatalog,
  });

  final String vendorId;
  final List<CartLine> lines;
  final String companyId;
  final Set<String>? companyCatalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);

    final bool hasGated = lines.any(
      (CartLine line) => _isLineNotInCatalog(
        companyId,
        companyCatalog,
        line,
      ),
    );

    final String vendorLabel = l10n != null
        ? l10n.translate('cartVendorLabel').replaceAll('{vendor}', vendorId)
        : 'ספק $vendorId';

    return Card(
      elevation: AElevation.level1,
      shape: RoundedRectangleBorder(borderRadius: ARadii.md),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vendorLabel,
              style: theme.textTheme.titleMedium,
            ),
            if (hasGated) ...[
              const SizedBox(height: ASpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ASpacing.md),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.errorContainer.withValues(alpha: 0.24),
                  borderRadius: ARadii.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.translate('cartVendorRestricted') ??
                          'חלק מהמוצרים של ספק זה דורשים אישור.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ASpacing.xs),
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          final String? rfqId =
                              await _launchRfqRequest(context, ref, lines);
                          if (!context.mounted || rfqId == null) {
                            return;
                          }
                          final String successMessage =
                              l10n?.translate('cartVendorRequestSuccess') ??
                                  'הבקשה נשלחה לספק.';
                          await _handleRfqResult(
                            navigator: navigator,
                            messenger: messenger,
                            ref: ref,
                            rfqId: rfqId,
                            successMessage: successMessage,
                          );
                        } on Object catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          final ScaffoldMessengerState messenger =
                              ScaffoldMessenger.maybeOf(context) ??
                                  ScaffoldMessenger.of(context);
                          final String message =
                              l10n?.translate('cartCreateQuoteError') ??
                                  "Couldn't create request.";
                          messenger.showSnackBar(
                            SnackBar(content: Text('$message $error')),
                          );
                        }
                      },
                      icon: const Icon(Icons.outgoing_mail, size: 18),
                      label: Text(
                        l10n?.translate('cartRequestAccess') ?? 'בקש גישה',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: ASpacing.md),
            for (int index = 0; index < lines.length; index++) ...[
              if (index > 0) const SizedBox(height: ASpacing.md),
              _CartLineTile(
                line: lines[index],
                companyId: companyId,
                companyCatalog: companyCatalog,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({
    required this.line,
    required this.companyId,
    required this.companyCatalog,
  });

  final CartLine line;
  final String companyId;
  final Set<String>? companyCatalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CartController controller = ref.read(cartControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);
    final AsyncValue<Session?> sessionState =
        ref.watch(sessionControllerProvider);
    final Session? session =
        sessionState.whenOrNull(data: (Session? value) => value);
    final String pricingCompanyId = _companyIdFromSession(session);
    final bool notInCatalog =
        _isLineNotInCatalog(companyId, companyCatalog, line);
    final String notInCatalogLabel = l10n?.translate('notInCatalogShort') ??
        (l10n?.translate('notInCatalog') ?? 'Not in catalog');
    final String removeTooltip =
        l10n?.translate('cartRemoveLineTooltip') ?? 'Remove';
    final String skuLabel = (line.variantSku?.isNotEmpty ?? false)
        ? line.variantSku!
        : line.variantId;

    Future<void> updateQuantity(num nextValue) async {
      final double target = nextValue.toDouble().clamp(1, 999);
      if ((target - line.qty).abs() < 0.0001) {
        return;
      }
      print('[CART] qty_change row=${line.rowId} from=${line.qty} to=$target');
      try {
        await controller.updateLineQty(line.rowId, target);
      } on Object catch (error, _) {
        if (!context.mounted) {
          return;
        }
        _handleError(context, error);
      } finally {
        ref.invalidate(cartLinesProvider(line.orderId));
      }
    }

    Future<void> deleteLine() async {
      try {
        await controller.deleteLine(line.id);
      } on Object catch (error, _) {
        if (!context.mounted) {
          return;
        }
        _handleError(context, error);
      } finally {
        ref.invalidate(cartLinesProvider(line.orderId));
      }
    }

    final intl.NumberFormat currency =
        intl.NumberFormat.currency(symbol: '₪', decimalDigits: 2);
    final Widget qtyStepper = AQtyStepper(
      key: ValueKey<String>('cart_qty_stepper_${line.rowId}'),
      qty: line.qty,
      min: 1,
      step: 1,
      enabled: !notInCatalog,
      onChanged: (value) => unawaited(updateQuantity(value)),
    );

    final Widget totalTag = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          currency.format(line.unitPrice),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AColors.foreground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${currency.format(line.unitPrice)} × ${line.qty.toStringAsFixed(0)} = ${currency.format(line.lineTotal)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AColors.mutedForeground,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ],
    );

    final Widget deleteButton = IconButton(
      tooltip: removeTooltip,
      onPressed: deleteLine,
      icon: const Icon(Icons.delete_outline),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: ASpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: ARadii.md),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AColors.surfaceMuted,
                    borderRadius: ARadii.sm,
                    border: Border.all(color: AColors.cardBorder),
                  ),
                  child:
                      const Icon(Icons.inventory_2, color: AColors.neutral600),
                ),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.displayTitle,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: $skuLabel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AColors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (line.variantLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          line.variantLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AColors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (notInCatalog) ...[
                        const SizedBox(height: 6),
                        Chip(
                          key: ValueKey<String>(
                            'cart_row_not_in_catalog_${line.variantId}',
                          ),
                          label: Text(
                            notInCatalogLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          avatar: Icon(
                            Icons.warning_amber_rounded,
                            color: theme.colorScheme.error,
                            size: 16,
                          ),
                          backgroundColor: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.2),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: ASpacing.md),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      totalTag,
                      const SizedBox(height: 8),
                      _CartLineEffectivePrice(
                        line: line,
                        companyId: pricingCompanyId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.md),
            Row(
              children: [
                qtyStepper,
                const Spacer(),
                deleteButton,
              ],
            ),
            if (notInCatalog)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextButton.icon(
                  onPressed: () async {
                    try {
                      final String? rfqId = await _launchRfqRequest(
                        context,
                        ref,
                        <CartLine>[line],
                      );
                      if (!context.mounted || rfqId == null) {
                        return;
                      }
                      final String successMessage =
                          l10n?.translate('cartRequestAccessSuccess') ??
                              'בקשה נשלחה לספק.';
                      await _handleRfqResult(
                        navigator: navigator,
                        messenger: messenger,
                        ref: ref,
                        rfqId: rfqId,
                        successMessage: successMessage,
                      );
                    } on Object catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      final String message =
                          l10n?.translate('cartCreateQuoteError') ??
                              "Couldn't create request.";
                      messenger.showSnackBar(
                        SnackBar(content: Text('$message $error')),
                      );
                    }
                  },
                  icon: const Icon(Icons.outgoing_mail, size: 18),
                  label: Text(
                    l10n?.translate('cartRequestAccess') ?? 'בקש גישה',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LinePriceRequest {
  const _LinePriceRequest({
    required this.companyId,
    required this.variantId,
    required this.qty,
  });

  final String companyId;
  final String variantId;
  final double qty;

  @override
  bool operator ==(Object other) {
    return other is _LinePriceRequest &&
        other.companyId == companyId &&
        other.variantId == variantId &&
        (other.qty - qty).abs() < 1e-6;
  }

  @override
  int get hashCode => Object.hash(companyId, variantId, qty);
}

final _cartLinePriceProvider = FutureProvider.autoDispose
    .family<PriceResolution?, _LinePriceRequest>((ref, request) async {
  if (request.companyId.isEmpty) {
    return null;
  }
  final double safeQty = request.qty <= 0 ? 1 : request.qty;
  final svc = ref.read(priceResolutionServiceProvider);
  return svc.resolve(
    companyId: request.companyId,
    variantId: request.variantId,
    qty: safeQty,
  );
});

class _CartLineEffectivePrice extends ConsumerWidget {
  const _CartLineEffectivePrice({
    required this.line,
    required this.companyId,
  });

  final CartLine line;
  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ThemeData theme = Theme.of(context);
    final TextStyle baseLabelStyle = theme.textTheme.bodySmall ??
        theme.textTheme.bodyMedium ??
        const TextStyle();
    final TextStyle labelStyle = baseLabelStyle.copyWith(
      color: baseLabelStyle.color?.withValues(alpha: 0.72) ??
          theme.colorScheme.onSurface.withValues(alpha: 0.72),
    );
    final TextStyle valueStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
            baseLabelStyle.copyWith(fontWeight: FontWeight.w600);
    final String label =
        l10n?.translate('productEffectivePriceLabel') ?? 'Effective price';
    final String dashLabel = l10n?.translate('dash') ?? '—';
    final String contractLabel =
        l10n?.translate('contractPrice') ?? 'Contract price';

    final AsyncValue<PriceResolution?> priceAsync = companyId.isEmpty
        ? const AsyncValue<PriceResolution?>.data(null)
        : ref.watch(
            _cartLinePriceProvider(
              _LinePriceRequest(
                companyId: companyId,
                variantId: line.variantId,
                qty: line.qty,
              ),
            ),
          );

    Widget buildRow(Widget value) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stack =
              !constraints.hasBoundedWidth || constraints.maxWidth < 360;
          final double maxWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final Widget labelWidget = Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          );
          final Widget valueWidget = Align(
            alignment: stack
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: value,
          );
          if (stack) {
            final Widget column = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelWidget,
                const SizedBox(height: ASpacing.xs),
                valueWidget,
              ],
            );
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: column,
            );
          }
          final Widget row = Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: labelWidget),
              const SizedBox(width: ASpacing.sm),
              Flexible(child: valueWidget),
            ],
          );
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: row,
          );
        },
      );
    }

    return priceAsync.when(
      data: (PriceResolution? price) {
        final String valueText =
            price != null ? _formatPrice(price) : dashLabel;
        final List<Widget> columnChildren = <Widget>[
          buildRow(
            Text(
              valueText,
              key: ValueKey<String>('cart_line_price_${line.variantId}'),
              style: valueStyle,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ];
        if (price != null && price.source.toLowerCase() != 'base') {
          columnChildren
            ..add(const SizedBox(height: 4))
            ..add(
              ContractPriceBadge(
                key: ValueKey<String>(
                    'cart_line_contract_chip_${line.variantId}'),
                label: contractLabel,
              ),
            );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: columnChildren,
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildRow(
            const SizedBox(
              width: 96,
              child: ASkeleton(height: 16),
            ),
          ),
        ],
      ),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildRow(
            Text(
              dashLabel,
              key: ValueKey<String>('cart_line_price_${line.variantId}'),
              style: valueStyle,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(PriceResolution price) {
  try {
    final intl.NumberFormat formatter =
        intl.NumberFormat.currency(name: price.currency);
    return formatter.format(price.price);
  } catch (_) {
    return '${price.currency} ${price.price.toStringAsFixed(2)}';
  }
}

String _companyIdFromSession(Session? session) {
  final Object? raw = session?.user.appMetadata['company_id'];
  if (raw is String && raw.isNotEmpty) {
    return raw;
  }
  return '';
}

void _handleError(BuildContext context, Object error) {
  final MarketplaceLocalizations? l10n =
      Localizations.of<MarketplaceLocalizations>(
    context,
    MarketplaceLocalizations,
  );
  final String baseMessage =
      l10n?.translate('cartActionFailed') ?? 'Cart action failed.';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$baseMessage $error')),
  );
}

class _CartRecommendationsSection extends ConsumerWidget {
  const _CartRecommendationsSection({required this.request});

  final CatalogRecommendationRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<List<CatalogRecommendation>> recommendationsAsync =
        ref.watch(catalogRecommendationsProvider(request));

    return recommendationsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (Object _, StackTrace __) => const SizedBox.shrink(),
      data: (List<CatalogRecommendation> recommendations) {
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }
        final String title = l10n?.translate('cartRecommendationsTitle') ??
            'Complete your order';
        final String subtitle =
            l10n?.translate('cartRecommendationsSubtitle') ??
                'Products often ordered together';

        return Column(
          key: const ValueKey<String>('cart_recommendations_section'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ATypography.titleMd),
            const SizedBox(height: ASpacing.xs),
            Text(
              subtitle,
              style: ATypography.bodySm.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
            const SizedBox(height: ASpacing.md),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(width: ASpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  return _CartRecommendationCard(
                    recommendation: recommendations[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CartRecommendationCard extends ConsumerWidget {
  const _CartRecommendationCard({
    required this.recommendation,
  });

  final CatalogRecommendation recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final Locale locale = Localizations.localeOf(context);
    final String title =
        _recommendationDisplayName(recommendation.product, locale);
    final String reason = l10n?.translate(recommendation.reason.l10nKey) ??
        _fallbackRecommendationReason(recommendation.reason);
    final String addLabel = l10n?.translate('cartRecommendationsAdd') ?? 'Add';
    final String addedMessage =
        l10n?.translate('cartRecommendationsAdded') ?? 'Added to cart';

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AColors.neutral200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ASpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ASpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AColors.neutral100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              reason,
              style: ATypography.bodySm.copyWith(
                color: AColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ATypography.titleSm,
          ),
          const SizedBox(height: ASpacing.xs),
          Text(
            recommendation.product.sku,
            style: ATypography.bodySm.copyWith(
              color: AColors.mutedForeground,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(cartControllerProvider.notifier)
                      .addVariant(recommendation.variant);
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(addedMessage)));
                } on Object catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  _handleError(context, error);
                }
              },
              child: Text(addLabel),
            ),
          ),
        ],
      ),
    );
  }
}

String _recommendationDisplayName(Product product, Locale locale) {
  if (locale.languageCode == 'he') {
    return product.nameHe.isNotEmpty ? product.nameHe : product.nameEn;
  }
  return product.nameEn.isNotEmpty ? product.nameEn : product.nameHe;
}

String _fallbackRecommendationReason(CatalogRecommendationReason reason) {
  switch (reason) {
    case CatalogRecommendationReason.fastDelivery:
      return 'Fast delivery';
    case CatalogRecommendationReason.lowMoq:
      return 'Low MOQ';
    case CatalogRecommendationReason.smallPack:
      return 'Small pack';
    case CatalogRecommendationReason.defaultReason:
      return 'Suggested';
  }
}

bool _isLineNotInCatalog(
  String companyId,
  Set<String>? companyCatalog,
  CartLine line,
) {
  if (companyId.isEmpty || companyCatalog == null) {
    return false;
  }
  return !companyCatalog.contains(line.variantId);
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String emptyMessage =
        l10n?.translate('cartEmptyMessage') ?? 'Your cart is empty right now.';
    final String browseCatalogLabel =
        l10n?.translate('cartBrowseCatalog') ?? 'Back to catalog';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/catalog'),
              icon: const Icon(Icons.storefront),
              label: Text(browseCatalogLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartErrorState extends StatelessWidget {
  const _CartErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String retryLabel = l10n?.translate('commonRetry') ?? 'Try again';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTotalsFooter extends ConsumerStatefulWidget {
  const _CartTotalsFooter({required this.draftOrderId});

  final String draftOrderId;

  @override
  ConsumerState<_CartTotalsFooter> createState() => _CartTotalsFooterState();
}

class _CartTotalsFooterState extends ConsumerState<_CartTotalsFooter> {
  bool _creatingRfq = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CartLine>> linesAsync =
        ref.watch(cartLinesProvider(widget.draftOrderId));
    final bool isLoading = ref.watch(cartControllerProvider).isLoading;
    final String companyId = ref.watch(quickOrderCompanyIdProvider);
    final Set<String>? companyCatalog = companyId.isEmpty
        ? null
        : ref.watch(quickOrderCompanyCatalogProvider(companyId)).maybeWhen(
              data: (value) => value,
              orElse: () => null,
            );
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String proceedLabel =
        l10n?.translate('cartProceedToCheckout') ?? 'Proceed to checkout';
    final String missingDraftMessage =
        l10n?.translate('checkoutDraftMissing') ??
            'Cannot proceed without an active cart.';
    final String requestQuoteLabel =
        l10n?.translate('cartRequestQuote') ?? 'Request a quote';

    return linesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (List<CartLine> lines) {
        final double subtotal = lines.fold<double>(
          0,
          (double acc, CartLine line) => acc + line.subtotal,
        );
        final intl.NumberFormat currency =
            intl.NumberFormat.currency(symbol: '₪', decimalDigits: 2);
        final String subtotalLabel =
            l10n?.translate('subtotalShort') ?? 'Subtotal';
        final bool hasItems = lines.isNotEmpty;
        final int forbiddenCount = lines
            .where(
              (CartLine line) =>
                  _isLineNotInCatalog(companyId, companyCatalog, line),
            )
            .length;
        final bool hasForbidden = forbiddenCount > 0;
        return SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$subtotalLabel: ${currency.format(subtotal)}',
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              const SizedBox(height: 8),
              KeyedSubtree(
                key: const ValueKey('checkout_submit_btn'),
                child: AButton.primary(
                  key: const ValueKey('cart_checkout_btn'),
                  expand: true,
                  label: proceedLabel,
                  icon: const Icon(Icons.local_shipping_outlined),
                  onPressed: (!hasItems || isLoading || hasForbidden)
                      ? null
                      : () {
                          final ScaffoldMessengerState messenger =
                              ScaffoldMessenger.of(context);
                          if (widget.draftOrderId.isEmpty) {
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(content: Text(missingDraftMessage)),
                            );
                            return;
                          }
                          context.push(
                            '/customer/cart/checkout',
                            extra: widget.draftOrderId,
                          );
                        },
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: !hasItems || _creatingRfq
                    ? null
                    : () => _openRfqDialog(context, lines),
                icon: _creatingRfq
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.request_quote_outlined),
                label: Text(
                  requestQuoteLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openRfqDialog(
      BuildContext context, List<CartLine> lines) async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    setState(() {
      _creatingRfq = true;
    });
    try {
      final String? rfqId = await _launchRfqRequest(context, ref, lines);
      if (!mounted || rfqId == null) {
        return;
      }
      final String successMessage = l10n?.translate('cartCreateQuoteSuccess') ??
          'Request sent to vendors.';
      await _handleRfqResult(
        navigator: navigator,
        messenger: messenger,
        ref: ref,
        rfqId: rfqId,
        successMessage: successMessage,
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n?.translate('cartCreateQuoteError') ?? "Couldn't create request."} $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _creatingRfq = false;
        });
      }
    }
  }
}
