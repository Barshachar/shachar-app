import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/auth/debug_auth_sheet.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';
import 'package:ashachar_marketplace/src/features/promotions/presentation/widgets/premium_promotions_banner.dart';

class CustomerHomePage extends ConsumerWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<Session?> session = ref.watch(sessionControllerProvider);
    final Session? sessionValue = session.asData?.value;
    final bool isAuthenticated = sessionValue != null;
    final bool debugFeaturesEnabled = ref.watch(debugFeaturesEnabledProvider);
    final CartState cartState = ref.watch(cartControllerProvider);
    final String? draftOrderId = cartState.draftOrderId;
    final AsyncValue<List<CartLine>> cartLinesAsync = (draftOrderId == null)
        ? const AsyncData(<CartLine>[])
        : ref.watch(cartLinesProvider(draftOrderId));
    final AsyncValue<List<OrderSummary>> recentOrdersAsync =
        ref.watch(recentOrdersPreviewProvider);

    final Locale locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('he', 'IL');
    final NumberFormat currencyFormat = NumberFormat.simpleCurrency(
      locale: locale.toLanguageTag(),
    );

    final String greeting = l10n?.translate('homeGreeting') ?? 'ברוך שובך!';
    final String subtitle =
        l10n?.translate('homeGreetingSubtitle') ?? 'מה נרצה לעשות היום?';
    final String searchPlaceholder =
        l10n?.translate('homeSearchPlaceholder') ?? 'חפש מוצרים';
    final String searchTooltip =
        l10n?.translate('homeSearchTooltip') ?? 'חיפוש';
    final String menuTooltip = l10n?.translate('homeMenuTooltip') ?? 'תפריט';
    final String campaignTitle =
        l10n?.translate('homeCampaignTitle') ?? 'מבצעים 2025';
    final String campaignSubtitle = l10n?.translate('homeCampaignSubtitle') ??
        'חסכון בלעדי ללקוחות חוזרים.';
    final String campaignCta =
        l10n?.translate('homeCampaignCta') ?? 'למוצרים משתתפים';
    final String campaignBadge =
        l10n?.translate('homeCampaignBadge') ?? 'מועדון פרימיום';
    final String campaignHighlight =
        l10n?.translate('homeCampaignHighlight') ?? 'עד 40% הנחה';
    final String currentOrderTitle =
        l10n?.translate('homeCurrentOrderTitle') ?? 'הזמנה נוכחית';
    final String currentOrderEmpty = l10n?.translate('homeCurrentOrderEmpty') ??
        'אין טיוטת הזמנה פעילה כרגע.';
    final String currentOrderLoading =
        l10n?.translate('homeCurrentOrderLoading') ?? 'טוען טיוטה...';
    final String currentOrderValueLabel =
        l10n?.translate('homeCurrentOrderValue') ?? 'שווי הזמנה';
    final String continueOrderLabel =
        l10n?.translate('homeContinueOrder') ?? 'המשך להזמנה';
    final String itemsLabel =
        l10n?.translate('homeCurrentOrderItems') ?? '{count} פריטים';
    final String homeTitle = l10n?.translate('homeTitle') ?? 'בית לקוחות';
    final String signOutLabel = l10n?.translate('signOut') ?? 'התנתקות';
    final String signInSwitchLabel =
        l10n?.translate('signInSwitchUser') ?? 'התחברות / החלפת משתמש';
    final String reorderTitle =
        l10n?.translate('homeReorderTitle') ?? 'הזמנה חוזרת';
    final String savedListsShortcutLabel =
        l10n?.translate('homeSavedListsShortcut') ?? 'רשימות שמורות';
    final String viewAllOrdersLabel =
        l10n?.translate('homeViewAllOrders') ?? 'כל ההזמנות';

    final List<_HomeShortcutConfig> shortcuts = <_HomeShortcutConfig>[
      _HomeShortcutConfig(
        keyValue: 'home_menu_promotions',
        icon: Icons.local_offer_outlined,
        label: l10n?.translate('homeTilePromotions') ?? 'מבצעים',
        description: l10n?.translate('homeTilePromotionsDescription') ??
            'חבילות והטבות במיוחד בשבילך',
        onTap: () => context.go('/promotions'),
      ),
      _HomeShortcutConfig(
        keyValue: 'home_menu_catalog',
        icon: Icons.storefront_outlined,
        label: l10n?.translate('homeTileCatalog') ?? 'קטלוג',
        description: l10n?.translate('homeTileCatalogDescription') ??
            'סיור בין כל המוצרים',
        onTap: () => context.go('/catalog'),
      ),
      _HomeShortcutConfig(
        keyValue: 'home_menu_quick_order',
        icon: Icons.flash_on_outlined,
        label: l10n?.translate('homeTileQuickOrder') ?? 'הזמנה מהירה',
        description: l10n?.translate('homeTileQuickOrderDescription') ??
            'הוספה מרוכזת ללקוחות חוזרים',
        onTap: () => context.go('/catalog/quick-order'),
      ),
      _HomeShortcutConfig(
        keyValue: 'home_menu_cart',
        icon: Icons.shopping_cart_outlined,
        label: l10n?.translate('homeTileCart') ?? 'סל הזמנה',
        description: l10n?.translate('homeTileCartDescription') ??
            'טיוטת ההזמנה הנוכחית',
        onTap: () => context.go('/customer/cart'),
      ),
      _HomeShortcutConfig(
        keyValue: 'home_menu_orders',
        icon: Icons.receipt_long_outlined,
        label: l10n?.translate('homeTileOrders') ?? 'הזמנות שלי',
        description: l10n?.translate('homeTileOrdersDescription') ??
            'מעקב אחרי סטטוסים ומשלוחים',
        onTap: () => context.go('/customer/orders'),
      ),
      _HomeShortcutConfig(
        keyValue: 'home_menu_approvals',
        icon: Icons.verified_outlined,
        label: l10n?.translate('homeTileApprovals') ?? 'אישורים',
        description: l10n?.translate('homeTileApprovalsDescription') ??
            'בקשות ממתינות לאישור',
        onTap: () => context.go('/customer/approvals'),
      ),
      _HomeShortcutConfig(
        keyValue: 'home_menu_cashback',
        icon: Icons.savings_outlined,
        label: l10n?.translate('homeTileCashback') ?? 'הזיכויים שלי',
        description: l10n?.translate('homeTileCashbackDescription') ??
            'צבירת זיכויים על כל הזמנה',
        onTap: () => context.go('/finance/cashback'),
      ),
    ];

    return Scaffold(
      key: const ValueKey('customer_home_root'),
      backgroundColor: AColors.background,
      drawer: const _HomePlaceholderDrawer(),
      appBar: AppBar(
        backgroundColor: AColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext leadingContext) {
            return IconButton(
              icon: const Icon(Icons.menu),
              tooltip: menuTooltip,
              onPressed: () => Scaffold.of(leadingContext).openDrawer(),
            );
          },
        ),
        title: Text(
          homeTitle,
          style: ATypography.titleSm.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: searchTooltip,
            onPressed: () => context.go('/catalog/search'),
          ),
          IconButton(
            key: debugFeaturesEnabled
                ? const ValueKey('debug_entrypoint')
                : null,
            icon: Icon(isAuthenticated ? Icons.logout : Icons.login),
            tooltip: isAuthenticated ? signOutLabel : signInSwitchLabel,
            onPressed: isAuthenticated
                ? () async {
                    try {
                      await ref
                          .read(sessionControllerProvider.notifier)
                          .signOut();
                      if (context.mounted) {
                        context.go('/home');
                      }
                    } catch (_) {}
                  }
                : () {
                    if (debugFeaturesEnabled) {
                      showDebugAuthSheet(context, ref);
                    } else {
                      context.go('/login');
                    }
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 360;
            return SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                start: ASpacing.page,
                end: ASpacing.page,
                top: ASpacing.lg,
                bottom: ASpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroBanner(
                    greeting: greeting,
                    subtitle: subtitle,
                    searchPlaceholder: searchPlaceholder,
                    onSearchTap: () => context.go('/catalog/search'),
                  ),
                  ASpacing.gapRow(ASpacing.lg),
                  PremiumPromotionsBanner(
                    title: campaignTitle,
                    subtitle: campaignSubtitle,
                    cta: campaignCta,
                    badgeLabel: campaignBadge,
                    highlight: campaignHighlight,
                    onTap: () => context.go('/promotions'),
                  ),
                  ASpacing.gapRow(ASpacing.lg),
                  _ReorderShortcuts(
                    title: reorderTitle,
                    ordersAsync: recentOrdersAsync,
                    quickOrderLabel:
                        l10n?.translate('homeTileQuickOrder') ?? 'הזמנה מהירה',
                    savedListsLabel: savedListsShortcutLabel,
                    viewAllLabel: viewAllOrdersLabel,
                    currencyFormat: currencyFormat,
                    onQuickOrderTap: () => context.go('/catalog/quick-order'),
                    onSavedListsTap: () => context.go('/customer/lists'),
                    onOrderTap: (String id) =>
                        context.go('/customer/orders/$id'),
                    onViewAllOrders: () => context.go('/customer/orders'),
                  ),
                  ASpacing.gapRow(ASpacing.lg),
                  _CurrentOrderCard(
                    title: currentOrderTitle,
                    valueLabel: currentOrderValueLabel,
                    itemsLabelTemplate: itemsLabel,
                    emptyLabel: currentOrderEmpty,
                    loadingLabel: currentOrderLoading,
                    currencyFormat: currencyFormat,
                    linesAsync: cartLinesAsync,
                    onPrimaryAction: () => context.go('/customer/cart'),
                    continueLabel: continueOrderLabel,
                  ),
                  ASpacing.gapRow(ASpacing.xl),
                  _ShortcutGrid(shortcuts: shortcuts, compact: compact),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.greeting,
    required this.subtitle,
    required this.searchPlaceholder,
    required this.onSearchTap,
  });

  final String greeting;
  final String subtitle;
  final String searchPlaceholder;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AColors.primary,
        borderRadius: ARadii.lg,
        boxShadow: AElevation.shadowSoft,
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(
        ASpacing.xl,
        ASpacing.xl,
        ASpacing.xl,
        ASpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: ATypography.headline2.copyWith(color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            subtitle,
            style: ATypography.bodySm.copyWith(color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: ASpacing.lg),
          InkWell(
            key: const ValueKey('home_search_bar'),
            borderRadius: ARadii.pill,
            onTap: onSearchTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: ARadii.pill,
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: ASpacing.lg,
                vertical: ASpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: AColors.mutedForeground, size: 20),
                  const SizedBox(width: ASpacing.sm),
                  Expanded(
                    child: Text(
                      searchPlaceholder,
                      style: ATypography.bodySm.copyWith(
                        color: AColors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(width: ASpacing.sm),
                  Icon(
                    context.isRtl ? Icons.chevron_left : Icons.chevron_right,
                    color: AColors.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentOrderCard extends StatelessWidget {
  const _CurrentOrderCard({
    required this.title,
    required this.valueLabel,
    required this.itemsLabelTemplate,
    required this.emptyLabel,
    required this.loadingLabel,
    required this.currencyFormat,
    required this.linesAsync,
    required this.onPrimaryAction,
    required this.continueLabel,
  });

  final String title;
  final String valueLabel;
  final String itemsLabelTemplate;
  final String emptyLabel;
  final String loadingLabel;
  final NumberFormat currencyFormat;
  final AsyncValue<List<CartLine>> linesAsync;
  final VoidCallback onPrimaryAction;
  final String continueLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('home_current_order_card'),
      decoration: BoxDecoration(
        color: AColors.primaryDark,
        borderRadius: ARadii.lg,
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(
        ASpacing.xl,
        ASpacing.xl,
        ASpacing.xl,
        ASpacing.lg,
      ),
      child: linesAsync.when(
        loading: () => _OrderCardContent(
          title: title,
          subtitle: loadingLabel,
          valueLabel: valueLabel,
          value: '--',
          itemsLabel: '--',
          onPrimaryAction: null,
          primaryLabel: continueLabel,
        ),
        error: (_, __) => _OrderCardContent(
          title: title,
          subtitle: emptyLabel,
          valueLabel: valueLabel,
          value: '--',
          itemsLabel: '--',
          onPrimaryAction: onPrimaryAction,
          primaryLabel: continueLabel,
        ),
        data: (List<CartLine> lines) {
          if (lines.isEmpty) {
            return _OrderCardContent(
              title: title,
              subtitle: emptyLabel,
              valueLabel: valueLabel,
              value: currencyFormat.format(0),
              itemsLabel: itemsLabelTemplate.replaceAll('{count}', '0'),
              onPrimaryAction: onPrimaryAction,
              primaryLabel: continueLabel,
            );
          }
          final int itemCount = lines.length;
          final double total = lines.fold<double>(
            0,
            (double running, CartLine line) => running + line.lineTotal,
          );
          final String valueText = currencyFormat.format(total);
          final String itemsText = itemsLabelTemplate.replaceAll(
            '{count}',
            itemCount.toString(),
          );
          return _OrderCardContent(
            title: title,
            subtitle: itemsText,
            valueLabel: valueLabel,
            value: valueText,
            itemsLabel: itemsText,
            onPrimaryAction: onPrimaryAction,
            primaryLabel: continueLabel,
          );
        },
      ),
    );
  }
}

class _OrderCardContent extends StatelessWidget {
  const _OrderCardContent({
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.value,
    required this.itemsLabel,
    required this.primaryLabel,
    required this.onPrimaryAction,
  });

  final String title;
  final String subtitle;
  final String valueLabel;
  final String value;
  final String itemsLabel;
  final String primaryLabel;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ATypography.titleSm.copyWith(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: ASpacing.sm),
        Text(
          subtitle,
          style: ATypography.bodySm.copyWith(color: Colors.white70),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: ASpacing.lg),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueLabel,
                    style: ATypography.bodySm.copyWith(color: Colors.white60),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: ASpacing.xs),
                  Text(
                    value,
                    style: ATypography.titleMd.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: ASpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemsLabel,
                    style: ATypography.bodySm.copyWith(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: ASpacing.sm),
                  AButton.secondary(
                    key: const ValueKey('home_continue_order_btn'),
                    expand: true,
                    label: primaryLabel,
                    onPressed: onPrimaryAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.shortcuts, required this.compact});

  final List<_HomeShortcutConfig> shortcuts;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final int columnCount = compact ? 2 : 3;
    final double spacing = compact ? ASpacing.md : ASpacing.lg;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final double tileWidth =
            (maxWidth - spacing * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: shortcuts
              .map(
                (config) => SizedBox(
                  width: tileWidth,
                  child: _HomeShortcutTile(config: config),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ReorderShortcuts extends StatelessWidget {
  const _ReorderShortcuts({
    required this.title,
    required this.ordersAsync,
    required this.quickOrderLabel,
    required this.savedListsLabel,
    required this.viewAllLabel,
    required this.currencyFormat,
    required this.onQuickOrderTap,
    required this.onSavedListsTap,
    required this.onOrderTap,
    required this.onViewAllOrders,
  });

  final String title;
  final AsyncValue<List<OrderSummary>> ordersAsync;
  final String quickOrderLabel;
  final String savedListsLabel;
  final String viewAllLabel;
  final NumberFormat currencyFormat;
  final VoidCallback onQuickOrderTap;
  final VoidCallback onSavedListsTap;
  final ValueChanged<String> onOrderTap;
  final VoidCallback onViewAllOrders;

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ordersAsync.isLoading;
    final List<OrderSummary> orders =
        ordersAsync.asData?.value ?? const <OrderSummary>[];
    if (isLoading && orders.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> chips = <Widget>[
      ActionChip(
        key: const ValueKey('home_quick_order_chip'),
        avatar: const Icon(Icons.flash_on_outlined, size: 18),
        label: Text(quickOrderLabel),
        onPressed: onQuickOrderTap,
      ),
      ActionChip(
        key: const ValueKey('home_saved_lists_chip'),
        avatar: const Icon(Icons.bookmark_outline, size: 18),
        label: Text(savedListsLabel),
        onPressed: onSavedListsTap,
      ),
      for (final OrderSummary order in orders.take(3))
        ActionChip(
          key: ValueKey<String>('home_reorder_order_${order.id}'),
          avatar: const Icon(Icons.refresh_outlined, size: 18),
          label: Text(
            '${order.orderNumber} · ${currencyFormat.format(order.total)}',
          ),
          onPressed: () => onOrderTap(order.id),
        ),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: ARadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ATypography.titleSm),
            const SizedBox(height: ASpacing.sm),
            Wrap(
              spacing: ASpacing.sm,
              runSpacing: ASpacing.sm,
              children: chips,
            ),
            if (orders.isNotEmpty) ...[
              const SizedBox(height: ASpacing.sm),
              TextButton.icon(
                key: const ValueKey('home_view_all_orders_btn'),
                onPressed: onViewAllOrders,
                icon: const Icon(Icons.list_alt_outlined, size: 18),
                label: Text(viewAllLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeShortcutTile extends StatelessWidget {
  const _HomeShortcutTile({required this.config});

  final _HomeShortcutConfig config;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey(config.keyValue),
      borderRadius: ARadii.md,
      onTap: config.onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: ASpacing.interactive),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ARadii.md,
          border: Border.all(color: AColors.borderSubtle),
          boxShadow: AElevation.shadowSoft,
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(
          ASpacing.lg,
          ASpacing.lg,
          ASpacing.lg,
          ASpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AColors.primaryMuted,
                borderRadius: ARadii.sm,
              ),
              padding: const EdgeInsets.all(ASpacing.sm),
              child: Icon(config.icon, color: AColors.primaryDark, size: 22),
            ),
            const SizedBox(height: ASpacing.md),
            Text(
              config.label,
              style: ATypography.titleSm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: ASpacing.xs),
            Text(
              config.description,
              style: ATypography.bodySm,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeShortcutConfig {
  const _HomeShortcutConfig({
    required this.keyValue,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final String keyValue;
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
}

class _HomePlaceholderDrawer extends StatelessWidget {
  const _HomePlaceholderDrawer();

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    final String profileLabel = l10n?.translate('profile') ?? 'הפרופיל שלי';
    final String settingsLabel = l10n?.translate('settings') ?? 'הגדרות';
    final String helpLabel = l10n?.translate('help') ?? 'עזרה';
    final String aboutLabel = l10n?.translate('about') ?? 'אודות';

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(ASpacing.xl),
              decoration: BoxDecoration(
                color: AColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: ASpacing.md),
                  Text(
                    'SuperMart Chain',
                    style: ATypography.titleMd.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: ASpacing.xs),
                  Text(
                    'buyer1@demo.local',
                    style: ATypography.bodySm.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.all(ASpacing.md),
                children: [
                  ListTile(
                    leading: const Icon(Icons.local_offer_outlined),
                    title:
                        Text(l10n?.translate('homeTilePromotions') ?? 'מבצעים'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/promotions');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(l10n?.translate('homeTileCatalog') ?? 'קטלוג'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/catalog');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart_outlined),
                    title: Text(l10n?.translate('homeTileCart') ?? 'סל הזמנה'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customer/cart');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title:
                        Text(l10n?.translate('homeTileOrders') ?? 'הזמנות שלי'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customer/orders');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title:
                        Text(l10n?.translate('homeTileApprovals') ?? 'אישורים'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customer/approvals');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(profileLabel),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customer/profile');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(settingsLabel),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customer/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(helpLabel),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/customer/help');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(aboutLabel),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$aboutLabel - בקרוב')),
                      );
                    },
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

final recentOrdersPreviewProvider =
    FutureProvider.autoDispose<List<OrderSummary>>((ref) async {
  final OrdersRepository repository = ref.watch(ordersRepositoryProvider);
  final List<OrderSummary> orders = await repository.fetchOrders();
  if (orders.length <= 3) {
    return orders;
  }
  return orders.take(3).toList();
});
