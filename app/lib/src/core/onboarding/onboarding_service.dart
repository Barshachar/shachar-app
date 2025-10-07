/// Onboarding service for new users
/// Shows tutorial and tips for first-time users
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding service - manages user onboarding state
class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyOnboardingVersion = 'onboarding_version';
  static const int _currentVersion = 1;

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_keyOnboardingCompleted) ?? false;
    final version = prefs.getInt(_keyOnboardingVersion) ?? 0;

    // If version changed, show onboarding again
    return completed && version >= _currentVersion;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
    await prefs.setInt(_keyOnboardingVersion, _currentVersion);
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingCompleted);
    await prefs.remove(_keyOnboardingVersion);
  }

  /// Show onboarding if needed
  static Future<void> showOnboardingIfNeeded(BuildContext context) async {
    final completed = await hasCompletedOnboarding();
    if (!completed && context.mounted) {
      await showOnboardingDialog(context);
    }
  }

  /// Show onboarding dialog
  static Future<void> showOnboardingDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const OnboardingDialog(),
    );
    await completeOnboarding();
  }
}

/// Onboarding dialog widget
class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key});

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      title: 'ברוכים הבאים לא.שחר Marketplace',
      description:
          'מערכת הזמנות מקצועית לעסקים. בואו נעבור יחד על התכונות העיקריות.',
      icon: Icons.waving_hand,
      iconColor: Colors.blue,
    ),
    OnboardingPage(
      title: 'חיפוש וקטלוג',
      description: 'חפשו מוצרים במהירות, סננו לפי קטגוריות, והוסיפו לסל בקלות.',
      icon: Icons.search,
      iconColor: Colors.green,
    ),
    OnboardingPage(
      title: 'הזמנה מהירה',
      description:
          'העלו קובץ Excel עם מק"טים ובצעו הזמנה של עשרות מוצרים בשניות!',
      icon: Icons.flash_on,
      iconColor: Colors.orange,
    ),
    OnboardingPage(
      title: 'ניהול הזמנות',
      description: 'עקבו אחר הזמנות, צפו בהיסטוריה, והזמינו שוב בקלות.',
      icon: Icons.shopping_bag,
      iconColor: Colors.purple,
    ),
    OnboardingPage(
      title: 'מוכנים להתחיל?',
      description: 'כל התכונות זמינות לכם. בהצלחה!',
      icon: Icons.rocket_launch,
      iconColor: Colors.red,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _pages[index];
                },
              ),
            ),
            const SizedBox(height: 24),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('הקודם'),
                  )
                else
                  const SizedBox(width: 80),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('דלג'),
                ),
                if (_currentPage < _pages.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('הבא'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('בואו נתחיל!'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Single onboarding page
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 64,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Feature spotlight widget - for highlighting specific features
class FeatureSpotlight extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final VoidCallback onDismiss;

  const FeatureSpotlight({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: Colors.black54,
            ),
          ),
        ),
        // Highlighted child
        child,
        // Tooltip
        Positioned(
          bottom: 80,
          left: 20,
          right: 20,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onDismiss,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: onDismiss,
                      child: const Text('הבנתי'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
