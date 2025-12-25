import 'package:flutter/material.dart';

/// Central design tokens shared across customer-facing widgets.
class AColors {
  AColors._();

  static const Color primary = Color(0xFF0CECDD);
  static const Color primaryDark = Color(0xFF06B6B8);
  static const Color primaryLight = Color(0xFFD5FFFB);
  static const Color primaryMuted = Color(0xFFEAFFFC);

  static const Color accent = Color(0xFF1D9BF0);

  static const Color foreground = Color(0xFF0B1224);
  static const Color mutedForeground = Color(0xFF6B7287);

  static const Color surface = Color(0xFFF9FBFF);
  static const Color surfaceMuted = Color(0xFFF0F4FB);
  static const Color surfaceSubtle = Color(0xFFE2E8F6);
  static const Color background = Color(0xFFF4F7FD);
  static const Color authBackgroundStart = Color(0xFF0C1226);
  static const Color authBackgroundEnd = Color(0xFF0F1D36);

  static const Color borderSubtle = Color(0xFFE4E9F2);
  static const Color borderStrong = Color(0xFFC7D4E8);
  static const Color cardBorder = Color(0xFFB6C6DE);

  static const Color neutral100 = Color(0xFFF7F9FC);
  static const Color neutral200 = Color(0xFFE6EDF6);
  static const Color neutral300 = Color(0xFFC7D2E4);
  static const Color neutral400 = Color(0xFF96A3BC);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5565);
  static const Color neutral900 = Color(0xFF0B1224);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color dangerSurface = Color(0xFFFEE2E2);
  static const Color dangerBorder = Color(0xFFFCA5A5);

  static const Color midnight = Color(0xFF080F1F);
  static const Color midnightDeep = Color(0xFF060A14);
  static const Color auroraBlue = Color(0xFF00B5FF);
  static const Color auroraCyan = Color(0xFF00F5D4);
  static const Color auroraLime = Color(0xFFC8FF70);
  static const Color glassOverlay = Color(0x66FFFFFF);

  static const Color foregroundOnDark = Color(0xFFF4F7FD);
  static const Color mutedForegroundOnDark = Color(0xFFCBD7EC);
  static const Color surfaceGlassDark = Color(0xFF0F1D36);
}

class ASpacing {
  ASpacing._();

  static const double grid = 4;

  static const double xxs = grid;
  static const double xs = grid * 1; // 4
  static const double sm = grid * 2; // 8
  static const double md = grid * 3; // 12
  static const double lg = grid * 4; // 16
  static const double xl = grid * 6; // 24
  static const double xxl = grid * 8; // 32
  static const double xxxl = grid * 10; // 40

  static const double interactive = 44;
  static const double gutter = 20;
  static const double page = 28;

  static SizedBox gapRow([double size = md]) => SizedBox(height: size);
  static SizedBox gapCol([double size = md]) => SizedBox(width: size);
}

class ARadii {
  ARadii._();

  static const BorderRadius xs = BorderRadius.all(Radius.circular(6));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(12));
  static const BorderRadius md = BorderRadius.all(Radius.circular(16));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(24));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(32));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

class AElevation {
  AElevation._();

  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level3 = 4;
  static const double level4 = 8;
  static const double level5 = 12;

  static const List<BoxShadow> shadowSoft = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A111827),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}

class ATypography {
  ATypography._();

  static const TextStyle display = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AColors.foreground,
  );

  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AColors.foreground,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.22,
    color: AColors.foreground,
  );

  static const TextStyle titleLg = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.27,
    color: AColors.foreground,
  );

  static const TextStyle titleMd = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.33,
    color: AColors.foreground,
  );

  static const TextStyle titleSm = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AColors.foreground,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AColors.foreground,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: AColors.foreground,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AColors.mutedForeground,
  );

  static const TextStyle bodyXs = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AColors.mutedForeground,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
    color: AColors.mutedForeground,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.2,
    color: AColors.foreground,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: Colors.white,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AColors.foreground,
  );
}

extension AThemeExtension on BuildContext {
  TextDirection get textDirection => Directionality.of(this);
  bool get isRtl => textDirection == TextDirection.rtl;

  EdgeInsetsDirectional pagePadding() => const EdgeInsetsDirectional.symmetric(
        horizontal: ASpacing.page,
        vertical: ASpacing.lg,
      );
}
