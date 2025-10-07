import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';

class ContractPriceBadge extends StatelessWidget {
  const ContractPriceBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.sm,
        vertical: ASpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AColors.primary.withValues(alpha: 0.08),
        borderRadius: ARadii.pill,
      ),
      child: Text(
        label,
        style: ATypography.bodyXs.copyWith(
          color: AColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
