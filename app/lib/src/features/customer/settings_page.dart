/// Settings page
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/onboarding/onboarding_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _language = 'he';
  String _theme = 'system';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ASpacing.lg),
        children: [
          // Notifications Section
          _SectionHeader(title: 'התראות'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('התראות'),
                  subtitle: const Text('הפעל/כבה את כל ההתראות'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('התראות במייל'),
                  subtitle: const Text('קבל עדכונים במייל'),
                  value: _emailNotifications,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _emailNotifications = value);
                        }
                      : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('התראות Push'),
                  subtitle: const Text('קבל התראות באפליקציה'),
                  value: _pushNotifications,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() => _pushNotifications = value);
                        }
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: ASpacing.xl),

          // Appearance Section
          _SectionHeader(title: 'מראה'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('שפה'),
                  subtitle: Text(_language == 'he' ? 'עברית' : 'English'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('ערכת נושא'),
                  subtitle: Text(_getThemeText(_theme)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showThemeDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: ASpacing.xl),

          // Help & Support Section
          _SectionHeader(title: 'עזרה ותמיכה'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('מרכז עזרה'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('הצג הדרכה'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    OnboardingService.showOnboardingDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('שלח משוב'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showFeedbackDialog();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: ASpacing.xl),

          // About Section
          _SectionHeader(title: 'אודות'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('גרסה'),
                  subtitle: Text('1.0.0+1'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('תנאי שימוש'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('תנאי שימוש - בקרוב')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('מדיניות פרטיות'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('מדיניות פרטיות - בקרוב')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: ASpacing.xxl),

          // Danger Zone
          Center(
            child: AButton.secondary(
              label: 'נקה מטמון',
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: () {
                _showClearCacheDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeText(String theme) {
    switch (theme) {
      case 'light':
        return 'בהיר';
      case 'dark':
        return 'כהה';
      case 'system':
      default:
        return 'לפי המערכת';
    }
  }

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר שפה'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('עברית'),
              value: 'he',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('בחר ערכת נושא'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('בהיר'),
              value: 'light',
              groupValue: _theme,
              onChanged: (value) {
                setState(() => _theme = value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('כהה'),
              value: 'dark',
              groupValue: _theme,
              onChanged: (value) {
                setState(() => _theme = value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('לפי המערכת'),
              value: 'system',
              groupValue: _theme,
              onChanged: (value) {
                setState(() => _theme = value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('שלח משוב'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'כתוב את המשוב שלך כאן...',
            border: OutlineInputBorder(),
          ),
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
                const SnackBar(content: Text('תודה על המשוב!')),
              );
            },
            child: const Text('שלח'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('נקה מטמון'),
        content: const Text('האם אתה בטוח שברצונך לנקות את המטמון?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ביטול'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('המטמון נוקה בהצלחה')),
              );
            },
            child: const Text('נקה'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: ASpacing.md,
        bottom: ASpacing.md,
      ),
      child: Text(
        title,
        style: ATypography.titleSm.copyWith(
          color: AColors.mutedForeground,
        ),
      ),
    );
  }
}
