import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/admin/cashback/data/admin_cashback_providers.dart';
import 'package:ashachar_marketplace/src/features/admin/cashback/domain/admin_cashback_models.dart';

/// Admin view of cashback across customers: total outstanding liability, a
/// per-company balance list, and a manual adjustment action.
class AdminCashbackPage extends ConsumerWidget {
  const AdminCashbackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
            context, MarketplaceLocalizations);
    String tr(String key, String fallback) => l10n?.translate(key) ?? fallback;

    final AsyncValue<List<AdminCashbackRow>> rowsAsync =
        ref.watch(adminCashbackOverviewProvider);
    final EdgeInsets padding =
        context.pagePadding().resolve(Directionality.of(context));
    final intl.NumberFormat ils = intl.NumberFormat.simpleCurrency(name: 'ILS');

    return Scaffold(
      appBar: AppBar(title: Text(tr('adminCashbackTitle', 'זיכויים (אדמין)'))),
      backgroundColor: AColors.background,
      body: rowsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => Center(
          child: Text(tr('adminCashbackError', 'טעינת הזיכויים נכשלה.')),
        ),
        data: (List<AdminCashbackRow> rows) {
          final double liability = rows.fold<double>(
              0, (double sum, AdminCashbackRow r) => sum + r.balanceIls);
          return SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _LiabilityCard(
                  label: tr('adminCashbackLiability', 'סך התחייבות זיכויים'),
                  value: ils.format(liability),
                ),
                const SizedBox(height: 24),
                Text(tr('adminCashbackByCompany', 'יתרות לפי חברה'),
                    style: ATypography.titleMd),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      tr('adminCashbackEmpty', 'אין יתרות זיכוי.'),
                      style: ATypography.bodyLg
                          .copyWith(color: AColors.mutedForeground),
                    ),
                  )
                else
                  ...rows.map(
                    (AdminCashbackRow row) => _CompanyRow(
                      row: row,
                      formatted: ils.format(row.balanceIls),
                      tr: tr,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiabilityCard extends StatelessWidget {
  const _LiabilityCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label,
                style: ATypography.bodySm
                    .copyWith(color: AColors.mutedForeground)),
            const SizedBox(height: 8),
            Text(value, style: ATypography.headline2.copyWith(fontSize: 26)),
          ],
        ),
      ),
    );
  }
}

class _CompanyRow extends ConsumerWidget {
  const _CompanyRow({
    required this.row,
    required this.formatted,
    required this.tr,
  });

  final AdminCashbackRow row;
  final String formatted;
  final String Function(String, String) tr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(row.companyName, style: ATypography.bodyLg),
      subtitle: Text(formatted,
          style: ATypography.bodySm.copyWith(color: AColors.mutedForeground)),
      trailing: TextButton(
        onPressed: () => _showAdjustSheet(context),
        child: Text(tr('adminCashbackAdjustCta', 'התאמה')),
      ),
    );
  }

  Future<void> _showAdjustSheet(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool? done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) => _AdjustSheet(row: row, tr: tr),
    );
    if (done == true) {
      messenger.showSnackBar(
        SnackBar(content: Text(tr('adminCashbackAdjusted', 'ההתאמה נשמרה'))),
      );
    }
  }
}

class _AdjustSheet extends ConsumerStatefulWidget {
  const _AdjustSheet({required this.row, required this.tr});

  final AdminCashbackRow row;
  final String Function(String, String) tr;

  @override
  ConsumerState<_AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends ConsumerState<_AdjustSheet> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _note = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String Function(String, String) tr = widget.tr;
    final double? amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount == 0) {
      setState(() => _error = tr('adminCashbackAdjustInvalid', 'יש להזין סכום שונה מאפס'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(adminCashbackRepositoryProvider).adjust(
            companyId: widget.row.companyId,
            amountIls: amount,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      ref.invalidate(adminCashbackOverviewProvider);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = tr('adminCashbackAdjustFailed', 'ההתאמה נכשלה, נסו שוב');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String Function(String, String) tr = widget.tr;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 8, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${tr('adminCashbackAdjustCta', 'התאמה')} · ${widget.row.companyName}',
              style: ATypography.titleMd),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            enabled: !_loading,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            decoration: InputDecoration(
              labelText: tr('adminCashbackAdjustAmount', 'סכום (₪, שלילי = חיוב)'),
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: tr('adminCashbackAdjustNote', 'הערה (לא חובה)'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
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
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(tr('adminCashbackAdjustConfirm', 'שמירה')),
            ),
          ),
        ],
      ),
    );
  }
}
