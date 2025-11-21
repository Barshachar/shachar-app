import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:offline_toolkit/src/offline/queue/offline_queue_observers.dart';
import 'package:offline_toolkit/src/offline/sync/sync_scheduler.dart';

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
      final _OfflineBannerStrings strings = _resolveStrings(context, 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.toast)),
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
    final EdgeInsetsGeometry resolvedPadding =
        widget.padding ?? const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0);
    final _OfflineBannerStrings strings = _resolveStrings(context, count);

    return Padding(
      padding: resolvedPadding,
      child: Card(
        color:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sync_problem,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.body,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _syncing ? null : _handleSync,
                    icon: _syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_syncing ? strings.syncing : strings.syncNow),
                  ),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.info)),
                    ),
                    child: Text(strings.learnMore),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _OfflineBannerStrings _resolveStrings(BuildContext context, int count) {
    final Locale locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('he');
    if (locale.languageCode.toLowerCase() == 'he') {
      return _OfflineBannerStrings.he(count);
    }
    return _OfflineBannerStrings.en(count);
  }
}

class _OfflineBannerStrings {
  _OfflineBannerStrings({
    required this.title,
    required this.body,
    required this.syncNow,
    required this.syncing,
    required this.learnMore,
    required this.info,
    required this.toast,
  });

  factory _OfflineBannerStrings.he(int count) {
    return _OfflineBannerStrings(
      title: 'המערכת עובדת במצב אופליין',
      body:
          'יש $count פעולות ממתינות לסנכרון. ניתן להמשיך לעבוד ורק לאחר חיבור הנתונים יתעדכנו.',
      syncNow: 'סנכרן עכשיו',
      syncing: 'מסנכרן...',
      learnMore: 'איך זה עובד?',
      info: 'המערכת תשמור את ההזמנות ותסנכרן אותן כאשר החיבור יחזור.',
      toast: 'מנסה לסנכרן את ההזמנות הממתינות...',
    );
  }

  factory _OfflineBannerStrings.en(int count) {
    return _OfflineBannerStrings(
      title: 'Working offline',
      body:
          'There are $count pending actions. You can keep working and we will sync them once connectivity returns.',
      syncNow: 'Sync now',
      syncing: 'Syncing...',
      learnMore: 'How does it work?',
      info:
          'Your requests stay safe locally and will be synced automatically once a network connection is back.',
      toast: 'Attempting to sync pending actions...',
    );
  }

  final String title;
  final String body;
  final String syncNow;
  final String syncing;
  final String learnMore;
  final String info;
  final String toast;
}
