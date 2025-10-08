import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/presentation/status_tokens.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';

typedef RfqSendMessageAction = Future<void> Function({
  required String rfqId,
  required String text,
});

Future<void> _defaultRfqSendMessageAction({
  required String rfqId,
  required String text,
}) async {}

final rfqSendMessageActionProvider = Provider<RfqSendMessageAction>((ref) {
  return _defaultRfqSendMessageAction;
});

bool _isDefaultRfqSendMessageAction(RfqSendMessageAction action) {
  return identical(action, _defaultRfqSendMessageAction);
}

// UI-only resubmit action hook (tests can override). No-op by default.
typedef RfqResubmitAction = Future<void> Function({required String rfqId});

Future<void> _defaultResubmitAction({required String rfqId}) async {}

final rfqResubmitActionProvider = Provider<RfqResubmitAction>((ref) {
  return _defaultResubmitAction;
});

bool _isDefaultResubmitAction(RfqResubmitAction action) {
  return identical(action, _defaultResubmitAction);
}

class CustomerRfqsPage extends ConsumerWidget {
  const CustomerRfqsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RfqSummary>> rfqs = ref.watch(customerRfqsProvider);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    final DateFormat dateFormat = DateFormat.yMMMMd('he_IL').add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.translate('rfqListTitle') ?? 'Requests for quotes'),
      ),
      body: rfqs.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('rfq_loading_spinner'),
          ),
        ),
        error: (Object error, _) => _ErrorState(
          key: const ValueKey('rfq_error_state'),
          error: error,
          l10n: l10n,
          onRetry: () => ref.invalidate(customerRfqsProvider),
        ),
        data: (List<RfqSummary> items) {
          if (items.isEmpty) {
            return _EmptyState(
              key: const ValueKey('rfq_empty_state'),
              l10n: l10n,
              onCreate: () => GoRouter.of(context).go('/customer/cart'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(customerRfqsProvider.future),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final RfqSummary summary = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: ARadii.md,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            CustomerRfqDetailPage(rfqId: summary.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(ASpacing.md),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final bool stack = constraints.maxWidth < 360;

                          final Widget details = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.displayReference,
                                style: ATypography.titleSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                              const SizedBox(height: ASpacing.xs),
                              _StatusInline(
                                label: l10n?.translate('rfqListStatusLabel') ??
                                    (l10n?.translate('statusLabel') ??
                                        'Status'),
                                status: summary.status,
                                l10n: l10n,
                              ),
                              const SizedBox(height: ASpacing.xs),
                              Text(
                                '${l10n?.translate('rfqLastUpdatedLabel') ?? 'Created at'} '
                                '${dateFormat.format(summary.createdAt.toLocal())}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: ATypography.bodySm,
                              ),
                              if (summary.itemCount != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: ASpacing.xs),
                                  child: Text(
                                    '${l10n?.translate('rfqItemCountLabel') ?? 'Item count'}: ${summary.itemCount}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: ATypography.bodySm,
                                  ),
                                ),
                              if (summary.quoteCount != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: ASpacing.xs),
                                  child: Text(
                                    '${l10n?.translate('rfqQuoteCountLabel') ?? 'Quotes received'}: ${summary.quoteCount}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: ATypography.bodySm,
                                  ),
                                ),
                              if (summary.latestQuoteStatus != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: ASpacing.xs),
                                  child: _StatusInline(
                                    label: l10n?.translate(
                                            'rfqLatestQuoteStatusLabel') ??
                                        'Latest quote status',
                                    status: summary.latestQuoteStatus!,
                                    l10n: l10n,
                                    compact: true,
                                  ),
                                ),
                            ],
                          );

                          final Widget chevron = Icon(
                            context.isRtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: AColors.neutral400,
                          );

                          if (stack) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                details,
                                const SizedBox(height: ASpacing.sm),
                                Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: chevron,
                                ),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: details),
                              const SizedBox(width: ASpacing.md),
                              chevron,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('rfq_create_btn'),
        onPressed: () => GoRouter.of(context).go('/customer/cart'),
        icon: const Icon(Icons.add_comment_outlined),
        label: Text(l10n?.translate('rfqCreateCta') ?? 'New RFQ'),
      ),
    );
  }
}

class CustomerRfqDetailPage extends ConsumerStatefulWidget {
  const CustomerRfqDetailPage({required this.rfqId, super.key});

  final String rfqId;

  @override
  ConsumerState<CustomerRfqDetailPage> createState() =>
      _CustomerRfqDetailPageState();
}

class _CustomerRfqDetailPageState extends ConsumerState<CustomerRfqDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _sendingMessage = false;
  String? _messageError;
  bool _resubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RfqDetail> detailAsync =
        ref.watch(rfqDetailProvider(widget.rfqId));
    final ThemeData theme = Theme.of(context);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    final DateFormat dateFormat = DateFormat.yMMMMd('he_IL').add_Hm();

    return KeyedSubtree(
      key: const ValueKey('rfq_detail_root'),
      child: Scaffold(
        key: const ValueKey('customer_rfq_detail_scaffold'),
        appBar: AppBar(
          title: Text(
              'RFQ #${widget.rfqId.substring(0, widget.rfqId.length > 6 ? 6 : widget.rfqId.length)}'),
        ),
        body: detailAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              key: ValueKey('rfq_loading_spinner'),
            ),
          ),
          error: (Object error, _) => _ErrorState(
            key: const ValueKey('rfq_error_state'),
            error: error,
            l10n: l10n,
            onRetry: () => ref.invalidate(rfqDetailProvider(widget.rfqId)),
          ),
          data: (RfqDetail detail) {
            final RfqResubmitAction resubmitAction =
                ref.watch(rfqResubmitActionProvider);
            final bool hasCustomResubmit =
                !_isDefaultResubmitAction(resubmitAction);
            final bool canResubmit =
                hasCustomResubmit && _isResubmittableStatus(detail.status);
            return RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(rfqDetailProvider(widget.rfqId).future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusInline(
                            label: l10n?.translate(
                                  'rfqCustomerStatusLabel',
                                ) ??
                                (l10n?.translate('statusLabel') ?? 'Status'),
                            status: detail.status,
                            l10n: l10n,
                            labelStyle: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${l10n?.translate('rfqLastUpdatedLabel') ?? 'Created at'} '
                            '${dateFormat.format(detail.createdAt.toLocal())}',
                          ),
                          if (detail.needBy != null)
                            Text(
                              '${l10n?.translate('rfqNeedByLabel') ?? 'Need by'} '
                              '${dateFormat.format(detail.needBy!.toLocal())}',
                            ),
                          if (detail.terms != null && detail.terms!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${l10n?.translate('rfqQuoteTermsLabel') ?? 'Terms'}: ${detail.terms}',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (canResubmit) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton.icon(
                        key: const ValueKey('rfq_resubmit_btn'),
                        onPressed: _resubmitting
                            ? null
                            : () => _handleResubmit(resubmitAction),
                        icon: _resubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_outlined),
                        label: Text(
                          l10n?.translate('rfqResubmit') ??
                              'Resend for approval',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    l10n?.translate('rfqItemsSectionTitle') ?? 'Items',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final RfqItem item in detail.items)
                    Card(
                      child: ListTile(
                        title: Text(
                          item.description ??
                              item.sku ??
                              (l10n?.translate('rfqItemFallbackLabel') ??
                                  'Unnamed item'),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(() {
                              final String unit = (item.uom ?? '').trim();
                              final String base =
                                  '${l10n?.translate('rfqItemQuantityLabel') ?? 'Quantity'}: ${item.qty.toStringAsFixed(2)}';
                              return unit.isEmpty ? base : '$base $unit';
                            }()),
                            if (item.customerNotes != null &&
                                item.customerNotes!.isNotEmpty)
                              Text(
                                '${l10n?.translate('rfqItemNotesLabel') ?? 'Notes'}: ${item.customerNotes}',
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.translate('rfqQuoteSectionTitle') ??
                        'Received quotes',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (detail.quotes.isEmpty)
                    Card(
                      child: ListTile(
                        title: Text(
                          l10n?.translate('rfqQuotesEmpty') ?? 'No quotes yet',
                        ),
                        subtitle: Text(
                          l10n?.translate('rfqQuotesEmptyHint') ??
                              'Suppliers have not responded yet',
                        ),
                      ),
                    )
                  else
                    for (final RfqQuote quote in detail.quotes)
                      _QuoteCard(
                        quote: quote,
                        l10n: l10n,
                        onAccept: () => _acceptQuote(quote.id),
                      ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.translate('rfqMessagesSectionTitle') ??
                        'Questions & updates',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KeyedSubtree(
                            key: const ValueKey('rfq_messages_list'),
                            child: detail.messages.isEmpty
                                ? Text(
                                    l10n?.translate('rfqMessagesEmpty') ??
                                        'No messages yet',
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final RfqMessage message
                                          in detail.messages)
                                        KeyedSubtree(
                                          key: ValueKey(
                                              'rfq_message_item_${message.id}'),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _authorLabel(
                                                    message.authorRole,
                                                    l10n,
                                                  ),
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                          color:
                                                              Colors.grey[600]),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(message.body),
                                                const SizedBox(height: 4),
                                                Text(
                                                  dateFormat.format(message
                                                      .createdAt
                                                      .toLocal()),
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                          color:
                                                              Colors.grey[500]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                          const Divider(),
                          TextField(
                            key: const ValueKey('rfq_message_input'),
                            controller: _messageController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText:
                                  l10n?.translate('rfqSendMessageLabel') ??
                                      'New message',
                              errorText: _messageError,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              key: const ValueKey('rfq_message_send_btn'),
                              onPressed: _sendingMessage ? null : _sendMessage,
                              icon: _sendingMessage
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        key: ValueKey('rfq_message_sending'),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send_outlined),
                              label: Text(
                                l10n?.translate('rfqSendMessage') ??
                                    'Send to vendor',
                              ),
                            ),
                          ),
                          if (_messageError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _messageError!,
                              key: const ValueKey('rfq_message_send_error'),
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _authorLabel(
    String? authorRole,
    MarketplaceLocalizations? l10n,
  ) {
    switch (authorRole) {
      case 'vendor':
        return l10n?.translate('rfqMessageAuthorVendor') ?? 'Vendor reply';
      case 'admin':
        return l10n?.translate('rfqMessageAuthorAdmin') ?? 'System';
      default:
        return l10n?.translate('rfqMessageAuthorCustomer') ??
            'Customer message';
    }
  }

  Future<void> _handleResubmit(RfqResubmitAction action) async {
    setState(() {
      _resubmitting = true;
    });
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    try {
      await action(rfqId: widget.rfqId);
      ref
        ..invalidate(customerRfqsProvider)
        ..invalidate(rfqDetailProvider(widget.rfqId));
    } on Object catch (error) {
      if (mounted) {
        final ScaffoldMessengerState messenger =
            ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${l10n?.translate('rfqResubmitFailed') ?? 'Failed to resend for approval'}: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _resubmitting = false;
        });
      }
    }
  }

  bool _isResubmittableStatus(String status) {
    final String normalized = status.trim().toLowerCase();
    return normalized == 'rejected' ||
        normalized == 'rejected_by_vendor' ||
        normalized == 'vendor_rejected';
  }

  Future<void> _sendMessage() async {
    final String body = _messageController.text.trim();
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    if (body.isEmpty) {
      setState(() {
        _messageError =
            l10n?.translate('rfqMessageErrorEmpty') ?? 'Enter a message';
      });
      return;
    }
    final RfqSendMessageAction sendAction =
        ref.read(rfqSendMessageActionProvider);
    setState(() {
      _messageError = null;
      _sendingMessage = true;
    });
    try {
      await sendAction(rfqId: widget.rfqId, text: body);
      if (_isDefaultRfqSendMessageAction(sendAction)) {
        await ref
            .read(rfqActionControllerProvider)
            .postMessage(rfqId: widget.rfqId, body: body);
      }
      if (!mounted) {
        return;
      }
      _messageController.clear();
      ref.invalidate(rfqDetailProvider(widget.rfqId));
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          final String base = l10n?.translate('rfqMessageSendFailed') ??
              'Failed to send message';
          _messageError = '$base: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _sendingMessage = false;
        });
      }
    }
  }

  Future<void> _acceptQuote(String quoteId) async {
    setState(() {
      _messageError = null;
    });
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    try {
      final String orderId =
          await ref.read(rfqActionControllerProvider).acceptQuote(quoteId);
      if (!mounted) {
        return;
      }
      final GoRouter? router = GoRouter.maybeOf(context);
      if (router != null) {
        router.go('/customer/orders/$orderId');
      } else {
        Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
      }
    } on Object catch (error) {
      final ScaffoldMessengerState messenger =
          ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n?.translate('rfqAcceptQuoteFailed') ?? 'Failed to accept quote'}: $error',
          ),
        ),
      );
    }
  }
}

class _StatusInline extends StatelessWidget {
  const _StatusInline({
    required this.label,
    required this.status,
    required this.l10n,
    this.labelStyle,
    this.compact = false,
  });

  final String label;
  final String status;
  final MarketplaceLocalizations? l10n;
  final TextStyle? labelStyle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedLabelStyle = labelStyle ?? ATypography.bodySm;
    final String statusLabel = resolveStatusLabel(status: status, l10n: l10n);

    return Wrap(
      spacing: ASpacing.xs,
      runSpacing: ASpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$label:',
          style: resolvedLabelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        AStatusChip(
          statusCode: status,
          label: statusLabel,
          dense: compact,
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.onAccept,
    required this.l10n,
  });

  final RfqQuote quote;
  final VoidCallback onAccept;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.yMMMMd('he_IL').add_Hm();
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'he_IL', symbol: '₪');
    final bool isExpired = _isQuoteExpired(quote);

    final String quoteTitle =
        '${l10n?.translate('rfqQuoteLabel') ?? 'Quote'} ${quote.id}';

    return Card(
      key: ValueKey('rfq_quote_card_${quote.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quoteTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            _StatusInline(
              label: l10n?.translate('statusLabel') ?? 'Status',
              status: quote.status,
              l10n: l10n,
              compact: true,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n?.translate('rfqQuoteDateLabel') ?? 'Date'}: '
              '${dateFormat.format(quote.createdAt.toLocal())}',
            ),
            if (isExpired)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _ExpiredBadge(l10n: l10n, quoteId: quote.id),
              ),
            if (quote.total != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${l10n?.translate('rfqQuoteAmountLabel') ?? 'Estimated total'}: '
                  '${currencyFormat.format(quote.total)}',
                ),
              ),
            if (quote.vendorCompanyId != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${l10n?.translate('rfqQuoteVendorLabel') ?? 'Vendor'}: ${quote.vendorCompanyId}',
                ),
              ),
            if (quote.terms != null && quote.terms!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${l10n?.translate('rfqQuoteTermsLabel') ?? 'Terms'}: ${quote.terms}',
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: ValueKey('rfq_accept_quote_btn_${quote.id}'),
                onPressed: isExpired ? null : onAccept,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  l10n?.translate('rfqAcceptQuote') ?? 'Accept quote',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiredBadge extends StatelessWidget {
  const _ExpiredBadge({
    required this.l10n,
    required this.quoteId,
  });

  final MarketplaceLocalizations? l10n;
  final String quoteId;

  @override
  Widget build(BuildContext context) {
    final String label = resolveStatusLabel(status: 'expired', l10n: l10n);
    return AStatusChip(
      key: ValueKey('rfq_quote_expired_badge_$quoteId'),
      statusCode: 'expired',
      label: label,
      dense: true,
      icon: Icons.schedule_outlined,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
    required this.l10n,
    super.key,
  });

  final Object error;
  final VoidCallback onRetry;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String message =
        l10n?.translate('rfqListError') ?? 'Could not load RFQs.';
    final String details = error.toString();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                details,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n?.translate('rfqRetry') ?? 'Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.l10n,
    required this.onCreate,
    super.key,
  });

  final MarketplaceLocalizations? l10n;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final String title =
        l10n?.translate('rfqEmptyTitle') ?? 'No active requests';
    final String cta = l10n?.translate('rfqEmptyCta') ?? 'Create a new request';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: Text(cta),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isQuoteExpired(RfqQuote quote) {
  final DateTime? validUntil = _parseValidUntil(quote.terms);
  if (validUntil == null) {
    return false;
  }
  return validUntil.isBefore(DateTime.now().toUtc());
}

DateTime? _parseValidUntil(Map<String, dynamic>? terms) {
  if (terms == null || terms.isEmpty) {
    return null;
  }
  final dynamic raw = terms['valid_until'] ?? terms['validUntil'];
  if (raw == null) {
    return null;
  }
  if (raw is DateTime) {
    return raw.toUtc();
  }
  if (raw is String) {
    return DateTime.tryParse(raw)?.toUtc();
  }
  if (raw is int) {
    return DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
  }
  if (raw is num) {
    return DateTime.fromMillisecondsSinceEpoch(raw.toInt(), isUtc: true);
  }
  return null;
}
