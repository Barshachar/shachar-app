import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/cashback/data/cashback_providers.dart';
import 'package:ashachar_marketplace/src/features/cashback/domain/entities/cashback_models.dart';

/// Customer cashback screen. Shows the ILS balance and ledger movements. When
/// the `cashback_btc` feature flag is enabled it additionally surfaces a
/// display-only BTC equivalent and a "convert" entry point that explains the
/// (not-yet-live) regulated-provider flow.
class CashbackPage extends ConsumerWidget {
  const CashbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    String tr(String key, String fallback) => l10n?.translate(key) ?? fallback;

    final AsyncValue<CashbackSummary> summaryAsync =
        ref.watch(cashbackSummaryProvider);
    final bool btcEnabled = ref.watch(appConfigProvider).maybeWhen(
          data: (AppConfig config) => config.featureEnabled(kCashbackBtcFlag),
          orElse: () => false,
        );
    final EdgeInsets padding =
        context.pagePadding().resolve(Directionality.of(context));

    return Scaffold(
      appBar: AppBar(title: Text(tr('cashbackTitle', 'הזיכויים שלי'))),
      backgroundColor: AColors.background,
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => Center(
          child: Text(tr('cashbackLoadError', 'טעינת הזיכויים נכשלה.')),
        ),
        data: (CashbackSummary summary) => SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _BalanceCard(
                balanceIls: summary.balanceIls,
                btcEnabled: btcEnabled,
                tr: tr,
                ref: ref,
              ),
              const SizedBox(height: 24),
              Text(
                tr('cashbackHistoryTitle', 'תנועות אחרונות'),
                style: ATypography.titleMd,
              ),
              const SizedBox(height: 12),
              if (summary.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    tr('cashbackEmpty', 'עדיין לא צברת זיכויים.'),
                    style: ATypography.bodyLg
                        .copyWith(color: AColors.mutedForeground),
                  ),
                )
              else
                ...summary.entries.map(
                  (CashbackEntry entry) => _EntryTile(entry: entry, tr: tr),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balanceIls,
    required this.btcEnabled,
    required this.tr,
    required this.ref,
  });

  final double balanceIls;
  final bool btcEnabled;
  final String Function(String, String) tr;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final intl.NumberFormat ils =
        intl.NumberFormat.simpleCurrency(name: 'ILS');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140F1A2E),
            blurRadius: 32,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('cashbackBalance', 'יתרת זיכוי'),
              style: ATypography.bodySm.copyWith(color: AColors.mutedForeground),
            ),
            const SizedBox(height: 8),
            Text(ils.format(balanceIls),
                style: ATypography.headline2.copyWith(fontSize: 28)),
            if (btcEnabled) ...<Widget>[
              const SizedBox(height: 16),
              _BtcEquivalent(balanceIls: balanceIls, tr: tr, ref: ref),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () => _showConvertSheet(context, tr),
                  child: Text(tr('cashbackConvertCta', 'המרה לביטקוין')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConvertSheet(
      BuildContext context, String Function(String, String) tr) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(tr('cashbackConvertCta', 'המרה לביטקוין'),
                style: ATypography.titleMd),
            const SizedBox(height: 12),
            Text(
              tr(
                'cashbackComingSoon',
                'המרת הזיכוי לביטקוין תתאפשר בקרוב דרך ספק מוסדר. '
                    'היתרה שלך נשמרת בשקלים, וההמרה תתבצע לפי שער חי בעת הבקשה.',
              ),
              style:
                  ATypography.bodyLg.copyWith(color: AColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class _BtcEquivalent extends StatelessWidget {
  const _BtcEquivalent({
    required this.balanceIls,
    required this.tr,
    required this.ref,
  });

  final double balanceIls;
  final String Function(String, String) tr;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<BtcQuote> rateAsync = ref.watch(btcRateProvider);
    return rateAsync.maybeWhen(
      data: (BtcQuote quote) {
        final double? btc = quote.btcFor(balanceIls);
        if (btc == null) {
          return const SizedBox.shrink();
        }
        final String formatted = btc.toStringAsFixed(8);
        final String prefix = tr('cashbackBtcEquivalent', 'שווה ערך לכ-');
        return Text(
          '$prefix $formatted BTC',
          style: ATypography.bodyLg.copyWith(color: AColors.primary),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.tr});

  final CashbackEntry entry;
  final String Function(String, String) tr;

  @override
  Widget build(BuildContext context) {
    final intl.NumberFormat ils =
        intl.NumberFormat.simpleCurrency(name: 'ILS');
    final intl.DateFormat date = intl.DateFormat('dd/MM/yyyy');
    final bool isCredit = entry.amountIls >= 0;
    final String typeLabel = _typeLabel(entry.type, tr);
    final String sign = isCredit ? '+' : '−';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(entry.note?.isNotEmpty == true ? entry.note! : typeLabel,
                    style: ATypography.bodyLg),
                const SizedBox(height: 4),
                Text(
                  '$typeLabel · ${date.format(entry.createdAt)}',
                  style: ATypography.bodySm
                      .copyWith(color: AColors.mutedForeground),
                ),
              ],
            ),
          ),
          Text(
            '$sign${ils.format(entry.amountIls.abs())}',
            style: ATypography.bodyLg.copyWith(
              fontWeight: FontWeight.w600,
              color: isCredit ? AColors.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(
      CashbackEntryType type, String Function(String, String) tr) {
    switch (type) {
      case CashbackEntryType.earn:
        return tr('cashbackTypeEarn', 'צבירה');
      case CashbackEntryType.redeem:
        return tr('cashbackTypeRedeem', 'מימוש');
      case CashbackEntryType.expire:
        return tr('cashbackTypeExpire', 'פקיעה');
      case CashbackEntryType.adjust:
        return tr('cashbackTypeAdjust', 'התאמה');
    }
  }
}
