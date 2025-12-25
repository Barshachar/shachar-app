import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/ratings/data/vendor_rating_providers.dart';
import 'package:ashachar_marketplace/src/features/ratings/data/supabase_vendor_rating_repository.dart';
import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating.dart';
import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating_repository.dart';

class VendorRatingTarget {
  const VendorRatingTarget({
    required this.vendorId,
    required this.vendorName,
  });

  final String vendorId;
  final String vendorName;
}

class OrderVendorRatingSection extends StatelessWidget {
  const OrderVendorRatingSection({
    super.key,
    required this.orderId,
    required this.vendors,
  });

  final String orderId;
  final List<VendorRatingTarget> vendors;

  @override
  Widget build(BuildContext context) {
    if (vendors.isEmpty) {
      return const SizedBox.shrink();
    }
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title =
        l10n?.translate('orderRatingTitle') ?? 'Rate your vendors';
    final String subtitle = l10n?.translate('orderRatingSubtitle') ??
        'Help other buyers by sharing your feedback.';

    return Column(
      key: const ValueKey<String>('order_vendor_rating_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ATypography.titleMd),
        const SizedBox(height: ASpacing.xs),
        Text(
          subtitle,
          style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
        ),
        const SizedBox(height: ASpacing.lg),
        ...vendors.map(
          (VendorRatingTarget vendor) => Padding(
            padding: const EdgeInsets.only(bottom: ASpacing.lg),
            child: _VendorRatingCard(orderId: orderId, vendor: vendor),
          ),
        ),
      ],
    );
  }
}

class _VendorRatingCard extends ConsumerStatefulWidget {
  const _VendorRatingCard({
    required this.orderId,
    required this.vendor,
  });

  final String orderId;
  final VendorRatingTarget vendor;

  @override
  ConsumerState<_VendorRatingCard> createState() => _VendorRatingCardState();
}

class _VendorRatingCardState extends ConsumerState<_VendorRatingCard> {
  final TextEditingController _commentController = TextEditingController();
  int? _selectedRating;
  bool _submitting = false;
  bool _queued = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final VendorOrderRatingRequest request = VendorOrderRatingRequest(
      orderId: widget.orderId,
      vendorCompanyId: widget.vendor.vendorId,
    );
    final AsyncValue<VendorRating?> ratingAsync =
        ref.watch(vendorOrderRatingProvider(request));
    final AsyncValue<VendorRatingSummary?> summaryAsync =
        ref.watch(vendorRatingSummaryProvider(widget.vendor.vendorId));

    final VendorRating? existingRating =
        ratingAsync.whenOrNull(data: (value) => value);
    final bool hasRating = existingRating != null;
    final bool isQueued = _queued && !hasRating;
    final int displayedRating = existingRating?.rating ?? _selectedRating ?? 0;
    final String cardTitle = widget.vendor.vendorName.isNotEmpty
        ? widget.vendor.vendorName
        : widget.vendor.vendorId;

    final String summaryText = summaryAsync.when(
      data: (VendorRatingSummary? summary) {
        if (summary == null || summary.ratingsCount == 0) {
          return l10n?.translate('orderRatingEmptySummary') ?? 'No ratings yet';
        }
        final String template =
            l10n?.translate('orderRatingSummary') ?? '{avg} · {count} ratings';
        return template
            .replaceAll('{avg}', summary.averageRating.toStringAsFixed(1))
            .replaceAll('{count}', summary.ratingsCount.toString());
      },
      loading: () =>
          l10n?.translate('orderRatingLoadingSummary') ?? 'Loading ratings…',
      error: (_, __) =>
          l10n?.translate('orderRatingSummaryError') ?? 'Ratings unavailable',
    );

    final String queuedMessage = l10n?.translate('orderRatingQueued') ??
        'Saved offline. We\'ll submit when you\'re back online.';
    final String submittedMessage =
        l10n?.translate('orderRatingSubmitted') ?? 'Thanks for your feedback.';

    return Container(
      key: ValueKey<String>(
          'order_vendor_rating_card_${widget.vendor.vendorId}'),
      padding: const EdgeInsets.all(ASpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AColors.neutral200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cardTitle, style: ATypography.titleSm),
          const SizedBox(height: ASpacing.xs),
          Text(
            summaryText,
            style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
          ),
          const SizedBox(height: ASpacing.md),
          _StarRow(
            keyPrefix: 'order_vendor_rating_star_${widget.vendor.vendorId}',
            rating: displayedRating,
            enabled: !hasRating && !isQueued && !_submitting,
            onSelected: (int value) {
              setState(() {
                _selectedRating = value;
              });
            },
          ),
          if (hasRating) ...[
            const SizedBox(height: ASpacing.sm),
            Text(submittedMessage, style: ATypography.bodySm),
          ] else if (isQueued) ...[
            const SizedBox(height: ASpacing.sm),
            Text(
              queuedMessage,
              style:
                  ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
          ] else ...[
            const SizedBox(height: ASpacing.md),
            TextField(
              key: ValueKey<String>(
                  'order_vendor_rating_comment_${widget.vendor.vendorId}'),
              controller: _commentController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n?.translate('orderRatingCommentLabel') ??
                    'Comment (optional)',
                hintText: l10n?.translate('orderRatingCommentHint') ??
                    'Share what worked well or what to improve.',
              ),
            ),
            const SizedBox(height: ASpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: ValueKey<String>(
                    'order_vendor_rating_submit_${widget.vendor.vendorId}'),
                onPressed: _submitting || _selectedRating == null
                    ? null
                    : () => _submitRating(context, request),
                child: Text(
                  l10n?.translate('orderRatingSubmit') ?? 'Submit rating',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitRating(
    BuildContext context,
    VendorOrderRatingRequest request,
  ) async {
    if (_selectedRating == null) {
      return;
    }
    setState(() {
      _submitting = true;
    });
    final VendorRatingRepository repository =
        ref.read(vendorRatingRepositoryProvider);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      final VendorRatingSubmission result = await repository.submitRating(
        orderId: widget.orderId,
        vendorCompanyId: widget.vendor.vendorId,
        rating: _selectedRating!,
        comment: _commentController.text,
      );

      if (!mounted) {
        return;
      }

      if (result.queued) {
        setState(() {
          _queued = true;
        });
        final String message = l10n?.translate('orderRatingQueued') ??
            'Saved offline. We\'ll submit when you\'re back online.';
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      } else {
        final String message = l10n?.translate('orderRatingSubmitted') ??
            'Thanks for your feedback.';
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        ref.invalidate(vendorOrderRatingProvider(request));
        ref.invalidate(vendorRatingSummaryProvider(widget.vendor.vendorId));
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback =
          l10n?.translate('orderRatingError') ?? 'Unable to submit rating.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$fallback $error')));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.keyPrefix,
    required this.rating,
    required this.enabled,
    required this.onSelected,
  });

  final String keyPrefix;
  final int rating;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (int index) {
        final int value = index + 1;
        final bool filled = rating >= value;
        return IconButton(
          key: ValueKey<String>('$keyPrefix-$value'),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: enabled ? () => onSelected(value) : null,
          tooltip: '$value',
        );
      }),
    );
  }
}
