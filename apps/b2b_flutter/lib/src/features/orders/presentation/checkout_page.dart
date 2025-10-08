import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/app/theme/components.dart';
import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/auth/session_provider.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/catalog/presentation/quick_order_page.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/order_approval_state.dart';
import 'package:ashachar_marketplace/src/features/approvals/presentation/widgets/approval_status_banner.dart';
import 'package:ashachar_marketplace/src/features/orders/data/orders_repository.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/cart_controller.dart';
import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart';
import 'package:ashachar_marketplace/src/features/pricing/presentation/contract_price_badge.dart';

typedef SendOrderForApproval = Future<void> Function({required String orderId});

final sendOrderForApprovalProvider = Provider<SendOrderForApproval>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return ({required String orderId}) async {
    await client.rpc<void>(
      'rpc_evaluate_approvals',
      params: <String, dynamic>{'p_order_id': orderId},
    );
  };
});

final checkoutFormOptionsProvider =
    FutureProvider.autoDispose<CheckoutFormOptions>((ref) async {
  final OrdersRepository repository = ref.watch(ordersRepositoryProvider);
  final String companyId = ref.watch(quickOrderCompanyIdProvider);

  if (companyId.isEmpty) {
    return const CheckoutFormOptions(
      billToAccounts: <CheckoutAccountOption>[],
      shipToLocations: <CheckoutLocationOption>[],
      paymentTerms: <CheckoutPaymentTermOption>[],
    );
  }

  final List<dynamic> results = await Future.wait<dynamic>([
    repository.fetchBillToAccounts(companyId: companyId),
    repository.fetchShipToLocations(companyId: companyId),
    repository.fetchPaymentTerms(companyId: companyId),
  ]);

  return CheckoutFormOptions(
    billToAccounts: results[0] as List<CheckoutAccountOption>,
    shipToLocations: results[1] as List<CheckoutLocationOption>,
    paymentTerms: results[2] as List<CheckoutPaymentTermOption>,
  );
});

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String? _billToId;
  String? _shipToId;
  String? _paymentTermId;
  CheckoutFormOptions? _formOptions;
  late final TextEditingController _poController;
  late final TextEditingController _notesController;
  bool _isSendingApproval = false;
  bool _isSubmittingOrder = false;
  ProviderSubscription<AsyncValue<CheckoutFormOptions>>?
      _formOptionsSubscription;

  @override
  void initState() {
    super.initState();
    _poController = TextEditingController();
    _notesController = TextEditingController();
    _poController.addListener(_handleFormChanged);
    _notesController.addListener(_handleFormChanged);
    _formOptionsSubscription =
        ref.listenManual<AsyncValue<CheckoutFormOptions>>(
      checkoutFormOptionsProvider,
      (AsyncValue<CheckoutFormOptions>? previous,
          AsyncValue<CheckoutFormOptions> next) {
        next.whenData((CheckoutFormOptions options) {
          _formOptions = options;
          String? billToId = _billToId;
          String? shipToId = _shipToId;
          String? paymentTermId = _paymentTermId;
          bool changed = false;

          if (billToId == null && options.billToAccounts.isNotEmpty) {
            billToId = options.billToAccounts.first.id;
            changed = true;
          }
          if (shipToId == null && options.shipToLocations.isNotEmpty) {
            shipToId = options.shipToLocations.first.id;
            changed = true;
          }
          if (paymentTermId == null && options.paymentTerms.isNotEmpty) {
            paymentTermId = options.paymentTerms.first.id;
            changed = true;
          }

          if (changed && mounted) {
            setState(() {
              _billToId = billToId;
              _shipToId = shipToId;
              _paymentTermId = paymentTermId;
            });
          }
        });
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.orderId.isNotEmpty) {
        return;
      }
      final MarketplaceLocalizations? l10n =
          Localizations.of<MarketplaceLocalizations>(
        context,
        MarketplaceLocalizations,
      );
      final String message = l10n?.translate('checkoutDraftMissing') ??
          'Cannot proceed without an active cart.';
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _poController.removeListener(_handleFormChanged);
    _notesController.removeListener(_handleFormChanged);
    _poController.dispose();
    _notesController.dispose();
    _formOptionsSubscription?.close();
    super.dispose();
  }

  void _handleFormChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final AsyncValue<List<CartLine>> linesAsync =
        ref.watch(cartLinesProvider(widget.orderId));
    final AsyncValue<OrderApprovalState> approvalAsync =
        ref.watch(orderApprovalProvider(widget.orderId));
    final String companyId = ref.watch(quickOrderCompanyIdProvider);
    final Set<String>? companyCatalog = companyId.isEmpty
        ? null
        : ref.watch(quickOrderCompanyCatalogProvider(companyId)).maybeWhen(
              data: (value) => value,
              orElse: () => null,
            );
    final AsyncValue<CheckoutFormOptions> formOptionsAsync =
        ref.watch(checkoutFormOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.translate('checkoutTitle') ?? 'Checkout',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
      body: SafeArea(
        child: formOptionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, _) => Padding(
            padding: context.pagePadding(),
            child: AStateMessage(
              icon: Icons.error_outline,
              title: l10n?.translate('checkoutOptionsErrorTitle') ??
                  'לא הצלחנו לטעון את פרטי החשבון',
              message: l10n?.translate('checkoutOptionsErrorMessage') ??
                  'נסה לרענן או לבדוק את החיבור.',
              primaryLabel: l10n?.translate('commonRetry') ?? 'נסה שוב',
              onPrimaryPressed: () =>
                  ref.invalidate(checkoutFormOptionsProvider),
            ),
          ),
          data: (CheckoutFormOptions options) {
            final CheckoutAccountOption? billToSelection =
                options.billToAccounts.firstWhereOrNull(
                    (CheckoutAccountOption option) => option.id == _billToId);
            final CheckoutLocationOption? shipToSelection =
                options.shipToLocations.firstWhereOrNull(
                    (CheckoutLocationOption option) => option.id == _shipToId);
            final CheckoutPaymentTermOption? paymentTermSelection = options
                .paymentTerms
                .firstWhereOrNull((CheckoutPaymentTermOption option) =>
                    option.id == _paymentTermId);
            final String poNumber = _poController.text.trim();
            final String deliveryNotes = _notesController.text.trim();

            final Widget? approvalBanner =
                _buildApprovalBanner(context, approvalAsync, l10n);
            final Widget formSection = _buildForm(
              context,
              l10n,
              options,
              billToSelection,
              shipToSelection,
              paymentTermSelection,
            );
            final Widget summarySection = _CheckoutSummaryCard(
              linesAsync: linesAsync,
              l10n: l10n,
              approvalAsync: approvalAsync,
              onReviewPressed: () => _handleContinue(context, l10n),
              onSendForApprovalPressed: _handleSendForApprovalPressed,
              onSubmitApprovedPressed: _handleSubmitApprovedOrderPressed,
              isSendingApproval: _isSendingApproval,
              isSubmittingOrder: _isSubmittingOrder,
              companyId: companyId,
              companyCatalog: companyCatalog,
              billTo: billToSelection,
              shipTo: shipToSelection,
              paymentTerm: paymentTermSelection,
              poNumber: poNumber,
              deliveryNotes: deliveryNotes,
            );

            return FocusTraversalGroup(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isWide = constraints.maxWidth >= 960;
                  final List<Widget> narrowChildren = <Widget>[
                    if (approvalBanner != null) approvalBanner,
                    formSection,
                    const SizedBox(height: ASpacing.xxl),
                    summarySection,
                  ];

                  if (!isWide) {
                    return SingleChildScrollView(
                      padding: context.pagePadding(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: narrowChildren,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: context.pagePadding(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (approvalBanner != null) approvalBanner,
                        Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: formSection,
                                ),
                                const SizedBox(width: ASpacing.xxl),
                                SizedBox(
                                  width: 360,
                                  child: summarySection,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSendForApprovalPressed() {
    if (_isSendingApproval) {
      return;
    }
    unawaited(_sendForApproval());
  }

  void _handleSubmitApprovedOrderPressed() {
    if (_isSubmittingOrder) {
      return;
    }
    unawaited(_submitApprovedOrder());
  }

  Future<void> _sendForApproval() async {
    final SendOrderForApproval sendOrderForApproval =
        ref.read(sendOrderForApprovalProvider);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSendingApproval = true;
    });

    try {
      await sendOrderForApproval(orderId: widget.orderId);
      if (!mounted) {
        return;
      }
      ref.invalidate(orderApprovalProvider(widget.orderId));
      final String message =
          l10n?.translate('approvalSendSuccess') ?? 'Approval request sent.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback = l10n?.translate('approvalSendError') ??
          'Could not send approval request.';
      final String message = _normalizePostgrestError(error) ?? fallback;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback = l10n?.translate('approvalSendError') ??
          'Could not send approval request.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('$fallback\n$error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingApproval = false;
        });
      }
    }
  }

  Future<void> _submitApprovedOrder() async {
    final CartController controller = ref.read(cartControllerProvider.notifier);
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSubmittingOrder = true;
    });

    try {
      await controller.submitDraftAndNavigate(context);
      if (!mounted) {
        return;
      }
      final String message = l10n?.translate('approvalSubmitSuccess') ??
          'Order submitted successfully.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      final String fallback = l10n?.translate('approvalSubmitError') ??
          'Could not submit the order.';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('$fallback\n$error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingOrder = false;
        });
      }
    }
  }

  Widget? _buildApprovalBanner(
    BuildContext context,
    AsyncValue<OrderApprovalState> approvalAsync,
    MarketplaceLocalizations? l10n,
  ) {
    return approvalAsync.when(
      data: (OrderApprovalState state) {
        if (!state.requiresApproval) {
          return null;
        }
        final Key? bannerKey;
        switch (state.stage) {
          case OrderApprovalStage.readyToRequest:
          case OrderApprovalStage.rejected:
            bannerKey = const ValueKey('checkout_requires_approval_banner');
            break;
          case OrderApprovalStage.pending:
            bannerKey = const ValueKey('checkout_pending_approval_banner');
            break;
          case OrderApprovalStage.approved:
            bannerKey = const ValueKey('checkout_approved_banner');
            break;
          case OrderApprovalStage.notRequired:
            return null;
        }
        return ApprovalStatusBanner(
          key: bannerKey,
          state: state,
          l10n: l10n,
          margin: const EdgeInsetsDirectional.only(bottom: ASpacing.xl),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsetsDirectional.only(bottom: ASpacing.lg),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (Object error, _) {
        final String message = l10n?.translate('approvalBannerError') ??
            'Could not load approval status.';
        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: ASpacing.lg),
          child: Text(
            message,
            style: ATypography.bodySm.copyWith(color: AColors.danger),
          ),
        );
      },
    );
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
      final String detailText = details.toString().trim();
      if (detailText.isNotEmpty) {
        parts.add(detailText);
      }
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Widget _buildForm(
    BuildContext context,
    MarketplaceLocalizations? l10n,
    CheckoutFormOptions options,
    CheckoutAccountOption? billToSelection,
    CheckoutLocationOption? shipToSelection,
    CheckoutPaymentTermOption? paymentTermSelection,
  ) {
    final String billToLabel =
        l10n?.translate('checkoutBillToLabel') ?? 'Select bill-to';
    final String billToHint =
        l10n?.translate('checkoutBillToHint') ?? 'Choose account';
    final String billToTitle =
        l10n?.translate('checkoutBillToTitle') ?? 'Bill-to address';

    final String shipToLabel =
        l10n?.translate('checkoutShipToLabel') ?? 'Select ship-to';
    final String shipToHint =
        l10n?.translate('checkoutShipToHint') ?? 'Choose location';
    final String shipToTitle =
        l10n?.translate('checkoutShipToTitle') ?? 'Ship-to address';

    final String paymentTermsTitle =
        l10n?.translate('checkoutPaymentTermsTitle') ?? 'Payment terms';
    final String paymentTermsLabel =
        l10n?.translate('checkoutPaymentTermsLabel') ?? 'בחר תנאי תשלום';

    final String poLabel =
        l10n?.translate('checkoutPoNumberLabel') ?? 'PO number';
    final String deliveryNotesLabel =
        l10n?.translate('checkoutDeliveryNotesLabel') ?? 'Delivery notes';
    final String additionalInfoTitle =
        l10n?.translate('checkoutAdditionalInfoTitle') ?? 'Additional details';

    final List<DropdownMenuItem<String>> billToItems = options.billToAccounts
        .map(
          (CheckoutAccountOption option) => DropdownMenuItem<String>(
            value: option.id,
            child: Text(option.title),
          ),
        )
        .toList();

    final List<DropdownMenuItem<String>> shipToItems = options.shipToLocations
        .map(
          (CheckoutLocationOption option) => DropdownMenuItem<String>(
            value: option.id,
            child: Text(option.label),
          ),
        )
        .toList();

    final List<DropdownMenuItem<String>> paymentTermItems = options.paymentTerms
        .map(
          (CheckoutPaymentTermOption option) => DropdownMenuItem<String>(
            value: option.id,
            child: Text(option.label),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: billToTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _billToId,
                icon: const Icon(Icons.arrow_drop_down),
                decoration: InputDecoration(
                  labelText: billToLabel,
                  hintText: billToHint,
                  border: const OutlineInputBorder(borderRadius: ARadii.md),
                  isDense: true,
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: ASpacing.md,
                    vertical: ASpacing.sm,
                  ),
                ),
                isExpanded: true,
                items: billToItems,
                onChanged: options.billToAccounts.isEmpty
                    ? null
                    : (String? value) {
                        setState(() {
                          _billToId = value;
                        });
                      },
              ),
              const SizedBox(height: ASpacing.md),
              if (billToSelection != null)
                _CheckoutDetailTile(
                  title: billToSelection.subtitle ?? billToSelection.title,
                  body: billToSelection.addressLine,
                ),
            ],
          ),
        ),
        const SizedBox(height: ASpacing.xxl),
        _SectionCard(
          title: shipToTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _shipToId,
                icon: const Icon(Icons.arrow_drop_down),
                decoration: InputDecoration(
                  labelText: shipToLabel,
                  hintText: shipToHint,
                  border: const OutlineInputBorder(borderRadius: ARadii.md),
                  isDense: true,
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: ASpacing.md,
                    vertical: ASpacing.sm,
                  ),
                ),
                isExpanded: true,
                items: shipToItems,
                onChanged: options.shipToLocations.isEmpty
                    ? null
                    : (String? value) {
                        setState(() {
                          _shipToId = value;
                        });
                      },
              ),
              const SizedBox(height: ASpacing.md),
              if (shipToSelection != null)
                _CheckoutDetailTile(
                  title: shipToSelection.label,
                  body: shipToSelection.addressLine,
                  footer: shipToSelection.notes,
                ),
            ],
          ),
        ),
        const SizedBox(height: ASpacing.xxl),
        _SectionCard(
          title: paymentTermsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _paymentTermId,
                icon: const Icon(Icons.arrow_drop_down),
                decoration: InputDecoration(
                  labelText: paymentTermsLabel,
                  border: const OutlineInputBorder(borderRadius: ARadii.md),
                  isDense: true,
                  contentPadding: const EdgeInsetsDirectional.symmetric(
                    horizontal: ASpacing.md,
                    vertical: ASpacing.sm,
                  ),
                ),
                isExpanded: true,
                items: paymentTermItems,
                onChanged: options.paymentTerms.isEmpty
                    ? null
                    : (String? value) {
                        setState(() {
                          _paymentTermId = value;
                        });
                      },
              ),
              const SizedBox(height: ASpacing.md),
              if (paymentTermSelection != null)
                _CheckoutDetailTile(
                  title: paymentTermSelection.label,
                  body: paymentTermSelection.description,
                  footer: l10n != null
                      ? l10n
                          .translate('checkoutPaymentNetDays')
                          .replaceAll(
                            '{days}',
                            paymentTermSelection.netDays.toString(),
                          )
                      : 'Net ${paymentTermSelection.netDays}',
                ),
            ],
          ),
        ),
        const SizedBox(height: ASpacing.xxl),
        _SectionCard(
          title: additionalInfoTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _poController,
                decoration: InputDecoration(
                  labelText: poLabel,
                  border: const OutlineInputBorder(borderRadius: ARadii.md),
                ),
              ),
              const SizedBox(height: ASpacing.lg),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: deliveryNotesLabel,
                  border: const OutlineInputBorder(borderRadius: ARadii.md),
                ),
                maxLines: 3,
                minLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleContinue(BuildContext context, MarketplaceLocalizations? l10n) {
    final List<String> missing = <String>[];
    final CheckoutAccountOption? billToSelection = _formOptions?.billToAccounts
        .firstWhereOrNull(
            (CheckoutAccountOption option) => option.id == _billToId);
    final CheckoutLocationOption? shipToSelection =
        _formOptions?.shipToLocations.firstWhereOrNull(
            (CheckoutLocationOption option) => option.id == _shipToId);
    final CheckoutPaymentTermOption? paymentTermSelection =
        _formOptions?.paymentTerms.firstWhereOrNull(
            (CheckoutPaymentTermOption option) => option.id == _paymentTermId);

    if (_billToId == null || billToSelection == null) {
      missing.add(
        l10n?.translate('checkoutMissingBillTo') ?? 'Bill-to address',
      );
    }
    if (_shipToId == null || shipToSelection == null) {
      missing.add(
        l10n?.translate('checkoutMissingShipTo') ?? 'Ship-to address',
      );
    }
    if (_paymentTermId == null || paymentTermSelection == null) {
      missing.add(
        l10n?.translate('checkoutMissingPaymentTerms') ?? 'Payment terms',
      );
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (missing.isNotEmpty) {
      messenger.hideCurrentSnackBar();
      final String template =
          l10n?.translate('checkoutMissingData') ?? 'Please complete: {fields}';
      final String message = template.replaceAll(
        '{fields}',
        missing.join(l10n?.translate('checkoutMissingSeparator') ?? ', '),
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    messenger.hideCurrentSnackBar();
    final String message = l10n?.translate('checkoutComingSoon') ??
        'Checkout submission coming soon.';
    final List<String> details = <String>[
      if (billToSelection != null)
        '${l10n?.translate('checkoutBillToTitle') ?? 'Bill-to'}: ${billToSelection.title}',
      if (shipToSelection != null)
        '${l10n?.translate('checkoutShipToTitle') ?? 'Ship-to'}: ${shipToSelection.label}',
      if (paymentTermSelection != null)
        '${l10n?.translate('checkoutPaymentTermsTitle') ?? 'Payment terms'}: ${paymentTermSelection.label}',
      if (_poController.text.trim().isNotEmpty)
        '${l10n?.translate('checkoutPoNumberLabel') ?? 'PO number'}: ${_poController.text.trim()}',
      if (_notesController.text.trim().isNotEmpty)
        '${l10n?.translate('checkoutDeliveryNotesLabel') ?? 'Delivery notes'}: ${_notesController.text.trim()}',
    ];

    final String composed =
        details.isEmpty ? message : '$message\n${details.join('\n')}';
    messenger.showSnackBar(SnackBar(content: Text(composed)));
  }
}

class _CheckoutSummaryCard extends ConsumerWidget {
  const _CheckoutSummaryCard({
    required this.linesAsync,
    required this.l10n,
    required this.approvalAsync,
    required this.onReviewPressed,
    required this.onSendForApprovalPressed,
    required this.onSubmitApprovedPressed,
    required this.isSendingApproval,
    required this.isSubmittingOrder,
    required this.companyId,
    required this.companyCatalog,
    this.billTo,
    this.shipTo,
    this.paymentTerm,
    this.poNumber = '',
    this.deliveryNotes = '',
  });

  final AsyncValue<List<CartLine>> linesAsync;
  final MarketplaceLocalizations? l10n;
  final AsyncValue<OrderApprovalState> approvalAsync;
  final VoidCallback onReviewPressed;
  final VoidCallback onSendForApprovalPressed;
  final VoidCallback onSubmitApprovedPressed;
  final bool isSendingApproval;
  final bool isSubmittingOrder;
  final String companyId;
  final Set<String>? companyCatalog;
  final CheckoutAccountOption? billTo;
  final CheckoutLocationOption? shipTo;
  final CheckoutPaymentTermOption? paymentTerm;
  final String poNumber;
  final String deliveryNotes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intl.NumberFormat currency =
        intl.NumberFormat.currency(symbol: '₪', decimalDigits: 2);
    final AsyncValue<Session?> sessionState =
        ref.watch(sessionControllerProvider);
    final Session? session =
        sessionState.whenOrNull(data: (Session? value) => value);
    final String pricingCompanyId = _companyIdFromSession(session);

    return _SectionCard(
      title: l10n?.translate('checkoutSummaryTitle') ?? 'Order summary',
      child: linesAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (Object error, _) {
          final String message = l10n?.translate('checkoutSummaryError') ??
              'We could not load order totals.';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: ATypography.bodyMd),
              const SizedBox(height: ASpacing.md),
              Text('$error', style: ATypography.bodySm),
            ],
          );
        },
        data: (List<CartLine> lines) {
          if (lines.isEmpty) {
            final String emptyMessage =
                l10n?.translate('checkoutSummaryEmpty') ??
                    'Your cart is empty.';
            return Text(emptyMessage, style: ATypography.bodyMd);
          }

          final double subtotal = lines.fold<double>(
            0,
            (double total, CartLine line) => total + line.lineTotal,
          );
          final double estimatedTaxRate = 0.17;
          final double taxes = subtotal * estimatedTaxRate;
          final double grandTotal = subtotal + taxes;
          final int forbiddenCount = lines
              .where(
                (CartLine line) =>
                    _isLineNotInCatalog(companyId, companyCatalog, line),
              )
              .length;
          final bool hasForbidden = forbiddenCount > 0;

          final String subtotalLabel =
              l10n?.translate('subtotalShort') ?? 'Subtotal';
          final String taxesLabel = l10n?.translate('vatShort') ?? 'VAT';
          final String totalLabel = l10n?.translate('totalShort') ?? 'Total';

          final OrderApprovalState? approvalState =
              approvalAsync.whenOrNull(data: (state) => state);
          final Object? approvalError =
              approvalAsync.whenOrNull(error: (error, _) => error);
          final bool approvalsLoading = approvalAsync.isLoading;

          final List<Widget> children = <Widget>[];
          final List<Widget> metaDetails = <Widget>[
            if (billTo != null)
              _SummaryDetailRow(
                label: l10n?.translate('checkoutBillToTitle') ?? 'Bill-to',
                value: <String>[
                  billTo!.title,
                  if (billTo!.subtitle != null &&
                      billTo!.subtitle!.trim().isNotEmpty)
                    billTo!.subtitle!,
                  if (billTo!.addressLine != null &&
                      billTo!.addressLine!.trim().isNotEmpty)
                    billTo!.addressLine!,
                ].join('\n'),
              ),
            if (shipTo != null)
              _SummaryDetailRow(
                label: l10n?.translate('checkoutShipToTitle') ?? 'Ship-to',
                value: <String>[
                  shipTo!.label,
                  if (shipTo!.addressLine != null &&
                      shipTo!.addressLine!.trim().isNotEmpty)
                    shipTo!.addressLine!,
                  if (shipTo!.notes != null && shipTo!.notes!.trim().isNotEmpty)
                    shipTo!.notes!,
                ].join('\n'),
              ),
            if (paymentTerm != null)
              _SummaryDetailRow(
                label: l10n?.translate('checkoutPaymentTermsTitle') ??
                    'Payment terms',
                value: <String>[
                  paymentTerm!.label,
                  if (paymentTerm!.description != null &&
                      paymentTerm!.description!.trim().isNotEmpty)
                    paymentTerm!.description!,
                  'Net ${paymentTerm!.netDays}',
                ].join('\n'),
              ),
            if (poNumber.trim().isNotEmpty)
              _SummaryDetailRow(
                label: l10n?.translate('checkoutPoNumberLabel') ?? 'PO number',
                value: poNumber.trim(),
              ),
            if (deliveryNotes.trim().isNotEmpty)
              _SummaryDetailRow(
                label: l10n?.translate('checkoutDeliveryNotesLabel') ??
                    'Delivery notes',
                value: deliveryNotes.trim(),
              ),
          ];

          if (metaDetails.isNotEmpty) {
            children
              ..addAll(metaDetails)
              ..add(const SizedBox(height: ASpacing.md));
          }

          if (hasForbidden) {
            final String bannerMessage = l10n
                    ?.translate('checkoutNotInCatalogBanner') ??
                'Some items are outside your catalog. Remove them to submit.';
            final String countLabel = forbiddenCount == 1
                ? '1 item requires attention'
                : '$forbiddenCount items require attention';
            children.add(
              Container(
                key: const ValueKey('checkout_not_in_catalog_banner'),
                margin: const EdgeInsets.only(bottom: ASpacing.md),
                padding: const EdgeInsets.all(ASpacing.md),
                decoration: BoxDecoration(
                  color: AColors.dangerSurface,
                  borderRadius: ARadii.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AColors.danger),
                    const SizedBox(width: ASpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bannerMessage,
                            style: ATypography.bodySm.copyWith(
                              color: AColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: ASpacing.xs),
                          Text(
                            countLabel,
                            style: ATypography.bodyXs.copyWith(
                              color: AColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (lines.isNotEmpty) {
            if (children.isNotEmpty) {
              children.add(const SizedBox(height: ASpacing.md));
            }
            children.addAll(
              lines.map(
                (CartLine line) => Padding(
                  padding: const EdgeInsets.only(bottom: ASpacing.sm),
                  child: _CheckoutLineEffectivePrice(
                    line: line,
                    companyId: pricingCompanyId,
                  ),
                ),
              ),
            );
            children.add(const SizedBox(height: ASpacing.lg));
          }

          children
            ..add(
              _SummaryRow(
                label: subtotalLabel,
                value: currency.format(subtotal),
              ),
            )
            ..add(const SizedBox(height: ASpacing.sm))
            ..add(
              _SummaryRow(
                label: taxesLabel,
                value: currency.format(taxes),
              ),
            )
            ..add(const Divider(height: ASpacing.xxl))
            ..add(
              _SummaryRow(
                label: totalLabel,
                value: currency.format(grandTotal),
                emphasize: true,
              ),
            )
            ..add(const SizedBox(height: ASpacing.xxl))
            ..add(
              _buildApprovalAction(
                context: context,
                hasLines: lines.isNotEmpty,
                approvalState: approvalState,
                approvalsLoading: approvalsLoading,
                approvalError: approvalError,
                hasForbidden: hasForbidden,
              ),
            );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        },
      ),
    );
  }

  Widget _buildApprovalAction({
    required BuildContext context,
    required bool hasLines,
    required OrderApprovalState? approvalState,
    required bool approvalsLoading,
    required Object? approvalError,
    required bool hasForbidden,
  }) {
    if (!hasLines) {
      return const SizedBox.shrink();
    }

    if (approvalsLoading && approvalState == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ASpacing.sm),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (approvalError != null) {
      final String message = l10n?.translate('approvalBannerError') ??
          'Could not load approval status.';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: ATypography.bodySm.copyWith(color: AColors.danger),
          ),
          const SizedBox(height: ASpacing.md),
          _buildReviewButton(),
        ],
      );
    }

    if (approvalState == null || !approvalState.requiresApproval) {
      return _buildReviewButton();
    }

    final bool canSubmit =
        approvalState.stage == OrderApprovalStage.approved && !hasForbidden;
    final Widget submitButton = AButton.primary(
      key: const ValueKey('checkout_submit_btn'),
      expand: true,
      label: isSubmittingOrder
          ? l10n?.translate('approvalSubmitLoading') ?? 'Submitting...'
          : l10n?.translate('approvalSubmitButton') ?? 'Submit order',
      icon: const Icon(Icons.check_circle_outline, size: 18),
      loading: isSubmittingOrder,
      onPressed:
          !isSubmittingOrder && canSubmit ? onSubmitApprovedPressed : null,
    );

    switch (approvalState.stage) {
      case OrderApprovalStage.readyToRequest:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AButton.primary(
              key: const ValueKey('checkout_send_for_approval_btn'),
              expand: true,
              label: isSendingApproval
                  ? l10n?.translate('approvalSendLoading') ?? 'Sending...'
                  : l10n?.translate('approvalSendButton') ??
                      'Send for approval',
              icon: const Icon(Icons.send, size: 18),
              loading: isSendingApproval,
              onPressed: isSendingApproval ? null : onSendForApprovalPressed,
            ),
            const SizedBox(height: ASpacing.sm),
            submitButton,
          ],
        );
      case OrderApprovalStage.rejected:
        final String helper = l10n?.translate('approvalRejectedHint') ??
            'Update the order details and resend for approval.';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AButton.primary(
              key: const ValueKey('checkout_send_for_approval_btn'),
              expand: true,
              label: isSendingApproval
                  ? l10n?.translate('approvalSendLoading') ?? 'Sending...'
                  : l10n?.translate('approvalResendButton') ??
                      'Resend for approval',
              icon: const Icon(Icons.refresh, size: 18),
              loading: isSendingApproval,
              onPressed: isSendingApproval ? null : onSendForApprovalPressed,
            ),
            const SizedBox(height: ASpacing.sm),
            Text(
              helper,
              style: ATypography.bodyXs.copyWith(color: AColors.danger),
            ),
            const SizedBox(height: ASpacing.md),
            submitButton,
          ],
        );
      case OrderApprovalStage.pending:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AButton.secondary(
              expand: true,
              label:
                  l10n?.translate('approvalPendingCta') ?? 'Awaiting approval',
              icon: const Icon(Icons.hourglass_bottom, size: 18),
              onPressed: null,
            ),
            const SizedBox(height: ASpacing.sm),
            submitButton,
          ],
        );
      case OrderApprovalStage.approved:
        return submitButton;
      case OrderApprovalStage.notRequired:
        return _buildReviewButton();
    }
  }

  Widget _buildReviewButton() {
    return AButton.primary(
      key: const ValueKey('checkout_submit_btn'),
      expand: true,
      label: l10n?.translate('checkoutContinueButton') ?? 'Review and confirm',
      icon: const Icon(Icons.check_circle_outline, size: 18),
      onPressed: onReviewPressed,
    );
  }
}

class _CheckoutLinePriceRequest {
  const _CheckoutLinePriceRequest({
    required this.companyId,
    required this.variantId,
    required this.qty,
  });

  final String companyId;
  final String variantId;
  final double qty;

  @override
  bool operator ==(Object other) {
    return other is _CheckoutLinePriceRequest &&
        other.companyId == companyId &&
        other.variantId == variantId &&
        (other.qty - qty).abs() < 1e-6;
  }

  @override
  int get hashCode => Object.hash(companyId, variantId, qty);
}

final _checkoutLinePriceProvider = FutureProvider.autoDispose
    .family<PriceResolution?, _CheckoutLinePriceRequest>((ref, request) async {
  if (request.companyId.isEmpty) {
    return null;
  }
  final double safeQty = request.qty <= 0 ? 1 : request.qty;
  final svc = ref.read(priceResolutionServiceProvider);
  return svc.resolve(
    companyId: request.companyId,
    variantId: request.variantId,
    qty: safeQty,
  );
});

class _CheckoutLineEffectivePrice extends ConsumerWidget {
  const _CheckoutLineEffectivePrice({
    required this.line,
    required this.companyId,
  });

  final CartLine line;
  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle = ATypography.bodySm.copyWith(
      fontWeight: FontWeight.w600,
    );
    final TextStyle baseLabelStyle =
        theme.textTheme.bodySmall ?? ATypography.bodySm.copyWith();
    final TextStyle labelStyle = baseLabelStyle.copyWith(
      color: baseLabelStyle.color?.withValues(alpha: 0.72) ??
          theme.colorScheme.onSurface.withValues(alpha: 0.72),
    );
    final TextStyle valueStyle =
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600) ??
            ATypography.bodyMd.copyWith(fontWeight: FontWeight.w600);
    final String label =
        l10n?.translate('productEffectivePriceLabel') ?? 'Effective price';
    final String dashLabel = l10n?.translate('dash') ?? '—';
    final String contractLabel =
        l10n?.translate('contractPrice') ?? 'Contract price';

    final AsyncValue<PriceResolution?> priceAsync = companyId.isEmpty
        ? const AsyncValue<PriceResolution?>.data(null)
        : ref.watch(
            _checkoutLinePriceProvider(
              _CheckoutLinePriceRequest(
                companyId: companyId,
                variantId: line.variantId,
                qty: line.qty,
              ),
            ),
          );

    Widget buildRow(Widget value) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stack = constraints.maxWidth < 360;
          final Widget labelWidget = Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          );
          final Widget valueWidget = Align(
            alignment: stack
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: value,
          );
          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelWidget,
                const SizedBox(height: ASpacing.xs),
                valueWidget,
              ],
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: labelWidget),
              const SizedBox(width: ASpacing.sm),
              Flexible(child: valueWidget),
            ],
          );
        },
      );
    }

    Widget buildContent(PriceResolution? price) {
      final String valueText = price != null ? _formatPrice(price) : dashLabel;
      final List<Widget> columnChildren = <Widget>[
        buildRow(
          Text(
            valueText,
            key: ValueKey<String>('checkout_line_price_${line.variantId}'),
            style: valueStyle,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      ];
      if (price != null && price.source.toLowerCase() != 'base') {
        columnChildren
          ..add(const SizedBox(height: ASpacing.xs))
          ..add(
            ContractPriceBadge(
              key: ValueKey<String>(
                  'checkout_line_contract_chip_${line.variantId}'),
              label: contractLabel,
            ),
          );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: columnChildren,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(line.displayTitle, style: titleStyle),
        const SizedBox(height: ASpacing.xs),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: priceAsync.when(
            data: buildContent,
            loading: () => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildRow(
                  const SizedBox(
                    width: 96,
                    child: ASkeleton(height: 16),
                  ),
                ),
              ],
            ),
            error: (_, __) => buildContent(null),
          ),
        ),
      ],
    );
  }
}

String _formatPrice(PriceResolution price) {
  try {
    final intl.NumberFormat formatter =
        intl.NumberFormat.currency(name: price.currency);
    return formatter.format(price.price);
  } catch (_) {
    return '${price.currency} ${price.price.toStringAsFixed(2)}';
  }
}

String _companyIdFromSession(Session? session) {
  final Object? raw = session?.user.appMetadata['company_id'];
  if (raw is String && raw.isNotEmpty) {
    return raw;
  }
  return '';
}

bool _isLineNotInCatalog(
  String companyId,
  Set<String>? companyCatalog,
  CartLine line,
) {
  if (companyId.isEmpty || companyCatalog == null) {
    return false;
  }
  return !companyCatalog.contains(line.variantId);
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: title,
      header: true,
      child: Card(
        elevation: AElevation.level1,
        shape: RoundedRectangleBorder(borderRadius: ARadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(ASpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ATypography.titleMd),
              const SizedBox(height: ASpacing.lg),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutDetailTile extends StatelessWidget {
  const _CheckoutDetailTile({
    required this.title,
    this.body,
    this.footer,
  });

  final String title;
  final String? body;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AColors.surfaceSubtle,
        borderRadius: ARadii.md,
        border: Border.all(color: AColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(ASpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ATypography.bodyMd,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (body != null && body!.trim().isNotEmpty) ...[
            const SizedBox(height: ASpacing.xs),
            Text(
              body!,
              style: ATypography.bodySm,
            ),
          ],
          if (footer != null && footer!.trim().isNotEmpty) ...[
            const SizedBox(height: ASpacing.xs),
            Text(
              footer!,
              style: ATypography.bodyXs.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryDetailRow extends StatelessWidget {
  const _SummaryDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = ATypography.bodySm.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: ASpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          if (value.trim().isNotEmpty) ...[
            const SizedBox(height: ASpacing.xs),
            Text(value, style: ATypography.bodySm),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = emphasize
        ? ATypography.titleSm
        : ATypography.bodyMd.copyWith(color: AColors.mutedForeground);
    final TextStyle valueStyle =
        emphasize ? ATypography.titleMd : ATypography.bodyMd;

    return Semantics(
      label: label,
      value: value,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stack = constraints.maxWidth < 360;
          final Widget labelWidget = Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          );
          final Widget valueWidget = Text(
            value,
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: stack ? TextAlign.start : TextAlign.end,
          );
          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelWidget,
                const SizedBox(height: ASpacing.xs),
                valueWidget,
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: labelWidget),
              const SizedBox(width: ASpacing.lg),
              Flexible(child: valueWidget),
            ],
          );
        },
      ),
    );
  }
}

// Legacy classes removed in favour of dynamic checkout options.
