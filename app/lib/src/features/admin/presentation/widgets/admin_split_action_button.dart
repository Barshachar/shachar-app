import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/features/admin/presentation/admin_ui_actions.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_action_keys.dart';

class AdminSplitActionButton extends StatefulWidget {
  const AdminSplitActionButton({
    super.key,
    required this.orderId,
    required this.callSplit,
    this.onMessage,
  });

  final String orderId;
  final Future<String> Function() callSplit;
  final void Function(String message)? onMessage;

  @override
  State<AdminSplitActionButton> createState() => _AdminSplitActionButtonState();
}

class _AdminSplitActionButtonState extends State<AdminSplitActionButton> {
  bool _busy = false;
  String? _result;

  void _showMessage(String message) {
    widget.onMessage?.call(message);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSplit() async {
    setState(() => _busy = true);
    final String result = await splitOrderUI(
      orderId: widget.orderId,
      callSplit: widget.callSplit,
      showMessage: _showMessage,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          key: adminSplitButtonKey,
          onPressed: _busy ? null : _handleSplit,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.alt_route),
          label: Text(_busy ? 'Splitting…' : 'Split Order'),
        ),
        if (_result != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _result!,
              key: adminSplitResultKey,
            ),
          ),
      ],
    );
  }
}
