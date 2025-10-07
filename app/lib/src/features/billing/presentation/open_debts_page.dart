import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

final openDebtsSummaryProvider = FutureProvider<OpenDebtsSummary>((ref) async {
  return OpenDebtsSummary(
    totalDue: 12850.00,
    buckets: <OpenDebtBucket>[
      OpenDebtBucket(keySuffix: '0_30', label: '0-30', amount: 4820.00),
      OpenDebtBucket(keySuffix: '31_60', label: '31-60', amount: 3460.00),
      OpenDebtBucket(keySuffix: '61_90', label: '61-90', amount: 2710.00),
      OpenDebtBucket(keySuffix: '90_plus', label: '90+', amount: 2859.50),
    ],
  );
});

final openInvoicesProvider = FutureProvider<List<BillingInvoice>>((ref) async {
  return <BillingInvoice>[
    BillingInvoice(
      id: 'inv_1024',
      number: 'INV-1024',
      dueDate: DateTime(2024, 5, 3),
      amount: 4820.00,
    ),
    BillingInvoice(
      id: 'inv_1025',
      number: 'INV-1025',
      dueDate: DateTime(2024, 5, 17),
      amount: 3460.00,
    ),
    BillingInvoice(
      id: 'inv_1033',
      number: 'INV-1033',
      dueDate: DateTime(2024, 6, 2),
      amount: 2710.00,
    ),
  ];
});

class OpenDebtsSummary {
  const OpenDebtsSummary({
    required this.totalDue,
    required this.buckets,
  });

  final double totalDue;
  final List<OpenDebtBucket> buckets;

  bool get isEmpty =>
      totalDue == 0 &&
      buckets.every((OpenDebtBucket bucket) => bucket.amount == 0);
}

class OpenDebtBucket {
  const OpenDebtBucket({
    required this.keySuffix,
    required this.label,
    required this.amount,
  });

  final String keySuffix;
  final String label;
  final double amount;
}

class BillingInvoice {
  const BillingInvoice({
    required this.id,
    required this.number,
    required this.dueDate,
    required this.amount,
  });

  final String id;
  final String number;
  final DateTime dueDate;
  final double amount;
}

class OpenDebtsPage extends ConsumerWidget {
  const OpenDebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );

    final AsyncValue<OpenDebtsSummary> summaryAsync =
        ref.watch(openDebtsSummaryProvider);
    final AsyncValue<List<BillingInvoice>> invoicesAsync =
        ref.watch(openInvoicesProvider);

    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsets padding = context.pagePadding().resolve(textDirection);
    final EdgeInsets scrollPadding =
        padding + const EdgeInsets.only(bottom: ASpacing.xxl);

    return Scaffold(
      key: const ValueKey('open_debts_root'),
      appBar: AppBar(
        title: Text(l10n?.translate('billingTitle') ?? 'Billing'),
      ),
      body: SingleChildScrollView(
        padding: scrollPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.translate('openDebtsTitle') ?? 'Open debts',
              style: ATypography.titleLg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textDirection: textDirection,
            ),
            const SizedBox(height: ASpacing.md),
            OpenDebtsSummarySection(
              summaryAsync: summaryAsync,
              l10n: l10n,
            ),
            const SizedBox(height: ASpacing.xl),
            Text(
              l10n?.translate('invoicesTitle') ?? 'Invoices',
              style: ATypography.titleLg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textDirection: textDirection,
            ),
            const SizedBox(height: ASpacing.md),
            OpenDebtsInvoicesSection(
              invoicesAsync: invoicesAsync,
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }
}

class OpenDebtsSummarySection extends StatelessWidget {
  const OpenDebtsSummarySection({
    super.key,
    required this.summaryAsync,
    required this.l10n,
  });

  final AsyncValue<OpenDebtsSummary> summaryAsync;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String localeName = _resolveLocale(context);
    final intl.NumberFormat currencyFormat =
        intl.NumberFormat.simpleCurrency(locale: localeName);
    final TextDirection textDirection = Directionality.of(context);

    return summaryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: ASpacing.lg),
        child: Center(
          child: CircularProgressIndicator(
            key: ValueKey('open_debts_loading_spinner'),
          ),
        ),
      ),
      error: (Object error, _) => _SummaryErrorState(
        error: error,
        l10n: l10n,
      ),
      data: (OpenDebtsSummary summary) {
        if (summary.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: ASpacing.lg),
            child: AStateMessage(
              key: const ValueKey('open_debts_empty_state'),
              icon: Icons.receipt_long_outlined,
              title: l10n?.translate('openDebtsEmpty') ?? 'All clear',
              message: l10n?.translate('openDebtsEmptyHint') ??
                  'No outstanding balances at the moment.',
            ),
          );
        }

        final String totalLabel = currencyFormat.format(summary.totalDue);
        final String downloadLabel =
            l10n?.translate('openDebtsDownloadStatement') ??
                '${l10n?.translate('download') ?? 'Download'} '
                    '${l10n?.translate('statement') ?? 'statement'}';

        return ACard(
          key: const ValueKey('open_debts_summary_card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.translate('totalDue') ?? 'Total due',
                          style: ATypography.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textDirection: textDirection,
                        ),
                        const SizedBox(height: ASpacing.xs),
                        Text(
                          totalLabel,
                          style: ATypography.headline2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textDirection: textDirection,
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: downloadLabel,
                    button: true,
                    child: TextButton.icon(
                      key: const ValueKey('open_debts_export_btn'),
                      onPressed: () {},
                      icon: const Icon(Icons.file_download_outlined),
                      label: Text(
                        downloadLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textDirection: textDirection,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ASpacing.lg),
              Text(
                l10n?.translate('aging') ?? 'Aging',
                style: ATypography.titleSm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: textDirection,
              ),
              const SizedBox(height: ASpacing.sm),
              Wrap(
                key: const ValueKey('open_debts_aging_buckets'),
                spacing: ASpacing.lg,
                runSpacing: ASpacing.lg,
                children: summary.buckets
                    .map((OpenDebtBucket bucket) => _AgingBucketTile(
                          bucket: bucket,
                          currencyFormat: currencyFormat,
                          l10n: l10n,
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryErrorState extends StatelessWidget {
  const _SummaryErrorState({
    required this.error,
    required this.l10n,
  });

  final Object error;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ASpacing.lg),
      child: AStateMessage(
        key: const ValueKey('open_debts_error_state'),
        icon: Icons.error_outline,
        title: l10n?.translate('openDebtsError') ?? 'Unable to load balances',
        message: error.toString(),
        primaryLabel: l10n?.translate('export') ?? 'Export',
        onPrimaryPressed: () {},
      ),
    );
  }
}

class _AgingBucketTile extends StatelessWidget {
  const _AgingBucketTile({
    required this.bucket,
    required this.currencyFormat,
    required this.l10n,
  });

  final OpenDebtBucket bucket;
  final intl.NumberFormat currencyFormat;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final String labelKey = 'openDebtsBucket_${bucket.keySuffix}';
    final String bucketLabel = l10n?.translate(labelKey) ?? bucket.label;
    final String value = currencyFormat.format(bucket.amount);

    return ACard(
      key: ValueKey('open_debts_bucket_${bucket.keySuffix}'),
      elevation: AElevation.level0,
      backgroundColor: AColors.surfaceSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bucketLabel,
            style: ATypography.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textDirection: textDirection,
          ),
          const SizedBox(height: ASpacing.xs),
          Text(
            value,
            style: ATypography.titleLg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }
}

class OpenDebtsInvoicesSection extends StatelessWidget {
  const OpenDebtsInvoicesSection({
    super.key,
    required this.invoicesAsync,
    required this.l10n,
  });

  final AsyncValue<List<BillingInvoice>> invoicesAsync;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String localeName = _resolveLocale(context);
    final intl.NumberFormat currencyFormat =
        intl.NumberFormat.simpleCurrency(locale: localeName);
    final String fallbackDateLocale =
        intl.DateFormat.localeExists(localeName) ? localeName : 'en';
    final intl.DateFormat dateFormat =
        intl.DateFormat.yMMMd(fallbackDateLocale);
    final TextDirection textDirection = Directionality.of(context);

    return invoicesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: ASpacing.lg),
        child: Center(
          child: CircularProgressIndicator(
            key: ValueKey('invoices_loading_spinner'),
          ),
        ),
      ),
      error: (Object error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: ASpacing.lg),
        child: AStateMessage(
          key: const ValueKey('invoices_error_state'),
          icon: Icons.error_outline,
          title: l10n?.translate('invoicesError') ?? 'Invoices unavailable',
          message: error.toString(),
          primaryLabel: l10n?.translate('export') ?? 'Export',
          onPrimaryPressed: () {},
        ),
      ),
      data: (List<BillingInvoice> invoices) {
        if (invoices.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: ASpacing.lg),
            child: AStateMessage(
              key: const ValueKey('invoices_empty_state'),
              icon: Icons.receipt_long_outlined,
              title: l10n?.translate('invoicesEmpty') ?? 'No open invoices',
              message: l10n?.translate('invoicesEmptyHint') ??
                  'Once invoices are issued they will appear here.',
            ),
          );
        }

        return ListView.separated(
          key: const ValueKey('invoices_list_root'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length,
          separatorBuilder: (_, __) => const SizedBox(height: ASpacing.sm),
          itemBuilder: (BuildContext context, int index) {
            final BillingInvoice invoice = invoices[index];
            final String amountLabel = currencyFormat.format(invoice.amount);
            final String dueLabel = dateFormat.format(invoice.dueDate);
            return ACard(
              key: ValueKey('open_debts_invoice_${invoice.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.number,
                              style: ATypography.titleSm,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              textDirection: textDirection,
                            ),
                            const SizedBox(height: ASpacing.xs),
                            Text(
                              dueLabel,
                              style: ATypography.bodyMd.copyWith(
                                color: AColors.neutral500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              textDirection: textDirection,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        amountLabel,
                        style: ATypography.titleSm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textDirection: textDirection,
                      ),
                    ],
                  ),
                  const SizedBox(height: ASpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Semantics(
                      label: l10n?.translate('download') ?? 'Download',
                      button: true,
                      child: TextButton.icon(
                        key: ValueKey('invoice_download_btn_${invoice.id}'),
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined),
                        label: Text(
                          l10n?.translate('download') ?? 'Download',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textDirection: textDirection,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

String _resolveLocale(BuildContext context) {
  final Locale locale = Localizations.localeOf(context);
  final String localeName = locale.toString();
  if (intl.DateFormat.localeExists(localeName)) {
    return localeName;
  }
  if (intl.DateFormat.localeExists(locale.languageCode)) {
    return locale.languageCode;
  }
  return 'en';
}
