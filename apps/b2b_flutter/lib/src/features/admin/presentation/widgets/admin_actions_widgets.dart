import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ashachar_marketplace/src/features/admin/presentation/admin_ui_actions.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/widgets/admin_action_keys.dart';

class AdminSplitActionButton extends StatefulWidget {
  const AdminSplitActionButton({
    super.key,
    required this.orderId,
    required this.callSplit,
    this.onMessage,
    this.onSuccess,
  });

  final String orderId;
  final Future<String> Function() callSplit;
  final ValueChanged<String>? onMessage;
  final ValueChanged<String>? onSuccess;

  @override
  State<AdminSplitActionButton> createState() => _AdminSplitActionButtonState();
}

class _AdminSplitActionButtonState extends State<AdminSplitActionButton> {
  bool _busy = false;
  String? _result;

  void _forwardMessage(String message) {
    widget.onMessage?.call(message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleSplit() async {
    setState(() => _busy = true);
    final String result = await splitOrderUI(
      orderId: widget.orderId,
      callSplit: widget.callSplit,
      showMessage: _forwardMessage,
    );
    widget.onSuccess?.call(result);
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
        FilledButton.icon(
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

class AdminReportActionButton extends StatefulWidget {
  const AdminReportActionButton({
    super.key,
    required this.callReport,
    this.onMessage,
    this.onSuccess,
  });

  final Future<ReportRecord> Function() callReport;
  final ValueChanged<String>? onMessage;
  final Future<void> Function(ReportRecord record)? onSuccess;

  @override
  State<AdminReportActionButton> createState() =>
      _AdminReportActionButtonState();
}

class _AdminReportActionButtonState extends State<AdminReportActionButton> {
  bool _busy = false;
  String? _url;

  void _forwardMessage(String message) {
    widget.onMessage?.call(message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleReport() async {
    setState(() => _busy = true);
    ReportRecord? record;
    final String url = await generateReportUI(
      callReport: () async {
        record = await widget.callReport();
        return record!;
      },
      showMessage: _forwardMessage,
    );
    if (!mounted) return;
    if (url.isNotEmpty && record != null) {
      await widget.onSuccess?.call(record!);
    }
    setState(() {
      _url = url.isNotEmpty ? url : null;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          key: adminReportButtonKey,
          onPressed: _busy ? null : _handleReport,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.description_outlined),
          label: Text(_busy ? 'Generating…' : 'Generate CSV'),
        ),
        if (_url != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _url!,
                    key: adminReportUrlKey,
                    maxLines: 1,
                  ),
                ),
                TextButton.icon(
                  key: adminReportCopyButtonKey,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _url!));
                    _forwardMessage('Link copied to clipboard');
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AdminImportActionButton extends StatefulWidget {
  const AdminImportActionButton({
    super.key,
    required this.callImport,
    this.onMessage,
    this.onSuccess,
  });

  final Future<int> Function() callImport;
  final ValueChanged<String>? onMessage;
  final ValueChanged<String>? onSuccess;

  @override
  State<AdminImportActionButton> createState() =>
      _AdminImportActionButtonState();
}

class _AdminImportActionButtonState extends State<AdminImportActionButton> {
  bool _picked = false;
  bool _busy = false;
  String? _result;

  void _forwardMessage(String message) {
    widget.onMessage?.call(message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleUpload() async {
    if (!_picked) {
      _forwardMessage('Select a CSV first');
      return;
    }
    setState(() => _busy = true);
    final String message = await importPricesUI(
      callImport: widget.callImport,
      showMessage: _forwardMessage,
    );
    widget.onSuccess?.call(message);
    if (!mounted) return;
    setState(() {
      _result = message;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              key: adminImportPickButtonKey,
              onPressed: _busy
                  ? null
                  : () {
                      setState(() => _picked = true);
                      _forwardMessage('CSV selected');
                    },
              child: const Text('Pick CSV'),
            ),
            FilledButton(
              key: adminImportUploadButtonKey,
              onPressed: _busy ? null : _handleUpload,
              child: Text(_busy ? 'Uploading…' : 'Upload'),
            ),
          ],
        ),
        if (_result != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _result!,
              key: adminImportResultKey,
            ),
          ),
      ],
    );
  }
}
