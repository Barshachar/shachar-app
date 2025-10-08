import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/promotions/data/promotions_repository.dart';

/// Simple UI-only model representing a promotion card on the buyer list.
@immutable
class PromotionUiModel {
  const PromotionUiModel({
    required this.id,
    required this.title,
    required this.badgeLabel,
    required this.validUntilText,
    this.termsText,
    this.tags = const <String>[],
    this.imageUrl,
    this.onViewProducts,
  });

  final String id;
  final String title;
  final String badgeLabel;
  final String validUntilText;
  final String? termsText;
  final List<String> tags;
  final String? imageUrl;
  final VoidCallback? onViewProducts;
}

/// Provider for the promotions page - fetches from database
final promotionsProvider = FutureProvider.autoDispose<List<PromotionUiModel>>(
  (ref) async {
    final repository = ref.watch(promotionsRepositoryProvider);
    return repository.fetchPromotions();
  },
);

class PromotionsPage extends ConsumerWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PromotionUiModel>> promotionsAsync =
        ref.watch(promotionsProvider);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    String translate(String key, String fallback) {
      final String translated = l10n?.translate(key) ?? fallback;
      return translated.isEmpty ? fallback : translated;
    }

    final String title = translate('promotionsTitle', 'מבצעים');
    final String emptyMessage = translate(
      'promotionsEmpty',
      'אין מבצעים פעילים כרגע.',
    );
    final String errorMessage = translate(
      'promotionsError',
      'לא ניתן לטעון את רשימת המבצעים.',
    );
    final String viewProductsLabel = translate('viewProducts', 'View products');
    final String validUntilTemplate =
        translate('promotionsValidUntil', 'Valid until {date}');
    final String termsApplyTemplate =
        translate('promotionsTermsApply', 'Terms apply {terms}');

    return Scaffold(
      key: const ValueKey('promotions_list_root'),
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/customer');
            }
          },
        ),
      ),
      body: SafeArea(
        child: promotionsAsync.when(
          loading: () => const _PromotionsLoading(),
          error: (error, stackTrace) => _PromotionsPlaceholder(
            key: const ValueKey('promotions_error_state'),
            icon: Icons.error_outline,
            message: errorMessage,
          ),
          data: (promotions) {
            if (promotions.isEmpty) {
              return _PromotionsPlaceholder(
                key: const ValueKey('promotions_empty_state'),
                icon: Icons.inbox_outlined,
                message: emptyMessage,
              );
            }
            // Add onViewProducts callback
            final promotionsWithCallback = promotions.map((p) {
              return PromotionUiModel(
                id: p.id,
                title: p.title,
                badgeLabel: p.badgeLabel,
                validUntilText: p.validUntilText,
                termsText: p.termsText,
                tags: p.tags,
                imageUrl: p.imageUrl,
                onViewProducts:
                    p.onViewProducts ?? () => context.go('/catalog'),
              );
            }).toList();

            return _PromotionsListView(
              promotions: promotionsWithCallback,
              viewProductsLabel: viewProductsLabel,
              validUntilTemplate: validUntilTemplate,
              termsApplyTemplate: termsApplyTemplate,
            );
          },
        ),
      ),
    );
  }
}

class _PromotionsLoading extends StatelessWidget {
  const _PromotionsLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          key: ValueKey('promotions_loading_spinner'),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _PromotionsPlaceholder extends StatelessWidget {
  const _PromotionsPlaceholder({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AColors.mutedForeground),
            const SizedBox(height: ASpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ATypography.bodyMd,
              textDirection: Directionality.of(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionsListView extends StatelessWidget {
  const _PromotionsListView({
    required this.promotions,
    required this.viewProductsLabel,
    required this.validUntilTemplate,
    required this.termsApplyTemplate,
  });

  final List<PromotionUiModel> promotions;
  final String viewProductsLabel;
  final String validUntilTemplate;
  final String termsApplyTemplate;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final EdgeInsets resolvedPadding =
        context.pagePadding().resolve(direction) +
            const EdgeInsets.only(bottom: ASpacing.xl);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool useGrid = width >= 720;
        if (!useGrid) {
          return ListView.separated(
            padding: resolvedPadding,
            itemCount: promotions.length,
            separatorBuilder: (_, __) => const SizedBox(height: ASpacing.lg),
            itemBuilder: (context, index) => PromotionCard(
              promotion: promotions[index],
              viewProductsLabel: viewProductsLabel,
              validUntilTemplate: validUntilTemplate,
              termsApplyTemplate: termsApplyTemplate,
            ),
          );
        }

        final int crossAxisCount = width >= 1200 ? 3 : 2;
        final double childAspectRatio = width >= 1200 ? 1.35 : 1.2;

        return GridView.builder(
          padding: resolvedPadding,
          itemCount: promotions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: ASpacing.lg,
            crossAxisSpacing: ASpacing.lg,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => PromotionCard(
            promotion: promotions[index],
            viewProductsLabel: viewProductsLabel,
            validUntilTemplate: validUntilTemplate,
            termsApplyTemplate: termsApplyTemplate,
          ),
        );
      },
    );
  }
}

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    super.key,
    required this.promotion,
    required this.viewProductsLabel,
    required this.validUntilTemplate,
    required this.termsApplyTemplate,
  });

  final PromotionUiModel promotion;
  final String viewProductsLabel;
  final String validUntilTemplate;
  final String termsApplyTemplate;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final BorderRadius borderRadius = ARadii.md;
    final String validUntilText =
        validUntilTemplate.replaceAll('{date}', promotion.validUntilText);
    final String? rawTerms = promotion.termsText?.trim();
    final String? termsText = (rawTerms == null || rawTerms.isEmpty)
        ? null
        : termsApplyTemplate.replaceAll('{terms}', rawTerms);

    return Card(
      key: ValueKey('promotion_card_${promotion.id}'),
      elevation: AElevation.level2,
      shadowColor: const Color(0x11000000),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: const BorderSide(color: AColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: direction,
              children: [
                _PromotionMedia(imageUrl: promotion.imageUrl),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _PromotionBadge(
                          id: promotion.id,
                          label: promotion.badgeLabel,
                        ),
                      ),
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        promotion.title,
                        style: ATypography.titleMd,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        textDirection: direction,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.md),
            Text(
              validUntilText,
              style: ATypography.bodySm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.start,
              textDirection: direction,
            ),
            if (termsText != null) ...[
              const SizedBox(height: ASpacing.xs),
              Text(
                termsText,
                style: ATypography.bodySm.copyWith(
                  color: AColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                textDirection: direction,
              ),
            ],
            if (promotion.tags.isNotEmpty) ...[
              const SizedBox(height: ASpacing.md),
              Wrap(
                spacing: ASpacing.sm,
                runSpacing: ASpacing.xs,
                children: promotion.tags
                    .map((tag) => _PromotionTagChip(label: tag))
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: ASpacing.lg),
            AButton.primary(
              key: ValueKey('promotion_card_cta_${promotion.id}'),
              label: viewProductsLabel,
              expand: true,
              semanticsLabel: viewProductsLabel,
              onPressed: promotion.onViewProducts ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionMedia extends StatelessWidget {
  const _PromotionMedia({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    const double size = 72;
    final BorderRadius borderRadius = ARadii.sm;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(size, borderRadius),
        ),
      );
    }
    return _fallback(size, borderRadius);
  }

  Widget _fallback(double size, BorderRadius borderRadius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AColors.surfaceMuted,
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.local_offer_outlined,
        color: AColors.primaryDark,
        size: 32,
      ),
    );
  }
}

class _PromotionBadge extends StatelessWidget {
  const _PromotionBadge({required this.id, required this.label});

  final String id;
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    return Container(
      key: ValueKey('promotion_card_badge_$id'),
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.md,
        vertical: ASpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AColors.primaryMuted,
        borderRadius: ARadii.pill,
      ),
      child: Text(
        label,
        style: ATypography.chip.copyWith(color: AColors.primaryDark),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textDirection: textDirection,
      ),
    );
  }
}

class _PromotionTagChip extends StatelessWidget {
  const _PromotionTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.md,
        vertical: ASpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AColors.surfaceSubtle,
        borderRadius: ARadii.pill,
        border: const Border.fromBorderSide(
          BorderSide(color: AColors.borderStrong),
        ),
      ),
      child: Text(
        label,
        style: ATypography.bodyXs,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textDirection: textDirection,
      ),
    );
  }
}
