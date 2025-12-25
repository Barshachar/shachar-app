/// About page
library;

import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _appVersion = '1.0.0+1';

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title = l10n?.translate('aboutTitle') ?? 'אודות א.שחר';
    final String subtitle = l10n?.translate('aboutSubtitle') ??
        'פלטפורמת רכש B2B למרקטפלייס רב-ספקי.';
    final String versionLabel = l10n?.translate('aboutVersionLabel') ?? 'גרסה';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(ASpacing.lg),
        children: [
          _AboutHeroCard(
            title: title,
            subtitle: subtitle,
            versionLabel: versionLabel,
            versionValue: _appVersion,
          ),
          const SizedBox(height: ASpacing.xl),
          _AboutSection(
            title: l10n?.translate('aboutMissionTitle') ?? 'המשימה שלנו',
            child: Text(
              l10n?.translate('aboutMissionBody') ??
                  'להפוך רכש B2B למהיר, שקוף ואמין — מהמקור ועד האספקה.',
              style: ATypography.bodyMd.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: ASpacing.xl),
          _AboutSection(
            title: l10n?.translate('aboutHighlightsTitle') ?? 'מה תוכלו לעשות',
            child: Column(
              children: [
                _HighlightTile(
                  icon: Icons.shopping_basket_outlined,
                  title: l10n?.translate('aboutHighlightOrdersTitle') ??
                      'להזמין תוך דקות',
                  description: l10n?.translate('aboutHighlightOrdersBody') ??
                      'איחוד ספקים, אישורים ומעקב משלוחים במקום אחד.',
                ),
                const SizedBox(height: ASpacing.md),
                _HighlightTile(
                  icon: Icons.price_check_outlined,
                  title: l10n?.translate('aboutHighlightPricingTitle') ??
                      'תמחור חכם',
                  description: l10n?.translate('aboutHighlightPricingBody') ??
                      'מחירים מותאמים ללקוח, מבצעים וחוזים.',
                ),
                const SizedBox(height: ASpacing.md),
                _HighlightTile(
                  icon: Icons.insights_outlined,
                  title: l10n?.translate('aboutHighlightInsightsTitle') ??
                      'תובנות תפעוליות',
                  description: l10n?.translate('aboutHighlightInsightsBody') ??
                      'דשבורדים והתראות שמחזיקים את השרשרת בשליטה.',
                ),
              ],
            ),
          ),
          const SizedBox(height: ASpacing.xl),
          _AboutSection(
            title: l10n?.translate('aboutContactTitle') ?? 'צור קשר',
            child: Column(
              children: [
                _ContactRow(
                  icon: Icons.phone_outlined,
                  label: l10n?.translate('aboutContactPhoneLabel') ?? 'טלפון',
                  value:
                      l10n?.translate('aboutContactPhoneValue') ?? '03-1234567',
                ),
                const SizedBox(height: ASpacing.md),
                _ContactRow(
                  icon: Icons.email_outlined,
                  label: l10n?.translate('aboutContactEmailLabel') ?? 'אימייל',
                  value: l10n?.translate('aboutContactEmailValue') ??
                      'support@ashachar.co.il',
                ),
                const SizedBox(height: ASpacing.md),
                _ContactRow(
                  icon: Icons.access_time_outlined,
                  label: l10n?.translate('aboutContactHoursLabel') ??
                      'שעות פעילות',
                  value: l10n?.translate('aboutContactHoursValue') ??
                      'א\'-ה\' 08:00-17:00',
                ),
              ],
            ),
          ),
          const SizedBox(height: ASpacing.xl),
          _AboutSection(
            title: l10n?.translate('aboutLegalTitle') ?? 'משפטי',
            child: Column(
              children: [
                _LegalTile(
                  icon: Icons.description_outlined,
                  title: l10n?.translate('aboutLegalTerms') ?? 'תנאי שימוש',
                  fallbackMessage: l10n?.translate('aboutLegalSoon') ?? 'בקרוב',
                ),
                const SizedBox(height: ASpacing.sm),
                _LegalTile(
                  icon: Icons.privacy_tip_outlined,
                  title:
                      l10n?.translate('aboutLegalPrivacy') ?? 'מדיניות פרטיות',
                  fallbackMessage: l10n?.translate('aboutLegalSoon') ?? 'בקרוב',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHeroCard extends StatelessWidget {
  const _AboutHeroCard({
    required this.title,
    required this.subtitle,
    required this.versionLabel,
    required this.versionValue,
  });

  final String title;
  final String subtitle;
  final String versionLabel;
  final String versionValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AElevation.level1,
      shape: RoundedRectangleBorder(borderRadius: ARadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AColors.surfaceSubtle,
                    borderRadius: ARadii.md,
                    border: Border.all(color: AColors.cardBorder),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: AColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: ATypography.titleLg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.sm),
            Text(
              subtitle,
              style: ATypography.bodySm.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
            const SizedBox(height: ASpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ASpacing.md,
                vertical: ASpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AColors.surfaceSubtle,
                borderRadius: ARadii.pill,
                border: Border.all(color: AColors.cardBorder),
              ),
              child: Text(
                '$versionLabel $versionValue',
                style: ATypography.bodyXs.copyWith(
                  color: AColors.neutral600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AElevation.level1,
      shape: RoundedRectangleBorder(borderRadius: ARadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ATypography.titleMd),
            const SizedBox(height: ASpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ASpacing.md),
      decoration: BoxDecoration(
        color: AColors.surfaceSubtle,
        borderRadius: ARadii.md,
        border: Border.all(color: AColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AColors.primary),
          const SizedBox(width: ASpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ATypography.titleSm),
                const SizedBox(height: ASpacing.xs),
                Text(
                  description,
                  style: ATypography.bodySm.copyWith(
                    color: AColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AColors.primary),
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

class _LegalTile extends StatelessWidget {
  const _LegalTile({
    required this.icon,
    required this.title,
    required this.fallbackMessage,
  });

  final IconData icon;
  final String title;
  final String fallbackMessage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: ARadii.md,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title - $fallbackMessage')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ASpacing.md,
          vertical: ASpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AColors.surface,
          borderRadius: ARadii.md,
          border: Border.all(color: AColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AColors.primary),
            const SizedBox(width: ASpacing.md),
            Expanded(
              child: Text(
                title,
                style: ATypography.bodyMd,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
