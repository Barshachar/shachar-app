import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/async_value_x.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<Session?> sessionState =
        ref.watch(sessionControllerProvider);
    final bool isAuthenticated = sessionState.valueOrNull != null;
    final String signOutLabel = l10n?.translate('signOut') ?? 'Sign out';
    final String signInLabel = l10n?.translate('authSignIn') ?? 'Sign in';
    final Color actionColor = Theme.of(context).colorScheme.onPrimary;

    final String pageTitle =
        l10n?.translate('adminDashboardTitle') ?? 'Admin dashboard';
    final String overviewHeading =
        l10n?.translate('adminDashboardOverviewHeading') ?? 'Business overview';
    final String quickActionsHeading =
        l10n?.translate('adminDashboardQuickActionsHeading') ?? 'Quick actions';
    final String signalsHeading =
        l10n?.translate('adminDashboardSignalsHeading') ??
            'Operational signals';
    final String usersCta =
        l10n?.translate('adminDashboardUsersCta') ?? 'Manage users';
    final String usersDescription =
        l10n?.translate('adminDashboardUsersDescription') ??
            'Invite admins and manage access controls';
    final String supportCta =
        l10n?.translate('adminDashboardSupportCta') ?? 'Open support inbox';
    final String supportDescription =
        l10n?.translate('adminDashboardSupportDescription') ??
            'Track escalations and SLA breaches';
    final String taxCta = l10n?.translate('adminDashboardTaxSettingsCta') ??
        'Configure tax rules';
    final String taxDescription =
        l10n?.translate('adminDashboardTaxSettingsDescription') ??
            'VAT, exemptions, export profiles';
    final String auditCta =
        l10n?.translate('adminDashboardAuditLogCta') ?? 'Review audit log';
    final String auditDescription =
        l10n?.translate('adminDashboardAuditLogDescription') ??
            'Latest configuration changes & impersonations';
    final String vendorsCta =
        l10n?.translate('adminDashboardVendorsCta') ?? 'Manage vendor queue';
    final String vendorsDescription =
        l10n?.translate('adminDashboardVendorsDescription') ??
            'Approve or reject onboarding requests';
    final String supportAlertsTitle =
        l10n?.translate('adminDashboardSupportAlerts') ?? 'Support alerts';
    final String complianceAlertsTitle =
        l10n?.translate('adminDashboardComplianceAlerts') ??
            'Compliance & approvals';
    final String notesLabel = l10n?.translate('adminDashboardNotes') ??
        'Demo metrics for illustration purposes only.';

    final List<_OverviewStat> overview = <_OverviewStat>[
      _OverviewStat(
        label: l10n?.translate('adminDashboardTotalGmv') ?? 'Total GMV',
        value: '₪1.2M',
        trend: l10n?.translate('adminDashboardTotalGmvTrend') ??
            '+12.4% vs. last month',
        trendPositive: true,
        icon: Icons.trending_up,
      ),
      _OverviewStat(
        label:
            l10n?.translate('adminDashboardActiveVendors') ?? 'Active Vendors',
        value: '5',
        trend: l10n?.translate('adminDashboardActiveVendorsTrend') ??
            '2 onboarding right now',
        trendPositive: true,
        icon: Icons.storefront_outlined,
      ),
      _OverviewStat(
        label:
            l10n?.translate('adminDashboardApprovals') ?? 'Pending Approvals',
        value: '2',
        trend: l10n?.translate('adminDashboardApprovalsTrend') ??
            'SLA 3h remaining',
        trendPositive: false,
        icon: Icons.verified_user_outlined,
      ),
    ];

    final List<_QuickAction> quickActions = <_QuickAction>[
      _QuickAction(
        label: usersCta,
        description: usersDescription,
        icon: Icons.group_add_outlined,
        destination: '/admin/users',
      ),
      _QuickAction(
        label: supportCta,
        description: supportDescription,
        icon: Icons.headset_mic_outlined,
        destination: '/admin/support',
      ),
      _QuickAction(
        label: taxCta,
        description: taxDescription,
        icon: Icons.receipt_long_outlined,
        destination: '/admin/settings',
      ),
      _QuickAction(
        label: auditCta,
        description: auditDescription,
        icon: Icons.search_outlined,
        destination: '/admin/audit-log',
      ),
      _QuickAction(
        label: vendorsCta,
        description: vendorsDescription,
        icon: Icons.assignment_turned_in_outlined,
        destination: '/admin/vendor-queue',
      ),
      _QuickAction(
        label: l10n?.translate('adminDashboardCashbackCta') ?? 'Cashback',
        description: l10n?.translate('adminDashboardCashbackDescription') ??
            'Balances, liability and adjustments',
        icon: Icons.savings_outlined,
        destination: '/admin/cashback',
      ),
    ];

    final List<_InsightItem> highPriorityTickets = <_InsightItem>[
      _InsightItem(
        title: l10n?.translate('adminDashboardSupportAlert1Title') ??
            '#2034 Login Issue',
        subtitle: l10n?.translate('adminDashboardSupportAlert1Subtitle') ??
            'SLA breach in 12m • Assigned to Support Team',
        indicatorColor: AColors.danger,
      ),
      _InsightItem(
        title: l10n?.translate('adminDashboardSupportAlert2Title') ??
            '#2033 Order Not Delivered',
        subtitle: l10n?.translate('adminDashboardSupportAlert2Subtitle') ??
            'Escalated to Logistics • ETA 4h',
        indicatorColor: AColors.warning,
      ),
    ];

    final List<_InsightItem> complianceAlerts = <_InsightItem>[
      _InsightItem(
        title: l10n?.translate('adminDashboardComplianceAlert1Title') ??
            '2 approval requests awaiting admin review',
        subtitle: l10n?.translate('adminDashboardComplianceAlert1Subtitle') ??
            'Net 60 override • Vendor onboarding',
        indicatorColor: AColors.warning,
      ),
      _InsightItem(
        title: l10n?.translate('adminDashboardComplianceAlert2Title') ??
            '1 tax rule expiring this month',
        subtitle: l10n?.translate('adminDashboardComplianceAlert2Subtitle') ??
            'IL Non-profit exemption – refresh required',
        indicatorColor: AColors.primary,
      ),
    ];

    return Scaffold(
      backgroundColor: AColors.background,
      appBar: AppBar(
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
        title: Text(pageTitle),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: TextButton.icon(
              onPressed: () async {
                if (isAuthenticated) {
                  try {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  } catch (error) {
                    debugPrint('[AUTH_FLOW] logout=fail error=$error');
                  }
                } else {
                  context.go('/login');
                }
              },
              icon: Icon(
                isAuthenticated ? Icons.logout : Icons.login,
                color: actionColor,
                size: 18,
              ),
              label: Text(
                isAuthenticated ? signOutLabel : signInLabel,
                style: ATypography.bodySm.copyWith(color: actionColor),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 720;
          final EdgeInsets padding = const EdgeInsets.symmetric(
            horizontal: ASpacing.page,
            vertical: ASpacing.lg,
          );
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(overviewHeading, style: ATypography.titleMd),
                const SizedBox(height: ASpacing.md),
                Wrap(
                  spacing: ASpacing.md,
                  runSpacing: ASpacing.md,
                  children: overview
                      .map((stat) => _OverviewCard(stat: stat))
                      .toList(),
                ),
                const SizedBox(height: ASpacing.xl),
                Text(quickActionsHeading, style: ATypography.titleMd),
                const SizedBox(height: ASpacing.md),
                Wrap(
                  spacing: ASpacing.md,
                  runSpacing: ASpacing.md,
                  children: quickActions
                      .map((action) => _QuickActionCard(action: action))
                      .toList(),
                ),
                const SizedBox(height: ASpacing.xl),
                Text(signalsHeading, style: ATypography.titleMd),
                const SizedBox(height: ASpacing.md),
                Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: wide ? 1 : 0,
                      child: _InsightCard(
                        title: supportAlertsTitle,
                        items: highPriorityTickets,
                      ),
                    ),
                    if (wide)
                      const SizedBox(width: ASpacing.md)
                    else
                      const SizedBox(height: ASpacing.md),
                    Expanded(
                      flex: wide ? 1 : 0,
                      child: _InsightCard(
                        title: complianceAlertsTitle,
                        items: complianceAlerts,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ASpacing.xl),
                Text(notesLabel, style: ATypography.bodySm),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewStat {
  const _OverviewStat({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    this.trendPositive = true,
  });

  final String label;
  final String value;
  final String trend;
  final bool trendPositive;
  final IconData icon;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.stat});

  final _OverviewStat stat;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color trendColor =
        stat.trendPositive ? AColors.success : AColors.warning;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      child: Container(
        decoration: BoxDecoration(
          color: AColors.surface,
          borderRadius: ARadii.lg,
          boxShadow: AElevation.shadowSoft,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ASpacing.lg,
          vertical: ASpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    stat.label,
                    style: ATypography.bodyLg,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(stat.icon, size: 20, color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.lg),
            Text(
              stat.value,
              style: ATypography.headline1.copyWith(fontSize: 26),
            ),
            const SizedBox(height: ASpacing.sm),
            Text(
              stat.trend,
              style: ATypography.bodySm.copyWith(color: trendColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.description,
    required this.icon,
    required this.destination,
  });

  final String label;
  final String description;
  final IconData icon;
  final String destination;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      child: InkWell(
        onTap: () => context.go(action.destination),
        borderRadius: ARadii.md,
        child: Container(
          decoration: BoxDecoration(
            color: AColors.surface,
            borderRadius: ARadii.md,
            border: Border.all(color: AColors.cardBorder),
          ),
          padding: const EdgeInsets.all(ASpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(action.icon, color: AColors.primary),
                  const SizedBox(width: ASpacing.sm),
                  Expanded(
                    child: Text(
                      action.label,
                      style: ATypography.bodyLg,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AColors.mutedForeground,
                  ),
                ],
              ),
              const SizedBox(height: ASpacing.sm),
              Text(
                action.description,
                style: ATypography.bodySm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightItem {
  const _InsightItem({
    required this.title,
    required this.subtitle,
    required this.indicatorColor,
  });

  final String title;
  final String subtitle;
  final Color indicatorColor;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_InsightItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ASpacing.md),
      decoration: BoxDecoration(
        color: AColors.surface,
        borderRadius: ARadii.lg,
        boxShadow: AElevation.shadowSoft,
      ),
      padding: const EdgeInsets.all(ASpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ATypography.bodyLg),
          const SizedBox(height: ASpacing.sm),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: ASpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: item.indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: ASpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: ATypography.bodyMd.copyWith(
                            color: AColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: ATypography.bodySm,
                        ),
                      ],
                    ),
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
