import 'package:flutter/material.dart';

/// Central design tokens shared across customer-facing widgets.
class AColors {
  AColors._();

  static const Color primary = Color(0xFFC93A2F);
  static const Color primaryDark = Color(0xFFA62F26);
  static const Color primaryLight = Color(0xFFF2D6D3);
  static const Color primaryMuted = Color(0xFFF8E6E3);

  static const Color accent = Color(0xFF2563EB);

  // Premium accents — used by promotional / "club" surfaces.
  static const Color premiumGold = Color(0xFFE7B24B);
  static const Color premiumGoldLight = Color(0xFFF6D88A);
  static const Color premiumGoldDeep = Color(0xFFB8842B);
  static const Color premiumInk = Color(0xFF2A0F0C);

  static const Color foreground = Color(0xFF111827);
  static const Color mutedForeground = Color(0xFF6B7280);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F5F4);
  static const Color surfaceSubtle = Color(0xFFE8ECE8);
  static const Color background = Color(0xFFF7F9F7);
  static const Color authBackgroundStart = Color(0xFFF8F0EE);
  static const Color authBackgroundEnd = Color(0xFFFDF9F8);

  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFFCBD2D9);
  static const Color cardBorder = Color(0xFFD9E0E5);

  static const Color neutral100 = Color(0xFFFBFBFB);
  static const Color neutral200 = Color(0xFFEFF1F3);
  static const Color neutral300 = Color(0xFFD7DDE2);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral900 = Color(0xFF111827);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color dangerSurface = Color(0xFFFEE2E2);
  static const Color dangerBorder = Color(0xFFFCA5A5);
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
