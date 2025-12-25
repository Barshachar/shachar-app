import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core color tokens match design system palette', () {
    expect(AColors.primary, const Color(0xFF0CECDD));
    expect(AColors.foreground, const Color(0xFF0B1224));
    expect(AColors.background, const Color(0xFFF4F7FD));
    expect(AColors.success, const Color(0xFF22C55E));
  });

  test('spacing scale and helpers stay consistent', () {
    expect(ASpacing.xs, 4);
    expect(ASpacing.sm, 8);
    expect(ASpacing.lg, 16);

    final SizedBox rowGap = ASpacing.gapRow();
    final SizedBox colGap = ASpacing.gapCol(ASpacing.xl);
    expect(rowGap.height, ASpacing.md);
    expect(colGap.width, ASpacing.xl);
  });

  test('typography tokens expose new headline/body styles', () {
    expect(ATypography.titleMd.fontSize, 18);
    expect(ATypography.titleMd.fontWeight, FontWeight.w700);
    expect(ATypography.bodySm.fontSize, 12);
    expect(ATypography.chip.fontSize, 11);
  });
}
