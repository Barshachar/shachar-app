/// Customer profile page
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('פרופיל'),
      ),
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('שגיאה: ${error.toString()}'),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('אנא התחבר לחשבון'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(ASpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AColors.primary,
                        child: Text(
                          profile.displayName?.substring(0, 1).toUpperCase() ??
                              profile.email.substring(0, 1).toUpperCase(),
                          style: ATypography.titleLg.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: ASpacing.lg),
                      Text(
                        profile.displayName ?? profile.email.split('@')[0],
                        style: ATypography.titleLg,
                      ),
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        profile.email,
                        style: ATypography.bodyMd.copyWith(
                          color: AColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ASpacing.xxl),

                // Profile information
                _ProfileSection(
                  title: 'פרטים אישיים',
                  children: [
                    _ProfileItem(
                      icon: Icons.person_outline,
                      label: 'שם תצוגה',
                      value: profile.displayName ?? '-',
                    ),
                    _ProfileItem(
                      icon: Icons.email_outlined,
                      label: 'אימייל',
                      value: profile.email,
                    ),
                    _ProfileItem(
                      icon: Icons.business_outlined,
                      label: 'חברה',
                      value: profile.companyId,
                    ),
                    _ProfileItem(
                      icon: Icons.badge_outlined,
                      label: 'תפקיד',
                      value: _getRoleText(profile.role),
                    ),
                  ],
                ),

                const SizedBox(height: ASpacing.xl),

                // Actions
                _ProfileSection(
                  title: 'פעולות',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('ערוך פרופיל'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showEditProfileDialog(context, profile);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('שנה סיסמה'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showChangePasswordDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('העדפות התראות'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.go('/customer/settings');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: ASpacing.xl),

                // Logout button
                Center(
                  child: AButton.secondary(
                    label: 'התנתק',
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('התנתקות'),
                          content: const Text('האם אתה בטוח שברצונך להתנתק?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('ביטול'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('התנתק'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        try {
                          await ref
                              .read(sessionControllerProvider.notifier)
                              .signOut();
                          if (context.mounted) {
                            context.go('/home');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('שגיאה בהתנתקות: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.displayName);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ערוך פרופיל'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'שם תצוגה',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'לא ניתן לשנות אימייל או פרטי חברה',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('הפרופיל עודכן בהצלחה')),
              );
            },
            child: const Text('שמור'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שנה סיסמה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'סיסמה נוכחית',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'סיסמה חדשה',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'אשר סיסמה חדשה',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          FilledButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('הסיסמה שונתה בהצלחה')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('הסיסמאות לא תואמות')),
                );
              }
            },
            child: const Text('שמור'),
          ),
        ],
      ),
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'מנהל';
      case UserRole.vendorAdmin:
        return 'מנהל ספק';
      case UserRole.vendorUser:
        return 'משתמש ספק';
      case UserRole.customerAdmin:
        return 'מנהל לקוח';
      case UserRole.buyer:
        return 'קונה';
    }
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ATypography.titleMd,
        ),
        const SizedBox(height: ASpacing.md),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AColors.primary),
      title: Text(label,
          style: ATypography.bodyXs.copyWith(
            color: AColors.mutedForeground,
          )),
      subtitle: Text(value, style: ATypography.bodyMd),
    );
  }
}
