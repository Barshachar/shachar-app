import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/core/errors/user_friendly_error_handler.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/customer/data/customer_company_profile_repository.dart';
import 'package:ashachar_marketplace/src/features/customer/domain/customer_company_profile.dart';

final customerCompanyProfileProvider =
    FutureProvider.autoDispose.family<CustomerCompanyProfile, String?>(
  (ref, String? companyId) async {
    final profileAsync = ref.watch(userProfileProvider);
    final String? fallbackCompanyId = profileAsync.asData?.value?.companyId;
    final CustomerCompanyProfileRepository repository =
        ref.watch(customerCompanyProfileRepositoryProvider);
    return repository.fetchProfile(
      companyId: companyId ?? fallbackCompanyId,
    );
  },
);

class CustomerCompanyProfilePage extends ConsumerWidget {
  const CustomerCompanyProfilePage({super.key, this.companyId});

  final String? companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title =
        l10n?.translate('customerCompanyProfileTitle') ?? 'Customer Profile';
    final String overviewLabel =
        l10n?.translate('customerCompanyProfileTabOverview') ?? 'Overview';
    final String ordersLabel =
        l10n?.translate('customerCompanyProfileTabOrders') ?? 'Orders';
    final String quotesLabel =
        l10n?.translate('customerCompanyProfileTabQuotes') ?? 'Quotes';
    final String creditLabel =
        l10n?.translate('customerCompanyProfileTabCredit') ?? 'Credit';
    final String contractsLabel =
        l10n?.translate('customerCompanyProfileTabContracts') ?? 'Contracts';
    final String comingSoon =
        l10n?.translate('customerCompanyProfileComingSoon') ?? 'Coming soon';

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AColors.primary,
          foregroundColor: Colors.white,
          title: Text(title),
          bottom: TabBar(
            indicatorColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(text: overviewLabel),
              Tab(text: ordersLabel),
              Tab(text: quotesLabel),
              Tab(text: creditLabel),
              Tab(text: contractsLabel),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(companyId: companyId),
            _PlaceholderTab(label: ordersLabel, comingSoon: comingSoon),
            _PlaceholderTab(label: quotesLabel, comingSoon: comingSoon),
            _PlaceholderTab(label: creditLabel, comingSoon: comingSoon),
            _PlaceholderTab(label: contractsLabel, comingSoon: comingSoon),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.companyId});

  final String? companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String errorMessage =
        l10n?.translate('customerCompanyProfileLoadError') ??
            'Unable to load profile';
    final AsyncValue<CustomerCompanyProfile> profileAsync =
        ref.watch(customerCompanyProfileProvider(companyId));

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Text(
          error.userFriendlyMessage.isEmpty
              ? errorMessage
              : error.userFriendlyMessage,
          textAlign: TextAlign.center,
        ),
      ),
      data: (CustomerCompanyProfile profile) {
        return ListView(
          padding: const EdgeInsets.all(ASpacing.xl),
          children: [
            _ProfileCard(profile: profile),
            const SizedBox(height: ASpacing.lg),
            _ContactCard(profile: profile),
          ],
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final CustomerCompanyProfile profile;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String tierLabel =
        l10n?.translate('customerCompanyProfileTierLabel') ?? 'Tier';
    final String industryLabel =
        l10n?.translate('customerCompanyProfileIndustryLabel') ?? 'Industry';
    final String salesRepLabel =
        l10n?.translate('customerCompanyProfileSalesRepLabel') ?? 'Sales Rep';
    final String emailLabel =
        l10n?.translate('customerCompanyProfileEmailLabel') ?? 'Email';
    return Container(
      padding: const EdgeInsets.all(ASpacing.xl),
      decoration: BoxDecoration(
        color: AColors.surface,
        borderRadius: ARadii.lg,
        border: Border.all(
          color: AColors.cardBorder.withValues(alpha: 0.7),
        ),
        boxShadow: AElevation.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AColors.primaryMuted,
                child: Text(
                  profile.companyName.isNotEmpty
                      ? profile.companyName[0].toUpperCase()
                      : '#',
                  style: ATypography.titleMd.copyWith(color: AColors.primary),
                ),
              ),
              const SizedBox(width: ASpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.companyName,
                      style: ATypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: ASpacing.xs),
                    Text(
                      profile.companyId,
                      style: ATypography.bodySm,
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: profile.status),
            ],
          ),
          const SizedBox(height: ASpacing.xl),
          Wrap(
            spacing: ASpacing.xl,
            runSpacing: ASpacing.lg,
            children: [
              _InfoColumn(label: tierLabel, value: profile.tier),
              _InfoColumn(label: industryLabel, value: profile.industry),
              _InfoColumn(label: salesRepLabel, value: profile.salesRepName),
              _InfoColumn(label: emailLabel, value: profile.salesRepEmail),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.profile});

  final CustomerCompanyProfile profile;

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String contactTitle =
        l10n?.translate('customerCompanyProfileContactTitle') ??
            'Contact Details';
    return Container(
      padding: const EdgeInsets.all(ASpacing.xl),
      decoration: BoxDecoration(
        color: AColors.surface,
        borderRadius: ARadii.lg,
        border: Border.all(
          color: AColors.cardBorder.withValues(alpha: 0.7),
        ),
        boxShadow: AElevation.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contactTitle, style: ATypography.titleSm),
          const SizedBox(height: ASpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined, color: AColors.primary),
            title: Text(profile.formattedAddress, style: ATypography.bodyMd),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_outlined, color: AColors.primary),
            title: Text(profile.phone, style: ATypography.bodyMd),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
          ),
          const SizedBox(height: ASpacing.xs),
          Text(
            value,
            style: ATypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final bool active = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? AColors.success.withValues(alpha: 0.12)
            : AColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.timelapse,
            size: 16,
            color: active ? AColors.success : AColors.warning,
          ),
          const SizedBox(width: ASpacing.xs),
          Text(
            status,
            style: ATypography.bodySm.copyWith(
              color: active ? AColors.success : AColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label, required this.comingSoon});

  final String label;
  final String comingSoon;

  @override
  Widget build(BuildContext context) {
    final String placeholderText =
        comingSoon.isEmpty ? label : '$label $comingSoon';
    return Center(
      child: Text(
        placeholderText,
        style: ATypography.bodyLg.copyWith(color: AColors.mutedForeground),
      ),
    );
  }
}
