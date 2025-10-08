import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

@immutable
class SavedListOverview {
  const SavedListOverview({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final int itemCount;
  final DateTime lastUpdated;
}

final Provider<AsyncValue<List<SavedListOverview>>>
    savedListsControllerProvider =
    Provider<AsyncValue<List<SavedListOverview>>>(
  (ref) => const AsyncLoading<List<SavedListOverview>>(),
);

class SavedListsPage extends ConsumerWidget {
  const SavedListsPage({super.key});

  static const Color _background = Color(0xFF0B121C);
  static const Color _cardColor = Color(0xFF152233);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<List<SavedListOverview>> savedListsAsync =
        ref.watch(savedListsControllerProvider);

    return Scaffold(
      key: const ValueKey('saved_list_root'),
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: Text(
          l10n?.translate('savedListsTitle') ?? 'Saved Lists',
          style: ATypography.titleMd.copyWith(color: Colors.white),
        ),
        actions: const [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.white),
            onPressed: null,
          ),
          SizedBox(width: ASpacing.sm),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: null,
          ),
          SizedBox(width: ASpacing.sm),
        ],
      ),
      body: savedListsAsync.when(
        loading: () => const _SavedListsLoading(background: _background),
        error: (Object error, _) => _SavedListsError(
          message: error.toString(),
          l10n: l10n,
          onRetry: () => ref.invalidate(savedListsControllerProvider),
          background: _background,
        ),
        data: (List<SavedListOverview> lists) => lists.isEmpty
            ? _SavedListsEmpty(l10n: l10n, background: _background)
            : _SavedListsContent(
                lists: lists,
                l10n: l10n,
                background: _background,
                cardColor: _cardColor,
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
        label: Text(l10n?.translate('newList') ?? 'New List'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _SavedListsLoading extends StatelessWidget {
  const _SavedListsLoading({required this.background});

  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        key: ValueKey('saved_lists_loading_spinner'),
      ),
    );
  }
}

class _SavedListsEmpty extends StatelessWidget {
  const _SavedListsEmpty({required this.l10n, required this.background});

  final MarketplaceLocalizations? l10n;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final String title =
        l10n?.translate('savedListsEmptyTitle') ?? 'No saved lists yet';
    final String message = l10n?.translate('savedListsEmptyMessage') ??
        'Create lists to quickly add repeat items.';
    return Container(
      key: const ValueKey('saved_lists_empty_state'),
      color: background,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.list_alt_outlined, color: Colors.white, size: 48),
          const SizedBox(height: ASpacing.lg),
          Text(
            title,
            style: ATypography.titleSm.copyWith(color: Colors.white),
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            message,
            style: ATypography.bodySm
                .copyWith(color: Colors.white.withValues(alpha: .7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SavedListsError extends StatelessWidget {
  const _SavedListsError({
    required this.message,
    required this.l10n,
    required this.onRetry,
    required this.background,
  });

  final String message;
  final MarketplaceLocalizations? l10n;
  final VoidCallback onRetry;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final String title =
        l10n?.translate('savedListsErrorTitle') ?? 'Saved lists unavailable';
    final String retryLabel = l10n?.translate('ordersRetry') ?? 'Try again';
    return Container(
      key: const ValueKey('saved_lists_error_state'),
      color: background,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: ASpacing.lg),
          Text(
            title,
            style: ATypography.titleSm.copyWith(color: Colors.white),
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            message,
            style: ATypography.bodySm
                .copyWith(color: Colors.white.withValues(alpha: .7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ASpacing.lg),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: background,
            ),
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

class _SavedListsContent extends StatelessWidget {
  const _SavedListsContent({
    required this.lists,
    required this.l10n,
    required this.background,
    required this.cardColor,
  });

  final List<SavedListOverview> lists;
  final MarketplaceLocalizations? l10n;
  final Color background;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String localeName =
        locale.countryCode == null || locale.countryCode!.isEmpty
            ? locale.languageCode
            : '${locale.languageCode}_${locale.countryCode}';
    final intl.DateFormat dateFormat =
        intl.DateFormat.yMMMd(localeName).add_Hm();
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsetsGeometry padding = context.pagePadding();
    final String addAllLabel = l10n?.translate('addAll') ?? 'Add all';
    final String itemsCountTemplate =
        l10n?.translate('itemsCount') ?? '{count} items';
    final String lastUpdatedTemplate =
        l10n?.translate('lastUpdated') ?? 'Last updated {timestamp}';
    final String snackbarTemplate =
        l10n?.translate('savedListsAddAllSuccess') ??
            'Added all {itemCount} items from "{listName}"';

    return Container(
      color: background,
      child: ListView.separated(
        padding: padding,
        itemCount: lists.length,
        separatorBuilder: (_, __) => const SizedBox(height: ASpacing.lg),
        itemBuilder: (BuildContext context, int index) {
          final SavedListOverview list = lists[index];
          final String itemsCountLabel = itemsCountTemplate.replaceAll(
              '{count}', list.itemCount.toString());
          final String formattedDate =
              dateFormat.format(list.lastUpdated.toLocal());
          final String lastUpdatedLabel =
              lastUpdatedTemplate.replaceAll('{timestamp}', formattedDate);

          return Container(
            key: ValueKey<String>('saved_list_card_${list.id}'),
            padding: const EdgeInsets.all(ASpacing.lg),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list.name,
                  style: ATypography.titleSm.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textDirection: textDirection,
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  itemsCountLabel,
                  style: ATypography.bodySm.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textDirection: textDirection,
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  lastUpdatedLabel,
                  style: ATypography.bodySm.copyWith(color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  textDirection: textDirection,
                ),
                const SizedBox(height: ASpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.ios_share, color: Colors.white70),
                      onPressed: () {},
                    ),
                    Semantics(
                      key: const ValueKey('saved_list_add_all_btn'),
                      button: true,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        key: ValueKey<String>(
                            'saved_list_add_all_btn_${list.id}'),
                        onPressed: () {
                          final String message = snackbarTemplate
                              .replaceAll(
                                  '{itemCount}', list.itemCount.toString())
                              .replaceAll('{listName}', list.name);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              key: const ValueKey(
                                  'saved_list_add_all_result_snackbar'),
                              content: Text(
                                message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textDirection: textDirection,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: Text(
                          addAllLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textDirection: textDirection,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
