import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/offline/queue/offline_queue_observers.dart';
import 'package:ashachar_marketplace/src/offline/sync/sync_scheduler.dart';

class OfflineSyncBanner extends ConsumerStatefulWidget {
  const OfflineSyncBanner({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  ConsumerState<OfflineSyncBanner> createState() => _OfflineSyncBannerState();
}

class _OfflineSyncBannerState extends ConsumerState<OfflineSyncBanner> {
  bool _syncing = false;

  Future<void> _handleSync() async {
    if (_syncing) {
      return;
    }
    setState(() => _syncing = true);
    try {
      await ref.read(syncSchedulerProvider).syncNow();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizedOrDefault('offlineBannerSyncStarted',
                'מנסה לסנכרן את ההזמנות הממתינות...'),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<int> pendingAsync =
        ref.watch(offlineQueuePendingCountProvider);
    return pendingAsync.maybeWhen(
      data: (count) {
        if (count <= 0) {
          return const SizedBox.shrink();
        }
        return _buildBanner(context, count);
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context, int count) {
    final EdgeInsetsGeometry resolvedPadding = widget.padding ??
        const EdgeInsetsDirectional.fromSTEB(
          ASpacing.page,
          ASpacing.sm,
          ASpacing.page,
          0,
        );
    final String title =
        _localizedOrDefault('offlineBannerTitle', 'המערכת עובדת במצב אופליין');
    final String messageTemplate = _localizedOrDefault(
      'offlineBannerBody',
      'יש {count} פעולות ממתינות לסנכרון. ניתן להמשיך לעבוד ורק לאחר חיבור הנתונים יתעדכנו.',
    );
    final String message = messageTemplate.replaceAll('{count}', '$count');
    final String actionLabel = _localizedOrDefault(
      _syncing ? 'offlineBannerSyncing' : 'offlineBannerSyncNow',
      _syncing ? 'מסנכרן...' : 'סנכרן עכשיו',
    );

    return Padding(
      padding: resolvedPadding,
      child: ACard(
        backgroundColor: AColors.warning.withValues(alpha: 0.1),
        borderRadius: ARadii.md,
        padding: const EdgeInsetsDirectional.all(ASpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sync_problem, color: AColors.warning),
                const SizedBox(width: ASpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ATypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AColors.warning,
                        ),
                      ),
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        message,
                        style: ATypography.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ASpacing.sm),
            Wrap(
              spacing: ASpacing.sm,
              runSpacing: ASpacing.xs,
              alignment: WrapAlignment.start,
              children: [
                AButton.secondary(
                  label: actionLabel,
                  icon: Icon(_syncing ? Icons.autorenew : Icons.sync),
                  loading: _syncing,
                  onPressed: _syncing ? null : _handleSync,
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _localizedOrDefault(
                          'offlineBannerInfo',
                          'המערכת תשמור את ההזמנות ותסנכרן אותן כאשר החיבור יחזור.',
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    _localizedOrDefault(
                      'offlineBannerLearnMore',
                      'איך זה עובד?',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _localizedOrDefault(String key, String fallback) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String value = l10n?.translate(key) ?? key;
    return value == key ? fallback : value;
  }
}
