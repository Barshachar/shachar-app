import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/rfq/presentation/rfq_providers.dart';

Future<String?> showRfqCreateDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<CartLine> cartLines,
}) {
  if (cartLines.isEmpty) {
    return Future<String?>.value(null);
  }
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return _RfqCreateDialog(
        cartLines: cartLines,
      );
    },
  );
}

class _RfqCreateDialog extends ConsumerStatefulWidget {
  const _RfqCreateDialog({
    required this.cartLines,
  });

  final List<CartLine> cartLines;

  @override
  ConsumerState<_RfqCreateDialog> createState() => _RfqCreateDialogState();
}

class _RfqCreateDialogState extends ConsumerState<_RfqCreateDialog> {
  late final List<TextEditingController> _itemNotesControllers;
  late final List<TextEditingController> _qtyControllers;
  late final TextEditingController _generalTermsController;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _itemNotesControllers = widget.cartLines
        .map((_) => TextEditingController())
        .toList(growable: false);
    _qtyControllers = widget.cartLines
        .map((CartLine line) =>
            TextEditingController(text: line.qty.toStringAsFixed(2)))
        .toList(growable: false);
    _generalTermsController = TextEditingController();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _itemNotesControllers) {
      controller.dispose();
    }
    for (final TextEditingController controller in _qtyControllers) {
      controller.dispose();
    }
    _generalTermsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        'בקשת הצעת מחיר',
        style: theme.textTheme.titleLarge,
      ),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    for (int i = 0; i < widget.cartLines.length; i++)
                      _RequestItemCard(
                        line: widget.cartLines[i],
                        qtyController: _qtyControllers[i],
                        notesController: _itemNotesControllers[i],
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _generalTermsController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'הערות ותנאים כלליים',
                        hintText:
                            'למשל: זמני אספקה רצויים, תנאי תשלום, כתובת אספקה',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
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
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).maybePop<String?>(null),
          child: const Text('ביטול'),
        ),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: const Text('שליחת בקשה'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final List<RfqDraftLine> lines = <RfqDraftLine>[];
      for (int i = 0; i < widget.cartLines.length; i++) {
        final CartLine line = widget.cartLines[i];
        final double? qty =
            double.tryParse(_qtyControllers[i].text.replaceAll(',', '.'));
        if (qty == null || qty <= 0) {
          throw ArgumentError('כמות לא חוקית עבור ${line.displayTitle}');
        }
        lines.add(
          RfqDraftLine(
            variantId: line.variantId,
            qty: qty,
            customerNotes: _itemNotesControllers[i].text.trim().isEmpty
                ? null
                : _itemNotesControllers[i].text.trim(),
          ),
        );
      }

      final Map<String, dynamic> terms = <String, dynamic>{};
      final String notes = _generalTermsController.text.trim();
      if (notes.isNotEmpty) {
        terms['notes'] = notes;
      }
      final String rfqId = await ref
          .read(rfqActionControllerProvider)
          .createRfq(lines: lines, terms: terms.isEmpty ? null : terms);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop<String?>(rfqId);
    } on ArgumentError catch (error) {
      setState(() {
        _errorMessage = error.message?.toString() ?? error.toString();
      });
    } on Object catch (error) {
      setState(() {
        _errorMessage = 'הבקשה נכשלה: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _RequestItemCard extends StatelessWidget {
  const _RequestItemCard({
    required this.line,
    required this.qtyController,
    required this.notesController,
  });

  final CartLine line;
  final TextEditingController qtyController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              line.displayTitle,
              style: theme.textTheme.titleMedium,
            ),
            if (line.variantLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                line.variantLabel,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'כמות',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'הערות לפריט',
                      hintText: 'למשל: אחסון בקירור, חלופה אפשרית',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
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
