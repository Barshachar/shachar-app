import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
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
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Customer Profile'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Orders'),
              Tab(text: 'Quotes'),
              Tab(text: 'Credit'),
              Tab(text: 'Contracts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(companyId: companyId),
            const _PlaceholderTab(label: 'Orders'),
            const _PlaceholderTab(label: 'Quotes'),
            const _PlaceholderTab(label: 'Credit'),
            const _PlaceholderTab(label: 'Contracts'),
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
    final AsyncValue<CustomerCompanyProfile> profileAsync =
        ref.watch(customerCompanyProfileProvider(companyId));

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stackTrace) => Center(
        child: Text('Unable to load profile\n$error'),
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
    return Container(
      padding: const EdgeInsets.all(ASpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
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
              _InfoColumn(label: 'Tier', value: profile.tier),
              _InfoColumn(label: 'Industry', value: profile.industry),
              _InfoColumn(label: 'Sales Rep', value: profile.salesRepName),
              _InfoColumn(label: 'Email', value: profile.salesRepEmail),
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
    return Container(
      padding: const EdgeInsets.all(ASpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Details', style: ATypography.titleSm),
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
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label coming soon',
        style: ATypography.bodyLg.copyWith(color: AColors.mutedForeground),
      ),
    );
  }
}
