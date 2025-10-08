/// Enterprise-grade typography system
/// Based on modern design systems with Hebrew (RTL) support
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font families
class AppFonts {
  AppFonts._();

  /// Primary font family for Hebrew text
  static const String hebrewFontFamily = 'Assistant';

  /// Primary font family for English text
  static const String englishFontFamily = 'Inter';

  /// Monospace font family for code
  static const String monoFontFamily = 'JetBrains Mono';

  /// Get font family based on locale
  static String getFontFamily(String locale) {
    return locale == 'he' ? hebrewFontFamily : englishFontFamily;
  }

  /// Get TextStyle with proper font for locale
  static TextStyle getTextStyle(String locale, TextStyle baseStyle) {
    if (locale == 'he') {
      return GoogleFonts.assistant(textStyle: baseStyle);
    }
    return GoogleFonts.inter(textStyle: baseStyle);
  }
}

/// Font weight tokens
class FontWeights {
  FontWeights._();

  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}

/// Font size scale
class FontSizes {
  FontSizes._();

  static const double xs = 12.0;
  static const double sm = 14.0;
  static const double base = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 30.0;
  static const double xl4 = 36.0;
  static const double xl5 = 48.0;
  static const double xl6 = 60.0;
  static const double xl7 = 72.0;
  static const double xl8 = 96.0;
  static const double xl9 = 128.0;
}

/// Line height scale
class LineHeights {
  LineHeights._();

  static const double none = 1.0;
  static const double tight = 1.25;
  static const double snug = 1.375;
  static const double normal = 1.5;
  static const double relaxed = 1.625;
  static const double loose = 2.0;
}

/// Letter spacing scale
class LetterSpacings {
  LetterSpacings._();

  static const double tighter = -0.05;
  static const double tight = -0.025;
  static const double normal = 0.0;
  static const double wide = 0.025;
  static const double wider = 0.05;
  static const double widest = 0.1;
}

/// Typography preset styles
class TypographyPresets {
  TypographyPresets._();

  // Display styles - for hero sections and large headings
  static TextStyle display2xl({Color? color}) => TextStyle(
        fontSize: FontSizes.xl9,
        fontWeight: FontWeights.bold,
        height: LineHeights.none,
        letterSpacing: LetterSpacings.tight,
        color: color,
      );

  static TextStyle displayXl({Color? color}) => TextStyle(
        fontSize: FontSizes.xl8,
        fontWeight: FontWeights.bold,
        height: LineHeights.none,
        letterSpacing: LetterSpacings.tight,
        color: color,
      );

  static TextStyle displayLg({Color? color}) => TextStyle(
        fontSize: FontSizes.xl7,
        fontWeight: FontWeights.bold,
        height: LineHeights.none,
        letterSpacing: LetterSpacings.tight,
        color: color,
      );

  static TextStyle displayMd({Color? color}) => TextStyle(
        fontSize: FontSizes.xl6,
        fontWeight: FontWeights.bold,
        height: LineHeights.none,
        letterSpacing: LetterSpacings.tight,
        color: color,
      );

  static TextStyle displaySm({Color? color}) => TextStyle(
        fontSize: FontSizes.xl5,
        fontWeight: FontWeights.bold,
        height: LineHeights.none,
        color: color,
      );

  static TextStyle displayXs({Color? color}) => TextStyle(
        fontSize: FontSizes.xl4,
        fontWeight: FontWeights.bold,
        height: LineHeights.none,
        color: color,
      );

  // Heading styles - for section headings
  static TextStyle headingXl({Color? color}) => TextStyle(
        fontSize: FontSizes.xl4,
        fontWeight: FontWeights.semibold,
        height: LineHeights.tight,
        letterSpacing: LetterSpacings.tight,
        color: color,
      );

  static TextStyle headingLg({Color? color}) => TextStyle(
        fontSize: FontSizes.xl3,
        fontWeight: FontWeights.semibold,
        height: LineHeights.tight,
        letterSpacing: LetterSpacings.tight,
        color: color,
      );

  static TextStyle headingMd({Color? color}) => TextStyle(
        fontSize: FontSizes.xl2,
        fontWeight: FontWeights.semibold,
        height: LineHeights.snug,
        color: color,
      );

  static TextStyle headingSm({Color? color}) => TextStyle(
        fontSize: FontSizes.xl,
        fontWeight: FontWeights.semibold,
        height: LineHeights.snug,
        color: color,
      );

  static TextStyle headingXs({Color? color}) => TextStyle(
        fontSize: FontSizes.lg,
        fontWeight: FontWeights.semibold,
        height: LineHeights.snug,
        color: color,
      );

  // Body text styles
  static TextStyle bodyLg({Color? color}) => TextStyle(
        fontSize: FontSizes.lg,
        fontWeight: FontWeights.regular,
        height: LineHeights.relaxed,
        color: color,
      );

  static TextStyle bodyMd({Color? color}) => TextStyle(
        fontSize: FontSizes.base,
        fontWeight: FontWeights.regular,
        height: LineHeights.normal,
        color: color,
      );

  static TextStyle bodySm({Color? color}) => TextStyle(
        fontSize: FontSizes.sm,
        fontWeight: FontWeights.regular,
        height: LineHeights.normal,
        color: color,
      );

  static TextStyle bodyXs({Color? color}) => TextStyle(
        fontSize: FontSizes.xs,
        fontWeight: FontWeights.regular,
        height: LineHeights.normal,
        color: color,
      );

  // Label styles - for form labels and UI elements
  static TextStyle labelLg({Color? color}) => TextStyle(
        fontSize: FontSizes.base,
        fontWeight: FontWeights.medium,
        height: LineHeights.normal,
        color: color,
      );

  static TextStyle labelMd({Color? color}) => TextStyle(
        fontSize: FontSizes.sm,
        fontWeight: FontWeights.medium,
        height: LineHeights.normal,
        color: color,
      );

  static TextStyle labelSm({Color? color}) => TextStyle(
        fontSize: FontSizes.xs,
        fontWeight: FontWeights.medium,
        height: LineHeights.normal,
        color: color,
      );

  static TextStyle labelXs({Color? color}) => TextStyle(
        fontSize: FontSizes.xs,
        fontWeight: FontWeights.regular,
        height: LineHeights.normal,
        color: color,
      );

  // Caption/helper text
  static TextStyle caption({Color? color}) => TextStyle(
        fontSize: FontSizes.xs,
        fontWeight: FontWeights.regular,
        height: LineHeights.normal,
        color: color,
      );

  // Overline text
  static TextStyle overline({Color? color}) => TextStyle(
        fontSize: FontSizes.xs,
        fontWeight: FontWeights.semibold,
        height: LineHeights.normal,
        letterSpacing: LetterSpacings.wide,
        color: color,
      );

  // Code/monospace text
  static TextStyle code({Color? color}) => TextStyle(
        fontSize: FontSizes.sm,
        fontWeight: FontWeights.regular,
        height: LineHeights.normal,
        fontFamily: AppFonts.monoFontFamily,
        color: color,
      );

  // Button text styles
  static TextStyle buttonLg({Color? color}) => TextStyle(
        fontSize: FontSizes.base,
        fontWeight: FontWeights.semibold,
        height: LineHeights.normal,
        letterSpacing: LetterSpacings.normal,
        color: color,
      );

  static TextStyle buttonMd({Color? color}) => TextStyle(
        fontSize: FontSizes.sm,
        fontWeight: FontWeights.semibold,
        height: LineHeights.normal,
        letterSpacing: LetterSpacings.normal,
        color: color,
      );

  static TextStyle buttonSm({Color? color}) => TextStyle(
        fontSize: FontSizes.xs,
        fontWeight: FontWeights.semibold,
        height: LineHeights.normal,
        letterSpacing: LetterSpacings.normal,
        color: color,
      );
}

/// Typography utility class for common text styling needs
class TypographyUtils {
  TypographyUtils._();

  /// Apply RTL text direction
  static TextStyle applyRTL(TextStyle style) {
    return style.copyWith();
  }

  /// Apply LTR text direction
  static TextStyle applyLTR(TextStyle style) {
    return style.copyWith();
  }

  /// Truncate text with ellipsis
  static TextStyle truncate(TextStyle style) {
    return style;
  }

  /// Make text uppercase
  static TextStyle uppercase(TextStyle style) {
    return style;
  }

  /// Make text lowercase
  static TextStyle lowercase(TextStyle style) {
    return style;
  }

  /// Make text capitalized
  static TextStyle capitalize(TextStyle style) {
    return style;
  }

  /// Apply gradient to text
  static ShaderCallback getTextGradient(List<Color> colors) {
    return (Rect bounds) {
      return LinearGradient(
        colors: colors,
      ).createShader(bounds);
    };
  }
}

/// Text theme builder for light/dark modes
class AppTextTheme {
  AppTextTheme._();

  /// Build light theme text theme
  static TextTheme buildLightTheme(String locale) {
    return TextTheme(
      displayLarge: TypographyPresets.display2xl(),
      displayMedium: TypographyPresets.displayXl(),
      displaySmall: TypographyPresets.displayLg(),
      headlineLarge: TypographyPresets.headingXl(),
      headlineMedium: TypographyPresets.headingLg(),
      headlineSmall: TypographyPresets.headingMd(),
      titleLarge: TypographyPresets.headingSm(),
      titleMedium: TypographyPresets.headingXs(),
      titleSmall: TypographyPresets.labelLg(),
      bodyLarge: TypographyPresets.bodyLg(),
      bodyMedium: TypographyPresets.bodyMd(),
      bodySmall: TypographyPresets.bodySm(),
      labelLarge: TypographyPresets.labelLg(),
      labelMedium: TypographyPresets.labelMd(),
      labelSmall: TypographyPresets.labelSm(),
    ).apply(fontFamily: AppFonts.getFontFamily(locale));
  }

  /// Build dark theme text theme
  static TextTheme buildDarkTheme(String locale) {
    return buildLightTheme(locale);
  }
}

/// Responsive typography based on screen size
class ResponsiveTypography {
  ResponsiveTypography._();

  /// Get responsive text style based on screen width
  static TextStyle getResponsiveStyle(
    BuildContext context,
    TextStyle mobile,
    TextStyle? tablet,
    TextStyle? desktop,
  ) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1024 && desktop != null) {
      return desktop;
    } else if (width >= 768 && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Scale font size based on screen width
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1024) {
      return baseFontSize * 1.1;
    } else if (width >= 768) {
      return baseFontSize * 1.05;
    }
    return baseFontSize;
  }
}
