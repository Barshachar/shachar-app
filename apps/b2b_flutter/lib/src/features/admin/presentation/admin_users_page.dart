import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:design_system/design_system.dart' hide AlertDialog;
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_managed_user.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_user_action_result.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_users_controller.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

enum _AdminUserFilter { all, active, disabled }

String _roleLabel(UserRole role, MarketplaceLocalizations? l10n) {
  switch (role) {
    case UserRole.admin:
      return l10n?.translate('adminUserRoleAdmin') ?? 'Platform admin';
    case UserRole.vendorAdmin:
      return l10n?.translate('adminUserRoleVendorAdmin') ?? 'Vendor admin';
    case UserRole.vendorUser:
      return l10n?.translate('adminUserRoleVendorUser') ?? 'Vendor user';
    case UserRole.customerAdmin:
      return l10n?.translate('adminUserRoleCustomerAdmin') ?? 'Customer admin';
    case UserRole.buyer:
      return l10n?.translate('adminUserRoleBuyer') ?? 'Buyer';
  }
}

String _userInitial(AdminManagedUser user) {
  final String? fullName = user.fullName?.trim();
  final String email = user.email.trim();
  final String source =
      (fullName != null && fullName.isNotEmpty) ? fullName : email;
  if (source.isEmpty) {
    return '?';
  }
  final int firstRune = source.runes.first;
  return String.fromCharCode(firstRune).toUpperCase();
}

String _formatDateTime(
  DateTime? value,
  BuildContext context,
  MarketplaceLocalizations? l10n,
) {
  if (value == null) {
    return l10n?.translate('adminUsersNever') ?? 'Never';
  }
  final Locale locale = Localizations.localeOf(context);
  final intl.DateFormat formatter =
      intl.DateFormat.yMMMd(locale.toString()).add_Hm();
  return formatter.format(value.toLocal());
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  _AdminUserFilter _filter = _AdminUserFilter.active;

  @override
  void dispose() {
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

    final AsyncValue<List<AdminManagedUser>> usersState =
        ref.watch(adminUsersControllerProvider);
    final List<AdminManagedUser> safeUsers =
        (usersState.value?.isNotEmpty ?? false)
            ? usersState.value!
            : AdminUsersController.fallbackUsers;
    final bool isLoading = usersState.isLoading;
    final Object? loadError =
        usersState is AsyncError ? (usersState as AsyncError).error : null;

    final String title =
        l10n?.translate('adminUsersTitle') ?? 'User management';
    final String subtitle = l10n?.translate('adminUsersSubtitle') ??
        'Invite, deactivate, and monitor team access across the marketplace.';
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            tooltip: l10n?.translate('adminUsersRefresh') ?? 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(adminUsersControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onInvite(context, l10n),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n?.translate('adminUsersInviteCta') ?? 'Invite user'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            isRtl ? ASpacing.md : ASpacing.page,
            ASpacing.lg,
            isRtl ? ASpacing.page : ASpacing.md,
            ASpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: ATypography.headline2,
              ),
              const SizedBox(height: ASpacing.xs),
              Text(
                subtitle,
                style: ATypography.bodyMd.copyWith(
                  color: SemanticColors.foregroundMuted,
                ),
              ),
              const SizedBox(height: ASpacing.lg),
              _buildFilters(context, l10n, isRtl),
              const SizedBox(height: ASpacing.md),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    _buildContent(context, l10n, safeUsers),
                    if (isLoading)
                      const Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (loadError != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        child: Card(
                          color: SemanticColors.destructive
                              .withValues(alpha: 0.08),
                          child: Padding(
                            padding: const EdgeInsets.all(ASpacing.sm),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    l10n?.translate('adminUsersError') ??
                                        'Load failed, showing fallback users.',
                                    style: ATypography.bodySm.copyWith(
                                      color: SemanticColors.destructive,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => ref
                                      .read(
                                          adminUsersControllerProvider.notifier)
                                      .refresh(),
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    l10n?.translate('adminUsersRefresh') ??
                                        'רענן',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    MarketplaceLocalizations? l10n,
    bool isRtl,
  ) {
    final String searchHint =
        l10n?.translate('adminUsersSearchHint') ?? 'Search by name or email';
    final String allLabel = l10n?.translate('adminUsersFilterAll') ?? 'All';
    final String activeLabel =
        l10n?.translate('adminUsersFilterActive') ?? 'Active';
    final String disabledLabel =
        l10n?.translate('adminUsersFilterDisabled') ?? 'Disabled';

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool horizontal = constraints.maxWidth > 720;
        final EdgeInsetsDirectional textFieldPadding =
            EdgeInsetsDirectional.fromSTEB(
                isRtl ? ASpacing.xs : 0, 0, isRtl ? 0 : ASpacing.xs, 0);

        final Widget searchField = Expanded(
          child: Padding(
            padding: horizontal ? EdgeInsetsDirectional.zero : textFieldPadding,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: searchHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        );

        final SegmentedButton<_AdminUserFilter> filterSegment =
            SegmentedButton<_AdminUserFilter>(
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: ASpacing.sm),
            ),
          ),
          segments: <ButtonSegment<_AdminUserFilter>>[
            ButtonSegment<_AdminUserFilter>(
              value: _AdminUserFilter.active,
              label: Text(activeLabel),
              icon: const Icon(Icons.verified_user_outlined),
            ),
            ButtonSegment<_AdminUserFilter>(
              value: _AdminUserFilter.disabled,
              label: Text(disabledLabel),
              icon: const Icon(Icons.block_outlined),
            ),
            ButtonSegment<_AdminUserFilter>(
              value: _AdminUserFilter.all,
              label: Text(allLabel),
              icon: const Icon(Icons.people_alt_outlined),
            ),
          ],
          selected: <_AdminUserFilter>{_filter},
          onSelectionChanged: (Set<_AdminUserFilter> selection) {
            setState(() {
              _filter = selection.first;
            });
          },
        );

        if (horizontal) {
          return Row(
            children: <Widget>[
              searchField,
              const SizedBox(width: ASpacing.md),
              filterSegment,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            searchField,
            const SizedBox(height: ASpacing.sm),
            filterSegment,
          ],
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    MarketplaceLocalizations? l10n,
    List<AdminManagedUser> users,
  ) {
    final List<AdminManagedUser> filtered = _applyFilters(users);

    if (filtered.isEmpty) {
      return _EmptyState(
        title: l10n?.translate('adminUsersEmptyTitle') ?? 'No users yet',
        subtitle: l10n?.translate('adminUsersEmptySubtitle') ??
            'Use the invite button to add your first teammate.',
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth > 960;
        if (wide) {
          return _buildDataTable(context, l10n, filtered);
        }
        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(adminUsersControllerProvider.notifier).refresh();
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: ASpacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final AdminManagedUser user = filtered[index];
              return _UserCard(
                user: user,
                onDeactivate: () => _onDeactivate(context, l10n, user),
                onActivate: () => _onActivate(context, l10n, user),
                l10n: l10n,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    MarketplaceLocalizations? l10n,
    List<AdminManagedUser> users,
  ) {
    final String roleLabel = l10n?.translate('adminUsersRoleHeader') ?? 'Role';
    final String lastSignInLabel =
        l10n?.translate('adminUsersLastSignIn') ?? 'Last sign-in';
    final String invitedAtLabel =
        l10n?.translate('adminUsersInvitedAt') ?? 'Invited';
    final String statusLabel =
        l10n?.translate('adminUsersStatusHeader') ?? 'Status';
    final String actionsLabel =
        l10n?.translate('adminUsersActionsHeader') ?? 'Actions';

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(adminUsersControllerProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: DataTable(
              columnSpacing: ASpacing.lg,
              columns: <DataColumn>[
                DataColumn(
                  label: Text(
                    l10n?.translate('adminUsersIdentityHeader') ?? 'User',
                    style: ATypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    roleLabel,
                    style: ATypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    lastSignInLabel,
                    style: ATypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    invitedAtLabel,
                    style: ATypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    statusLabel,
                    style: ATypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                DataColumn(
                  label: Text(
                    actionsLabel,
                    style: ATypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              rows: users
                  .map(
                    (AdminManagedUser user) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 220, maxWidth: 280),
                            child: _UserIdentityCell(user: user),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 120, maxWidth: 180),
                            child: Text(_roleLabel(user.role, l10n)),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 150, maxWidth: 220),
                            child: Text(_formatDateTime(
                                user.lastSignInAt, context, l10n)),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 150, maxWidth: 220),
                            child: Text(
                                _formatDateTime(user.invitedAt, context, l10n)),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 140, maxWidth: 200),
                            child: _StatusChip(user: user, l10n: l10n),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: 200, maxWidth: 260),
                            child: Wrap(
                              spacing: ASpacing.xs,
                              runSpacing: ASpacing.xs,
                              children: <Widget>[
                                if (user.isDisabled)
                                  TextButton.icon(
                                    onPressed: () =>
                                        _onActivate(context, l10n, user),
                                    icon: const Icon(Icons.refresh),
                                    label: Text(
                                      l10n?.translate(
                                              'adminUsersActivateCta') ??
                                          'Activate',
                                    ),
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: () =>
                                        _onDeactivate(context, l10n, user),
                                    icon: const Icon(Icons.block),
                                    label: Text(
                                      l10n?.translate(
                                              'adminUsersDeactivateCta') ??
                                          'Disable',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }

  List<AdminManagedUser> _applyFilters(List<AdminManagedUser> users) {
    Iterable<AdminManagedUser> filtered = users;
    switch (_filter) {
      case _AdminUserFilter.active:
        filtered = filtered.where((AdminManagedUser user) => !user.isDisabled);
        break;
      case _AdminUserFilter.disabled:
        filtered = filtered.where((AdminManagedUser user) => user.isDisabled);
        break;
      case _AdminUserFilter.all:
        break;
    }

    final String query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where(
        (AdminManagedUser user) =>
            user.email.toLowerCase().contains(query) ||
            (user.fullName?.toLowerCase().contains(query) ?? false),
      );
    }

    final List<AdminManagedUser> sorted = filtered.toList(growable: false)
      ..sort((AdminManagedUser a, AdminManagedUser b) =>
          a.email.toLowerCase().compareTo(b.email.toLowerCase()));
    return sorted;
  }

  Future<void> _onInvite(
    BuildContext context,
    MarketplaceLocalizations? l10n,
  ) async {
    final InviteUserFormResult? result = await showDialog<InviteUserFormResult>(
      context: context,
      builder: (BuildContext dialogContext) => InviteUserDialog(l10n: l10n),
    );
    if (result == null) {
      return;
    }

    try {
      final AdminUserActionResult actionResult =
          await ref.read(adminUsersControllerProvider.notifier).inviteUser(
                email: result.email,
                role: result.role,
                fullName: result.fullName,
              );
      if (!context.mounted) {
        return;
      }
      final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      if (actionResult.queued) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              l10n?.translate('adminUsersQueuedSnack') ??
                  'Queued offline. Will sync when back online.',
            ),
          ),
        );
      } else {
        final String template = l10n?.translate('adminUsersInviteSuccess') ??
            'Invitation sent to {email}';
        scaffold.showSnackBar(
          SnackBar(
            content: Text(template.replaceAll('{email}', result.email)),
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            (l10n?.translate('adminUsersError') ??
                    'Operation failed: {message}')
                .replaceAll('{message}', error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _onDeactivate(
    BuildContext context,
    MarketplaceLocalizations? l10n,
    AdminManagedUser user,
  ) async {
    final _DeactivateDialogResult? confirmation =
        await showDialog<_DeactivateDialogResult>(
      context: context,
      builder: (BuildContext dialogContext) => DeactivateUserDialog(
        user: user,
        l10n: l10n,
      ),
    );

    if (confirmation == null) {
      return;
    }

    try {
      final AdminUserActionResult result =
          await ref.read(adminUsersControllerProvider.notifier).deactivateUser(
                user.id,
                reason: confirmation.reason,
              );
      if (!context.mounted) {
        return;
      }
      final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      if (result.queued) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              l10n?.translate('adminUsersQueuedSnack') ??
                  'Queued offline. Will sync when back online.',
            ),
          ),
        );
      } else {
        final String template =
            l10n?.translate('adminUsersDeactivateSuccess') ??
                '{email} disabled';
        scaffold.showSnackBar(
          SnackBar(
            content: Text(template.replaceAll('{email}', user.email)),
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            (l10n?.translate('adminUsersError') ??
                    'Operation failed: {message}')
                .replaceAll('{message}', error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _onActivate(
    BuildContext context,
    MarketplaceLocalizations? l10n,
    AdminManagedUser user,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ActivateUserDialog(
        user: user,
        l10n: l10n,
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      final AdminUserActionResult result =
          await ref.read(adminUsersControllerProvider.notifier).activateUser(
                user.id,
              );
      if (!context.mounted) {
        return;
      }
      final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      if (result.queued) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              l10n?.translate('adminUsersQueuedSnack') ??
                  'Queued offline. Will sync when back online.',
            ),
          ),
        );
      } else {
        final String template = l10n?.translate('adminUsersActivateSuccess') ??
            '{email} reactivated';
        scaffold.showSnackBar(
          SnackBar(
            content: Text(template.replaceAll('{email}', user.email)),
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            (l10n?.translate('adminUsersError') ??
                    'Operation failed: {message}')
                .replaceAll('{message}', error.toString()),
          ),
        ),
      );
    }
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onDeactivate,
    required this.onActivate,
    required this.l10n,
  });

  final AdminManagedUser user;
  final VoidCallback onDeactivate;
  final VoidCallback onActivate;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String role = _roleLabel(user.role, l10n);
    final String invitedLabel =
        l10n?.translate('adminUsersInvitedAt') ?? 'Invited';
    final String lastSignInLabel =
        l10n?.translate('adminUsersLastSignIn') ?? 'Last sign-in';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SemanticColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor:
                      SemanticColors.primary.withValues(alpha: 0.15),
                  foregroundColor: SemanticColors.primary,
                  child: Text(
                    _userInitial(user),
                  ),
                ),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.fullName?.isNotEmpty == true
                            ? user.fullName!
                            : user.email,
                        style: ATypography.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user.fullName?.isNotEmpty == true)
                        Text(
                          user.email,
                          style: ATypography.bodySm.copyWith(
                            color: SemanticColors.foregroundMuted,
                          ),
                        ),
                      const SizedBox(height: ASpacing.xs),
                      Wrap(
                        spacing: ASpacing.sm,
                        runSpacing: ASpacing.xs,
                        children: <Widget>[
                          Chip(
                            label: Text(role),
                            avatar: const Icon(Icons.badge_outlined, size: 18),
                          ),
                          _StatusChip(user: user, l10n: l10n),
                        ],
                      ),
                    ],
                  ),
                ),
                if (user.isDisabled)
                  TextButton.icon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      l10n?.translate('adminUsersActivateCta') ?? 'Activate',
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: onDeactivate,
                    icon: const Icon(Icons.block),
                    label: Text(
                      l10n?.translate('adminUsersDeactivateCta') ?? 'Disable',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: ASpacing.sm),
            Row(
              children: <Widget>[
                Icon(Icons.event_available_outlined,
                    color: SemanticColors.foregroundMuted, size: 18),
                const SizedBox(width: ASpacing.xs),
                Text(
                  '$invitedLabel: ${_formatDateTime(user.invitedAt, context, l10n)}',
                  style: ATypography.bodySm.copyWith(
                    color: SemanticColors.foregroundMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.xs),
            Row(
              children: <Widget>[
                Icon(Icons.schedule_outlined,
                    color: SemanticColors.foregroundMuted, size: 18),
                const SizedBox(width: ASpacing.xs),
                Text(
                  '$lastSignInLabel: ${_formatDateTime(user.lastSignInAt, context, l10n)}',
                  style: ATypography.bodySm.copyWith(
                    color: SemanticColors.foregroundMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserIdentityCell extends StatelessWidget {
  const _UserIdentityCell({required this.user});

  final AdminManagedUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 18,
          backgroundColor: SemanticColors.primary.withValues(alpha: 0.18),
          foregroundColor: SemanticColors.primary,
          child: Text(
            _userInitial(user),
          ),
        ),
        const SizedBox(width: ASpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              user.fullName?.isNotEmpty == true ? user.fullName! : user.email,
              style: ATypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
            if (user.fullName?.isNotEmpty == true)
              Text(
                user.email,
                style: ATypography.bodySm.copyWith(
                  color: SemanticColors.foregroundMuted,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.user, required this.l10n});

  final AdminManagedUser user;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final bool disabled = user.isDisabled;
    final Color background =
        disabled ? StatusColors.offlineSubtle : StatusColors.onlineSubtle;
    final Color foreground =
        disabled ? StatusColors.offline : StatusColors.online;
    final String label = disabled
        ? l10n?.translate('adminUsersStatusDisabled') ?? 'Disabled'
        : l10n?.translate('adminUsersStatusActive') ?? 'Active';

    return Chip(
      label: Text(label),
      avatar: Icon(
        disabled ? Icons.block : Icons.verified_user,
        size: 18,
        color: foreground,
      ),
      backgroundColor: background,
      labelStyle: ATypography.bodySm.copyWith(color: foreground),
      side: BorderSide(color: foreground.withValues(alpha: 0.4)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.people_outline,
              size: 48, color: SemanticColors.border),
          const SizedBox(height: ASpacing.md),
          Text(
            title,
            style: ATypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: ASpacing.xs),
          SizedBox(
            width: 320,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: ATypography.bodySm.copyWith(
                color: SemanticColors.foregroundMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InviteUserDialog extends StatefulWidget {
  const InviteUserDialog({super.key, required this.l10n});

  final MarketplaceLocalizations? l10n;

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  UserRole? _selectedRole = UserRole.customerAdmin;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.l10n?.translate('adminUsersInviteTitle') ?? 'Invite new user';
    final String emailLabel =
        widget.l10n?.translate('adminUsersInviteEmailLabel') ?? 'Email';
    final String nameLabel =
        widget.l10n?.translate('adminUsersInviteFullNameLabel') ??
            'Full name (optional)';
    final String roleLabel =
        widget.l10n?.translate('adminUsersInviteRoleLabel') ?? 'Role';
    final String cancelLabel =
        widget.l10n?.translate('adminUsersInviteCancel') ?? 'Cancel';
    final String submitLabel =
        widget.l10n?.translate('adminUsersInviteSubmit') ?? 'Send invite';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: emailLabel),
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                validator: (String? value) {
                  final String trimmed = value?.trim() ?? '';
                  final String errorMessage =
                      widget.l10n?.translate('adminUsersInviteEmailError') ??
                          'Enter a valid corporate email';
                  if (trimmed.isEmpty) {
                    return errorMessage;
                  }
                  const String pattern =
                      r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$';
                  final RegExp regex = RegExp(pattern, caseSensitive: false);
                  if (!regex.hasMatch(trimmed)) {
                    return errorMessage;
                  }
                  return null;
                },
              ),
              const SizedBox(height: ASpacing.md),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: nameLabel),
              ),
              const SizedBox(height: ASpacing.md),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: roleLabel),
                items: UserRole.values
                    .map(
                      (UserRole role) => DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(_roleLabel(role, widget.l10n)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (UserRole? value) {
                  setState(() => _selectedRole = value);
                },
                validator: (UserRole? value) {
                  if (value == null) {
                    return widget.l10n
                            ?.translate('adminUsersInviteRoleError') ??
                        'Select a role';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              InviteUserFormResult(
                email: _emailController.text.trim(),
                fullName: _nameController.text.trim().isEmpty
                    ? null
                    : _nameController.text.trim(),
                role: _selectedRole!,
              ),
            );
          },
          child: Text(submitLabel),
        ),
      ],
    );
  }
}

class InviteUserFormResult {
  const InviteUserFormResult({
    required this.email,
    required this.role,
    this.fullName,
  });

  final String email;
  final UserRole role;
  final String? fullName;
}

class DeactivateUserDialog extends StatefulWidget {
  const DeactivateUserDialog({
    super.key,
    required this.user,
    required this.l10n,
  });

  final AdminManagedUser user;
  final MarketplaceLocalizations? l10n;

  @override
  State<DeactivateUserDialog> createState() => _DeactivateUserDialogState();
}

class _DeactivateUserDialogState extends State<DeactivateUserDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.l10n?.translate('adminUsersDeactivateTitle') ?? 'Disable user';
    final String message =
        widget.l10n?.translate('adminUsersDeactivateMessage') ??
            'The user will lose access immediately. You can reactivate later.';
    final String reasonHint =
        widget.l10n?.translate('adminUsersDeactivateReasonHint') ??
            'Reason (optional)';
    final String cancelLabel =
        widget.l10n?.translate('adminUsersInviteCancel') ?? 'Cancel';
    final String confirmLabel =
        widget.l10n?.translate('adminUsersDeactivateConfirm') ?? 'Disable user';

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(message),
          const SizedBox(height: ASpacing.md),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: reasonHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _DeactivateDialogResult(
                reason: _reasonController.text.trim().isEmpty
                    ? null
                    : _reasonController.text.trim(),
              ),
            );
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class _DeactivateDialogResult {
  const _DeactivateDialogResult({this.reason});

  final String? reason;
}

class ActivateUserDialog extends StatelessWidget {
  const ActivateUserDialog({
    super.key,
    required this.user,
    required this.l10n,
  });

  final AdminManagedUser user;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String title =
        l10n?.translate('adminUsersActivateTitle') ?? 'Reactivate user';
    final String message = l10n?.translate('adminUsersActivateMessage') ??
        'Restore access for this user?';
    final String cancelLabel =
        l10n?.translate('adminUsersInviteCancel') ?? 'Cancel';
    final String confirmLabel =
        l10n?.translate('adminUsersActivateConfirm') ?? 'Activate user';

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
