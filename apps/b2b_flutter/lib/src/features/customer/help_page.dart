/// Help center page
library;

import 'package:flutter/material.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/onboarding/onboarding_service.dart';
import 'package:ashachar_marketplace/src/features/support/presentation/support_ai_chat_page.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String _searchQuery = '';

  final List<HelpTopic> _topics = const [
    HelpTopic(
      icon: Icons.shopping_cart_outlined,
      title: 'ביצוע הזמנה',
      description: 'איך לבצע הזמנה מהירה וקלה',
      articles: [
        'חיפוש מוצרים',
        'הוספה לסל',
        'השלמת הזמנה',
        'בחירת אמצעי תשלום',
      ],
    ),
    HelpTopic(
      icon: Icons.flash_on,
      title: 'הזמנה מהירה',
      description: 'העלאת קובץ Excel להזמנה מהירה',
      articles: [
        'איך להכין קובץ Excel',
        'העלאת הקובץ',
        'אישור הזמנה',
      ],
    ),
    HelpTopic(
      icon: Icons.account_circle_outlined,
      title: 'ניהול חשבון',
      description: 'עריכת פרופיל והגדרות',
      articles: [
        'עדכון פרטים אישיים',
        'שינוי סיסמה',
        'הגדרות התראות',
      ],
    ),
    HelpTopic(
      icon: Icons.receipt_long_outlined,
      title: 'ניהול הזמנות',
      description: 'מעקב אחר הזמנות וביטולים',
      articles: [
        'צפייה בהזמנות',
        'מעקב משלוח',
        'ביטול הזמנה',
        'החזרת מוצר',
      ],
    ),
    HelpTopic(
      icon: Icons.payment_outlined,
      title: 'תשלומים',
      description: 'אמצעי תשלום וחשבוניות',
      articles: [
        'אמצעי תשלום זמינים',
        'הוספת כרטיס אשראי',
        'חשבוניות',
        'קבלות מס',
      ],
    ),
    HelpTopic(
      icon: Icons.help_outline,
      title: 'שאלות נפוצות',
      description: 'תשובות לשאלות נפוצות',
      articles: [
        'זמני אספקה',
        'עלויות משלוח',
        'החזרות והחלפות',
        'אחריות על מוצרים',
      ],
    ),
  ];

  List<HelpTopic> get _filteredTopics {
    if (_searchQuery.isEmpty) {
      return _topics;
    }
    return _topics.where((topic) {
      return topic.title.contains(_searchQuery) ||
          topic.description.contains(_searchQuery) ||
          topic.articles.any((article) => article.contains(_searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מרכז עזרה'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(ASpacing.lg),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'חפש נושא עזרה...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: ARadii.lg,
                ),
                filled: true,
                fillColor: AColors.surfaceSubtle,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ASpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.school_outlined,
                    title: 'הדרכה',
                    onTap: () {
                      OnboardingService.showOnboardingDialog(context);
                    },
                  ),
                ),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.chat_outlined,
                    title: 'צ\'אט',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SupportAiChatPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.phone_outlined,
                    title: 'התקשר',
                    onTap: () {
                      _showContactDialog();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: ASpacing.xl),

          // Topics list
          Expanded(
            child: _filteredTopics.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AColors.mutedForeground,
                        ),
                        const SizedBox(height: ASpacing.md),
                        Text(
                          'לא נמצאו תוצאות',
                          style: ATypography.titleMd,
                        ),
                        const SizedBox(height: ASpacing.sm),
                        Text(
                          'נסה לחפש במילים אחרות',
                          style: ATypography.bodySm.copyWith(
                            color: AColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(ASpacing.lg),
                    itemCount: _filteredTopics.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: ASpacing.lg),
                    itemBuilder: (context, index) {
                      final topic = _filteredTopics[index];
                      return _HelpTopicCard(topic: topic);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('צור קשר'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ContactItem(
              icon: Icons.phone,
              label: 'טלפון',
              value: '03-1234567',
            ),
            const SizedBox(height: ASpacing.md),
            _ContactItem(
              icon: Icons.email,
              label: 'אימייל',
              value: 'support@ashachar.co.il',
            ),
            const SizedBox(height: ASpacing.md),
            _ContactItem(
              icon: Icons.access_time,
              label: 'שעות פעילות',
              value: 'א\'-ה\' 08:00-17:00',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }
}

class HelpTopic {
  final IconData icon;
  final String title;
  final String description;
  final List<String> articles;

  const HelpTopic({
    required this.icon,
    required this.title,
    required this.description,
    required this.articles,
  });
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: ARadii.lg,
        child: Padding(
          padding: const EdgeInsets.all(ASpacing.lg),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AColors.primary),
              const SizedBox(height: ASpacing.sm),
              Text(
                title,
                style: ATypography.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  final HelpTopic topic;

  const _HelpTopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(topic.icon, color: AColors.primary),
        title: Text(topic.title, style: ATypography.titleSm),
        subtitle: Text(
          topic.description,
          style: ATypography.bodySm.copyWith(
            color: AColors.mutedForeground,
          ),
        ),
        children: topic.articles.map((article) {
          return ListTile(
            title: Text(article),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('מאמר: $article - בקרוב')),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AColors.primary),
        const SizedBox(width: ASpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: ATypography.bodyXs.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
            Text(value, style: ATypography.bodyMd),
          ],
        ),
      ],
    );
  }
}
