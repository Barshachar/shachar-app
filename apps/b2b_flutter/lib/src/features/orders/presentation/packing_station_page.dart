import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/features/orders/data/packing_station_providers.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/packing_station_models.dart';

class PackingStationPage extends ConsumerWidget {
  const PackingStationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PackingStationOrder order = ref.watch(packingStationOrderProvider);
    final PackingStationController controller =
        ref.watch(packingStationOrderProvider.notifier);
    final EdgeInsets padding =
        context.pagePadding().resolve(Directionality.of(context));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Packing Station'),
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
                blurRadius: 26,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ${order.orderNumber}',
                  style: ATypography.titleMd,
                ),
                const SizedBox(height: 20),
                ...List.generate(order.lines.length, (int index) {
                  final PackingStationLine line = order.lines[index];
                  return Column(
                    children: [
                      _PackingLine(
                        line: line,
                        onQuantityChanged: (int value) {
                          controller.updateLine(index: index, quantity: value);
                        },
                      ),
                      if (index != order.lines.length - 1)
                        const Divider(height: 28),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                _InfoTile(
                  label: 'Box dimensions',
                  value: order.boxDimensions,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  label: 'Weight',
                  value: '${order.weight.toStringAsFixed(1)} lb',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AColors.primary,
                          side: const BorderSide(color: AColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Packing slip queued for print.')),
                          );
                        },
                        child: const Text('Print Packing Slip'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Order marked as packed')),
                          );
                        },
                        child: const Text('Mark as Packed'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackingLine extends StatelessWidget {
  const _PackingLine({
    required this.line,
    required this.onQuantityChanged,
  });

  final PackingStationLine line;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LineAvatar(symbol: line.symbol),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.name,
                style: ATypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: ${line.quantityOrdered}',
                style: ATypography.bodySm,
              ),
            ],
          ),
        ),
        _QuantityStepper(
          value: line.quantityPacked,
          min: 0,
          max: line.quantityOrdered,
          onChanged: onQuantityChanged,
        ),
      ],
    );
  }
}

class _LineAvatar extends StatelessWidget {
  const _LineAvatar({required this.symbol});

  final String? symbol;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (symbol) {
      'brush' => Icons.brush,
      'paint' => Icons.palette,
      'roller' => Icons.format_paint,
      _ => Icons.inventory_2_outlined,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AColors.primary),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '$value',
              style: ATypography.bodyLg,
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Icon(
          icon,
          size: 18,
          color: onPressed == null ? AColors.neutral300 : AColors.primary,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label $value',
        style: ATypography.bodyLg,
      ),
    );
  }
}
