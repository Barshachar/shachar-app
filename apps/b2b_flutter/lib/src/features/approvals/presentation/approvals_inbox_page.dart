import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/approvals_inbox_provider.dart';

typedef ApprovalsDecisionSender = Future<void> Function({
  required String stepId,
  required String orderId,
  required String decision,
  String? note,
});

final approvalsDecisionSenderProvider =
    Provider<ApprovalsDecisionSender>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return ({
    required String stepId,
    required String orderId,
    required String decision,
    String? note,
  }) async {
    await client.rpc<void>('rpc_approve_step', params: <String, dynamic>{
      'p_step_id': stepId,
      'p_order_id': orderId,
      'p_decision': decision,
      if (note != null && note.isNotEmpty) 'p_note': note,
    });
  };
});

class ApprovalsInboxPage extends ConsumerStatefulWidget {
  const ApprovalsInboxPage({super.key});

  @override
  ConsumerState<ApprovalsInboxPage> createState() => _ApprovalsInboxPageState();
}

class _ApprovalsInboxPageState extends ConsumerState<ApprovalsInboxPage> {
  Timer? _pollTimer;
  String? _busyStepId;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(approvalsInboxProvider);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<List<ApprovalRequest>> inboxAsync =
        ref.watch(approvalsInboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('approvalsInboxTitle') ?? 'Approvals Inbox',
        ),
        actions: [
          IconButton(
            tooltip:
                l10n?.translate('approvalsInboxRefresh') ?? 'Refresh inbox',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(approvalsInboxProvider);
            },
          ),
        ],
      ),
      body: inboxAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('approvals_inbox_loading_spinner'),
          ),
        ),
        error: (Object error, _) => _buildErrorState(context, l10n, error),
        data: (List<ApprovalRequest> requests) {
          if (requests.isEmpty) {
            return _buildEmptyState(context, l10n);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(approvalsInboxProvider);
              final _ = await ref.refresh(approvalsInboxProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: context
                  .pagePadding()
                  .resolve(Directionality.of(context))
                  .copyWith(bottom: ASpacing.xxl),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: ASpacing.lg),
              itemBuilder: (BuildContext context, int index) {
                final ApprovalRequest request = requests[index];
                final bool isBusy = _busyStepId == request.stepId;
                return _ApprovalCard(
                  request: request,
                  l10n: l10n,
                  isBusy: isBusy,
                  onApprove: () => _approve(request),
                  onReject: () => _promptReject(request),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    MarketplaceLocalizations? l10n,
  ) {
    final String title =
        l10n?.translate('approvalsInboxEmptyTitle') ?? 'No pending approvals';
    final String message =
        l10n?.translate('approvalsInboxEmptyBody') ?? 'You are all caught up.';
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(approvalsInboxProvider);
        final _ = await ref.refresh(approvalsInboxProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: context
            .pagePadding()
            .resolve(Directionality.of(context))
            .copyWith(bottom: ASpacing.xxl),
        children: [
          AStateMessage(
            key: const ValueKey('approvals_inbox_empty_state'),
            icon: Icons.verified_outlined,
            title: title,
            message: message,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    MarketplaceLocalizations? l10n,
    Object error,
  ) {
    final String title =
        l10n?.translate('approvalsInboxErrorTitle') ?? 'Inbox unavailable';
    final String message = error.toString();

    return Center(
      child: Padding(
        padding: context
            .pagePadding()
            .resolve(Directionality.of(context))
            .copyWith(bottom: ASpacing.xxl),
        child: AStateMessage(
          key: const ValueKey('approvals_inbox_error_state'),
          icon: Icons.error_outline,
          title: title,
          message: message,
          primaryLabel: l10n?.translate('approvalsInboxRetry') ?? 'Try again',
          onPrimaryPressed: () {
            ref.invalidate(approvalsInboxProvider);
          },
        ),
      ),
    );
  }

  Future<void> _approve(ApprovalRequest request) {
    return _sendDecision(request, decision: 'approve');
  }

  Future<void> _promptReject(ApprovalRequest request) async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            l10n?.translate('approvalsInboxRejectDialogTitle') ??
                'Reject approval',
          ),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText:
                  l10n?.translate('approvalsInboxRejectDialogLabel') ?? 'Note',
              hintText: l10n?.translate('approvalsInboxRejectDialogHint') ??
                  'Explain the rejection (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                l10n?.translate('approvalsInboxRejectCancel') ?? 'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n?.translate('approvalsInboxRejectConfirm') ?? 'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      controller.dispose();
      return;
    }

    final String note = controller.text.trim();
    controller.dispose();

    if (confirmed != true) {
      return;
    }

    await _sendDecision(
      request,
      decision: 'reject',
      note: note.isEmpty ? null : note,
    );
  }

  Future<void> _sendDecision(
    ApprovalRequest request, {
    required String decision,
    String? note,
  }) async {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ApprovalsDecisionSender sendDecision =
        ref.read(approvalsDecisionSenderProvider);

    setState(() {
      _busyStepId = request.stepId;
    });

    try {
      await sendDecision(
        stepId: request.stepId,
        orderId: request.orderId,
        decision: decision,
        note: note,
      );
      if (!mounted) {
        return;
      }
      ref.invalidate(approvalsInboxProvider);
      final String messageKey = decision == 'approve'
          ? 'approvalsInboxApproveSuccess'
          : 'approvalsInboxRejectSuccess';
      final String message = l10n?.translate(messageKey) ??
          (decision == 'approve'
              ? 'Approval recorded.'
              : 'Rejection recorded.');
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback = l10n?.translate('approvalsInboxActionError') ??
          'Action failed. Try again.';
      final String message = _normalizePostgrestError(error) ?? fallback;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback = l10n?.translate('approvalsInboxActionError') ??
          'Action failed. Try again.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('$fallback\n$error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _busyStepId = null;
        });
      }
    }
  }

  String? _normalizePostgrestError(PostgrestException error) {
    final List<String> parts = <String>[];
    if (error.message.trim().isNotEmpty) {
      parts.add(error.message.trim());
    }
    final Object? hint = error.hint;
    if (hint is String && hint.trim().isNotEmpty) {
      parts.add(hint.trim());
    }
    final Object? details = error.details;
    if (details != null) {
      final String text = details.toString().trim();
      if (text.isNotEmpty) {
        parts.add(text);
      }
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.request,
    required this.l10n,
    required this.onApprove,
    required this.onReject,
    required this.isBusy,
  });

  final ApprovalRequest request;
  final MarketplaceLocalizations? l10n;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      symbol: request.currency,
      decimalDigits: 2,
    );
    final String localeCode = l10n?.locale.languageCode ?? 'en';
    final DateFormat dateFormat = DateFormat.yMMMMd(localeCode).add_Hm();

    final String totalFormatted = currencyFormat.format(request.total);
    final String requestedAtLabel = dateFormat.format(
      request.requestedAt.toLocal(),
    );
    final String? requestedTemplate =
        l10n?.translate('approvalsInboxRequestedBy');
    final String requestedByLabel = requestedTemplate != null
        ? requestedTemplate.replaceFirst(
            '{name}',
            request.requestedBy ?? '-',
          )
        : 'Requested by: ${request.requestedBy ?? '-'}';
    final String? buyerTemplate = l10n?.translate('approvalsInboxBuyer');
    final String buyerLabel = buyerTemplate != null
        ? buyerTemplate.replaceFirst(
            '{name}',
            request.buyerName ?? '-',
          )
        : 'Buyer: ${request.buyerName ?? '-'}';
    final String? requestedAtTemplate =
        l10n?.translate('approvalsInboxRequestedAt');
    final String requestedAtText = requestedAtTemplate != null
        ? requestedAtTemplate.replaceFirst('{time}', requestedAtLabel)
        : 'Requested at $requestedAtLabel';

    return Card(
      elevation: AElevation.level1,
      shape: RoundedRectangleBorder(borderRadius: ARadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.xl),
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
                        request.orderNumber.isEmpty
                            ? request.orderId
                            : request.orderNumber,
                        style: ATypography.titleSm,
                      ),
                      const SizedBox(height: ASpacing.xs),
                      Text(
                        buyerLabel,
                        style: ATypography.bodySm,
                      ),
                    ],
                  ),
                ),
                Text(
                  totalFormatted,
                  style: ATypography.titleSm,
                ),
              ],
            ),
            const SizedBox(height: ASpacing.md),
            Text(
              requestedByLabel,
              style: ATypography.bodyXs,
            ),
            const SizedBox(height: ASpacing.xs),
            Text(
              requestedAtText,
              style: ATypography.bodyXs,
            ),
            if (request.note != null && request.note!.trim().isNotEmpty) ...[
              const SizedBox(height: ASpacing.md),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AColors.surfaceSubtle,
                  borderRadius: ARadii.md,
                  border: Border.all(color: AColors.borderSubtle),
                ),
                padding: const EdgeInsets.all(ASpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.translate('approvalsInboxNoteLabel') ?? 'Note',
                      style: ATypography.bodyXs.copyWith(
                        color: AColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: ASpacing.xs),
                    Text(
                      request.note!,
                      style: ATypography.bodySm,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: ASpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AButton.secondary(
                    key: ValueKey('approvals_reject_btn_${request.stepId}'),
                    expand: true,
                    label: l10n?.translate('approvalsInboxReject') ?? 'Reject',
                    icon: const Icon(Icons.close, size: 18),
                    loading: isBusy,
                    onPressed: isBusy ? null : onReject,
                  ),
                ),
                const SizedBox(width: ASpacing.md),
                Expanded(
                  child: AButton.primary(
                    key: ValueKey('approvals_approve_btn_${request.stepId}'),
                    expand: true,
                    label:
                        l10n?.translate('approvalsInboxApprove') ?? 'Approve',
                    icon: const Icon(Icons.check_circle, size: 18),
                    loading: isBusy,
                    onPressed: isBusy ? null : onApprove,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
