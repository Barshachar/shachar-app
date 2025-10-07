import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  final TextEditingController _vatController =
      TextEditingController(text: '18');

  String _selectedCountry = 'Israel';
  bool _taxInclusive = true;
  bool _shipToAutoDetect = true;
  String? _exemptCustomers;
  final List<String> _taxIds = <String>['IL123456789', 'ZZ987654321'];
  bool _exportAsTaxable = false;
  bool _importAsTaxable = false;

  @override
  void dispose() {
    _vatController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tax settings saved and synced.')),
    );
  }

  Future<void> _promptAddRule() async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add tax ID'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new tax identifier',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (result == null || result.isEmpty) {
      return;
    }
    setState(() => _taxIds.add(result));
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding =
        context.pagePadding().resolve(Directionality.of(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Settings'),
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AColors.background,
      body: SingleChildScrollView(
        padding: padding,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F1A2E),
                blurRadius: 28,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: _fieldDecoration('Country'),
                  items: const [
                    DropdownMenuItem(value: 'Israel', child: Text('Israel')),
                    DropdownMenuItem(
                        value: 'United States', child: Text('United States')),
                    DropdownMenuItem(value: 'Germany', child: Text('Germany')),
                  ],
                  onChanged: (String? value) {
                    if (value == null) return;
                    setState(() => _selectedCountry = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vatController,
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration('VAT').copyWith(
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 16),
                _ToggleTile(
                  label: 'Tax inclusive',
                  value: _taxInclusive,
                  onChanged: (bool value) =>
                      setState(() => _taxInclusive = value),
                ),
                _CheckboxTile(
                  label: 'Ship-to auto-detect tax',
                  value: _shipToAutoDetect,
                  onChanged: (bool? value) => setState(
                    () => _shipToAutoDetect = value ?? false,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _exemptCustomers,
                  decoration: _fieldDecoration('Exempt customers'),
                  hint: const Text('None'),
                  items: const [
                    DropdownMenuItem(
                        value: 'nonprofit', child: Text('Non-profit accounts')),
                    DropdownMenuItem(
                        value: 'gov', child: Text('Government entities')),
                  ],
                  onChanged: (String? value) =>
                      setState(() => _exemptCustomers = value),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tax IDs',
                  style:
                      ATypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _taxIds
                      .map((String id) => Chip(
                            label: Text(id),
                            onDeleted: () => setState(() => _taxIds.remove(id)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  onPressed: _promptAddRule,
                  child: const Text('Add Rule'),
                ),
                const SizedBox(height: 24),
                _ToggleTile(
                  label: 'Export as taxable',
                  value: _exportAsTaxable,
                  onChanged: (bool value) =>
                      setState(() => _exportAsTaxable = value),
                ),
                _ToggleTile(
                  label: 'Import as taxable',
                  value: _importAsTaxable,
                  onChanged: (bool value) =>
                      setState(() => _importAsTaxable = value),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: _saveSettings,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: ATypography.bodyLg,
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AColors.primary,
        ),
      ],
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  const _CheckboxTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: ATypography.bodyLg,
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
