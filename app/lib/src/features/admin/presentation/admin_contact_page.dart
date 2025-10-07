import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

class AdminContactPage extends StatelessWidget {
  const AdminContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title = l10n?.translate('adminContactTitle') ?? 'Get in touch';
    final String nameLabel = l10n?.translate('adminContactFieldName') ?? 'Name';
    final String emailLabel =
        l10n?.translate('adminContactFieldEmail') ?? 'Email';
    final String companyLabel =
        l10n?.translate('adminContactFieldCompany') ?? 'Company';
    final String phoneLabel =
        l10n?.translate('adminContactFieldPhone') ?? 'Phone';
    final String submitLabel =
        l10n?.translate('adminContactSubmit') ?? 'Send message';

    return Scaffold(
      backgroundColor: AColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF11243D),
        foregroundColor: Colors.white,
        title: const Text('ACME Analytics'),
        actions: const [
          _TopNavItem(label: 'Home'),
          _TopNavItem(label: 'About'),
          _TopNavItem(label: 'Services'),
          _TopNavItem(label: 'Login'),
          SizedBox(width: ASpacing.md),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth > 640;
          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? ASpacing.page * 1.5 : ASpacing.page,
                vertical: ASpacing.xl,
              ),
              width: wide ? 720 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ATypography.headline1,
                  ),
                  const SizedBox(height: ASpacing.xl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: ARadii.md,
                      border: Border.all(color: AColors.cardBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(ASpacing.xl),
                      child: _ContactForm(
                        nameLabel: nameLabel,
                        emailLabel: emailLabel,
                        companyLabel: companyLabel,
                        phoneLabel: phoneLabel,
                        submitLabel: submitLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  const _ContactForm({
    required this.nameLabel,
    required this.emailLabel,
    required this.companyLabel,
    required this.phoneLabel,
    required this.submitLabel,
  });

  final String nameLabel;
  final String emailLabel;
  final String companyLabel;
  final String phoneLabel;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    final InputDecoration decoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: ARadii.sm,
        borderSide: const BorderSide(color: AColors.cardBorder),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ASpacing.md,
        vertical: ASpacing.sm,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContactField(label: nameLabel, decoration: decoration),
        const SizedBox(height: ASpacing.md),
        Row(
          children: [
            Expanded(
              child: _ContactField(
                label: emailLabel,
                decoration: decoration,
              ),
            ),
            const SizedBox(width: ASpacing.md),
            Expanded(
              child: _ContactField(
                label: companyLabel,
                decoration: decoration,
              ),
            ),
          ],
        ),
        const SizedBox(height: ASpacing.md),
        _ContactField(label: phoneLabel, decoration: decoration),
        const SizedBox(height: ASpacing.lg),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4B96),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: ARadii.md),
            ),
            onPressed: () {},
            child: Text(submitLabel),
          ),
        ),
      ],
    );
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({required this.label, required this.decoration});

  final String label;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ATypography.bodyLg),
        const SizedBox(height: ASpacing.xs),
        TextField(decoration: decoration),
      ],
    );
  }
}

class _TopNavItem extends StatelessWidget {
  const _TopNavItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: Text(
        label,
        style: ATypography.bodySm.copyWith(color: Colors.white),
      ),
    );
  }
}
