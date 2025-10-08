import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/core/presentation/status_tokens.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';

typedef VendorRfqSendMessageAction = Future<void> Function({
  required String rfqId,
  required String text,
});

Future<void> _defaultVendorRfqSendMessageAction({
  required String rfqId,
  required String text,
}) async {}

final vendorRfqSendMessageActionProvider =
    Provider<VendorRfqSendMessageAction>((ref) {
  return _defaultVendorRfqSendMessageAction;
});

bool _isDefaultVendorRfqSendMessageAction(VendorRfqSendMessageAction action) {
  return identical(action, _defaultVendorRfqSendMessageAction);
}

typedef VendorQuoteRejectAction = Future<void> Function(
    {required String rfqId});

Future<void> _defaultVendorRejectAction({required String rfqId}) async {}

final vendorQuoteRejectActionProvider =
    Provider<VendorQuoteRejectAction>((ref) {
  return _defaultVendorRejectAction;
});

bool _isDefaultVendorRejectAction(VendorQuoteRejectAction action) {
  return identical(action, _defaultVendorRejectAction);
}

class VendorRfqsPage extends ConsumerWidget {
  const VendorRfqsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<RfqSummary>> rfqs = ref.watch(vendorRfqsProvider);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    final DateFormat dateFormat = DateFormat.yMMMMd('he_IL').add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.translate('rfqVendorListTitle') ?? 'Customer RFQs'),
      ),
      body: rfqs.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('vendor_rfq_loading_spinner'),
          ),
        ),
        error: (Object error, _) => _VendorErrorState(
          key: const ValueKey('vendor_rfq_error_state'),
          l10n: l10n,
          error: error,
          onRetry: () => ref.invalidate(vendorRfqsProvider),
        ),
        data: (List<RfqSummary> items) {
          if (items.isEmpty) {
            return _VendorEmptyState(
              key: const ValueKey('vendor_rfq_empty_state'),
              l10n: l10n,
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(vendorRfqsProvider.future),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final RfqSummary summary = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(summary.displayReference),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusInlineRow(
                          label: l10n?.translate('rfqVendorStatusLabel') ??
                              (l10n?.translate('statusLabel') ?? 'Status'),
                          status: summary.status,
                          l10n: l10n,
                        ),
                        Text(
                          '${l10n?.translate('rfqLastUpdatedLabel') ?? 'Created at'} '
                          '${dateFormat.format(summary.createdAt.toLocal())}',
                        ),
                        if (summary.needBy != null)
                          Text(
                            '${l10n?.translate('rfqNeedByLabel') ?? 'Need by'} '
                            '${dateFormat.format(summary.needBy!.toLocal())}',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            VendorQuotePage(rfqId: summary.id),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VendorQuotePage extends ConsumerWidget {
  const VendorQuotePage({required this.rfqId, super.key});

  final String rfqId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RfqDetail> detailAsync =
        ref.watch(rfqDetailProvider(rfqId));
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    final DateFormat dateFormat = DateFormat.yMMMMd('he_IL').add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n?.translate('rfqQuoteLabel') ?? 'Quote'} $rfqId',
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('vendor_rfq_loading_spinner'),
          ),
        ),
        error: (Object error, _) => _VendorErrorState(
          key: const ValueKey('vendor_rfq_error_state'),
          error: error,
          l10n: l10n,
          onRetry: () => ref.invalidate(rfqDetailProvider(rfqId)),
        ),
        data: (RfqDetail detail) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusInlineRow(
                        label: l10n?.translate('rfqCustomerStatusLabel') ??
                            (l10n?.translate('statusLabel') ?? 'Status'),
                        status: detail.status,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 6),
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
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${l10n?.translate('rfqVendorCustomerTermsLabel') ?? 'Customer terms'}: ${detail.terms}',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _VendorMessageThread(detail: detail, l10n: l10n),
              const SizedBox(height: 12),
              _VendorQuoteForm(detail: detail, l10n: l10n),
            ],
          );
        },
      ),
    );
  }
}

class _VendorMessageThread extends ConsumerStatefulWidget {
  const _VendorMessageThread({required this.detail, required this.l10n});

  final RfqDetail detail;
  final MarketplaceLocalizations? l10n;

  @override
  ConsumerState<_VendorMessageThread> createState() =>
      _VendorMessageThreadState();
}

class _VendorMessageThreadState extends ConsumerState<_VendorMessageThread> {
  final TextEditingController _messageController = TextEditingController();
  bool _sending = false;
  String? _sendError;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.yMMMMd('he_IL').add_Hm();
    final MarketplaceLocalizations? l10n = widget.l10n;
    final List<RfqMessage> messages = widget.detail.messages;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.translate('rfqVendorThreadTitle') ?? 'Message thread',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            KeyedSubtree(
              key: const ValueKey('vendor_rfq_messages_list'),
              child: messages.isEmpty
                  ? Text(
                      l10n?.translate('rfqVendorMessageEmpty') ??
                          'No messages for this request',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final RfqMessage message in messages)
                          KeyedSubtree(
                            key: ValueKey(
                                'vendor_rfq_message_item_${message.id}'),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _vendorAuthorLabel(
                                      message.authorRole,
                                      l10n,
                                    ),
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(message.body),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat
                                        .format(message.createdAt.toLocal()),
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[500]),
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
              key: const ValueKey('vendor_rfq_message_input'),
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n?.translate('rfqVendorMessageLabel') ??
                    'Reply to buyer',
                errorText: _sendError,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                key: const ValueKey('vendor_rfq_message_send_btn'),
                onPressed: _sending ? null : _sendMessage,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          key: ValueKey('vendor_rfq_message_sending'),
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  l10n?.translate('rfqVendorSendMessage') ?? 'Send message',
                ),
              ),
            ),
            if (_sendError != null) ...[
              const SizedBox(height: 8),
              Text(
                _sendError!,
                key: const ValueKey('vendor_rfq_message_send_error'),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    final MarketplaceLocalizations? l10n = widget.l10n;
    if (text.isEmpty) {
      setState(() {
        _sendError =
            l10n?.translate('rfqVendorMessageErrorEmpty') ?? 'Enter a message';
      });
      return;
    }
    final VendorRfqSendMessageAction sendAction =
        ref.read(vendorRfqSendMessageActionProvider);
    setState(() {
      _sendError = null;
      _sending = true;
    });
    try {
      await sendAction(rfqId: widget.detail.id, text: text);
      if (_isDefaultVendorRfqSendMessageAction(sendAction)) {
        await ref
            .read(rfqActionControllerProvider)
            .postMessage(rfqId: widget.detail.id, body: text);
      }
      if (!mounted) {
        return;
      }
      _messageController.clear();
      ref.invalidate(rfqDetailProvider(widget.detail.id));
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          final String base = l10n?.translate('rfqVendorMessageSendFailed') ??
              'Failed to send message';
          _sendError = '$base: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  String _vendorAuthorLabel(
    String? role,
    MarketplaceLocalizations? l10n,
  ) {
    switch (role) {
      case 'buyer':
        return l10n?.translate('rfqMessageAuthorCustomer') ??
            'Customer message';
      case 'admin':
        return l10n?.translate('rfqMessageAuthorAdmin') ?? 'System';
      default:
        return l10n?.translate('rfqMessageAuthorVendor') ?? 'Vendor reply';
    }
  }
}

class _VendorQuoteForm extends ConsumerStatefulWidget {
  const _VendorQuoteForm({required this.detail, required this.l10n});

  final RfqDetail detail;
  final MarketplaceLocalizations? l10n;

  @override
  ConsumerState<_VendorQuoteForm> createState() => _VendorQuoteFormState();
}

class _VendorQuoteFormState extends ConsumerState<_VendorQuoteForm> {
  late final List<TextEditingController> _priceControllers;
  late final List<TextEditingController> _minQtyControllers;
  late final List<TextEditingController> _stepControllers;
  late final List<TextEditingController> _leadTimeControllers;
  late final TextEditingController _termsController;
  bool _submitting = false;
  bool _rejecting = false;
  bool _rejected = false;
  String? _submitError;
  String? _actionError;

  @override
  void initState() {
    super.initState();
    _priceControllers = widget.detail.items
        .map((RfqItem item) => TextEditingController())
        .toList(growable: false);
    _minQtyControllers = widget.detail.items
        .map((RfqItem item) =>
            TextEditingController(text: item.qty.toStringAsFixed(2)))
        .toList(growable: false);
    _stepControllers = widget.detail.items
        .map((_) => TextEditingController())
        .toList(growable: false);
    _leadTimeControllers = widget.detail.items
        .map((_) => TextEditingController())
        .toList(growable: false);
    _termsController = TextEditingController();
  }

  @override
  void dispose() {
    for (final controller in _priceControllers) {
      controller.dispose();
    }
    for (final controller in _minQtyControllers) {
      controller.dispose();
    }
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    for (final controller in _leadTimeControllers) {
      controller.dispose();
    }
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final MarketplaceLocalizations? l10n = widget.l10n;
    if (_rejected) {
      return Card(
        key: const ValueKey('vendor_quote_rejected_state'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n?.translate('rfqVendorQuoteRejectedTitle') ??
                    'Request marked as rejected',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.translate('rfqVendorQuoteRejectedBody') ??
                    'You can submit a new quote if needed.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final VendorQuoteRejectAction rejectAction =
        ref.watch(vendorQuoteRejectActionProvider);
    final bool showReject = !_isDefaultVendorRejectAction(rejectAction);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.translate('rfqVendorQuoteDetailsTitle') ?? 'Quote details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < widget.detail.items.length; i++)
              _QuoteLineFields(
                item: widget.detail.items[i],
                priceController: _priceControllers[i],
                minQtyController: _minQtyControllers[i],
                stepController: _stepControllers[i],
                leadTimeController: _leadTimeControllers[i],
                l10n: l10n,
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _termsController,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n?.translate('rfqVendorCustomerTermsLabel') ??
                    'Customer terms',
                border: const OutlineInputBorder(),
              ),
            ),
            if (_submitError != null) ...[
              const SizedBox(height: 12),
              Text(
                _submitError!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
            if (_actionError != null) ...[
              const SizedBox(height: 12),
              Text(
                _actionError!,
                key: const ValueKey('vendor_quote_action_error'),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('vendor_quote_submit_btn'),
              onPressed:
                  _submitting ? null : () => _submit(context, widget.detail),
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                l10n?.translate('rfqVendorSubmitQuote') ?? 'Submit quote',
              ),
            ),
            if (showReject) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const ValueKey('vendor_quote_reject_btn'),
                onPressed:
                    _rejecting ? null : () => _reject(context, rejectAction),
                icon: _rejecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.highlight_off_outlined),
                label: Text(
                  l10n?.translate('rfqVendorRejectQuote') ?? 'Reject request',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    RfqDetail detail,
  ) async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);
    final MarketplaceLocalizations? l10n = widget.l10n;
    setState(() {
      _submitError = null;
      _actionError = null;
      _submitting = true;
    });
    try {
      final List<RfqQuoteDraftLine> lines = <RfqQuoteDraftLine>[];
      for (int i = 0; i < detail.items.length; i++) {
        final RfqItem item = detail.items[i];
        final double? price =
            double.tryParse(_priceControllers[i].text.replaceAll(',', '.'));
        if (price == null || price <= 0) {
          final String base =
              l10n?.translate('rfqVendorPriceRequired') ?? 'Price required for';
          throw ArgumentError(
            '$base ${item.description ?? item.sku ?? item.id}',
          );
        }
        final double? minQty =
            double.tryParse(_minQtyControllers[i].text.replaceAll(',', '.'));
        final double? stepQty =
            double.tryParse(_stepControllers[i].text.replaceAll(',', '.'));
        final int? leadTime =
            int.tryParse(_leadTimeControllers[i].text.replaceAll(',', '.'));
        lines.add(
          RfqQuoteDraftLine(
            rfqItemId: item.id,
            unitPrice: price,
            minimumOrderQty: minQty,
            stepQty: stepQty,
            leadTimeDays: leadTime,
          ),
        );
      }
      final Map<String, dynamic> terms = <String, dynamic>{};
      final String termsText = _termsController.text.trim();
      if (termsText.isNotEmpty) {
        terms['memo'] = termsText;
      }
      final String quoteId =
          await ref.read(rfqActionControllerProvider).submitQuote(
                rfqId: detail.id,
                items: lines,
                terms: terms.isEmpty ? null : terms,
              );
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${l10n?.translate('rfqVendorSuccessSnack') ?? 'Quote submitted successfully'} (#$quoteId)',
          ),
        ),
      );
      navigator.pop();
    } on ArgumentError catch (error) {
      if (mounted) {
        setState(() {
          _submitError = error.message?.toString() ?? error.toString();
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          final String base = l10n?.translate('rfqVendorSubmitError') ??
              'Failed to submit quote';
          _submitError = '$base: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  Future<void> _reject(
    BuildContext context,
    VendorQuoteRejectAction action,
  ) async {
    final ScaffoldMessengerState messenger =
        ScaffoldMessenger.maybeOf(context) ?? ScaffoldMessenger.of(context);
    final MarketplaceLocalizations? l10n = widget.l10n;
    setState(() {
      _actionError = null;
      _rejecting = true;
    });
    try {
      await action(rfqId: widget.detail.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _rejected = true;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.translate('rfqVendorRejectSuccess') ??
                'Request rejected successfully',
          ),
        ),
      );
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          final String base = l10n?.translate('rfqVendorRejectError') ??
              'Failed to reject request';
          _actionError = '$base: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _rejecting = false;
        });
      }
    }
  }
}

class _StatusInlineRow extends StatelessWidget {
  const _StatusInlineRow({
    required this.label,
    required this.status,
    required this.l10n,
  });

  final String label;
  final String status;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String statusLabel = resolveStatusLabel(status: status, l10n: l10n);

    return Wrap(
      spacing: ASpacing.xs,
      runSpacing: ASpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$label:',
          style: theme.textTheme.bodySmall ?? ATypography.bodySm,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
        AStatusChip(
          statusCode: status,
          label: statusLabel,
          dense: true,
        ),
      ],
    );
  }
}

class _QuoteLineFields extends StatelessWidget {
  const _QuoteLineFields({
    required this.item,
    required this.priceController,
    required this.minQtyController,
    required this.stepController,
    required this.leadTimeController,
    required this.l10n,
  });

  final RfqItem item;
  final TextEditingController priceController;
  final TextEditingController minQtyController;
  final TextEditingController stepController;
  final TextEditingController leadTimeController;
  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String fallbackLabel =
        l10n?.translate('rfqItemFallbackLabel') ?? 'Unnamed item';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.description ?? item.sku ?? fallbackLabel,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: ValueKey('vendor_quote_price_field_${item.id}'),
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n?.translate('rfqVendorUnitPriceLabel') ??
                        'Unit price (₪)',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: minQtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n?.translate('rfqVendorMOQLabel') ?? 'MOQ',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: stepController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText:
                        l10n?.translate('rfqVendorStepQtyLabel') ?? 'Step qty',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: leadTimeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  decoration: InputDecoration(
                    labelText: l10n?.translate('rfqVendorLeadTimeLabel') ??
                        'Lead time (days)',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorErrorState extends StatelessWidget {
  const _VendorErrorState({
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
    final String message = l10n?.translate('rfqVendorListError') ??
        (l10n?.translate('rfqListError') ?? 'Could not load RFQs.');
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

class _VendorEmptyState extends StatelessWidget {
  const _VendorEmptyState({required this.l10n, super.key});

  final MarketplaceLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final String title =
        l10n?.translate('rfqVendorEmptyTitle') ?? 'No vendor requests pending';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
