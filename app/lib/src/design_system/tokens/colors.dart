/// Enterprise-grade color system with semantic tokens
/// Based on modern design systems (shadcn/ui, Material Design 3)
library;

import 'package:flutter/material.dart';

/// Primary brand colors
class BrandColors {
  BrandColors._();

  // Primary palette
  static const Color primary50 = Color(0xFFF0F9FF);
  static const Color primary100 = Color(0xFFE0F2FE);
  static const Color primary200 = Color(0xFFBAE6FD);
  static const Color primary300 = Color(0xFF7DD3FC);
  static const Color primary400 = Color(0xFF38BDF8);
  static const Color primary500 = Color(0xFF0EA5E9);
  static const Color primary600 = Color(0xFF0284C7);
  static const Color primary700 = Color(0xFF0369A1);
  static const Color primary800 = Color(0xFF075985);
  static const Color primary900 = Color(0xFF0C4A6E);
  static const Color primary950 = Color(0xFF082F49);

  // Secondary palette
  static const Color secondary50 = Color(0xFFF8FAFC);
  static const Color secondary100 = Color(0xFFF1F5F9);
  static const Color secondary200 = Color(0xFFE2E8F0);
  static const Color secondary300 = Color(0xFFCBD5E1);
  static const Color secondary400 = Color(0xFF94A3B8);
  static const Color secondary500 = Color(0xFF64748B);
  static const Color secondary600 = Color(0xFF475569);
  static const Color secondary700 = Color(0xFF334155);
  static const Color secondary800 = Color(0xFF1E293B);
  static const Color secondary900 = Color(0xFF0F172A);
  static const Color secondary950 = Color(0xFF020617);
}

/// Semantic color tokens for UI components
class SemanticColors {
  SemanticColors._();

  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSubtle = Color(0xFFF8FAFC);
  static const Color backgroundMuted = Color(0xFFF1F5F9);
  static const Color backgroundElevated = Color(0xFFFFFFFF);

  // Foreground colors
  static const Color foreground = Color(0xFF0F172A);
  static const Color foregroundMuted = Color(0xFF64748B);
  static const Color foregroundSubtle = Color(0xFF94A3B8);

  // Border colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderHover = Color(0xFFCBD5E1);
  static const Color borderFocus = Color(0xFF0EA5E9);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF8FAFC);
  static const Color surfaceActive = Color(0xFFF1F5F9);

  // Primary action colors
  static const Color primary = Color(0xFF0EA5E9);
  static const Color primaryHover = Color(0xFF0284C7);
  static const Color primaryActive = Color(0xFF0369A1);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // Secondary action colors
  static const Color secondary = Color(0xFFF1F5F9);
  static const Color secondaryHover = Color(0xFFE2E8F0);
  static const Color secondaryActive = Color(0xFFCBD5E1);
  static const Color secondaryForeground = Color(0xFF0F172A);

  // Destructive colors
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveHover = Color(0xFFDC2626);
  static const Color destructiveActive = Color(0xFFB91C1C);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  // Success colors
  static const Color success = Color(0xFF10B981);
  static const Color successHover = Color(0xFF059669);
  static const Color successActive = Color(0xFF047857);
  static const Color successForeground = Color(0xFFFFFFFF);
  static const Color successSubtle = Color(0xFFD1FAE5);

  // Warning colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningHover = Color(0xFFD97706);
  static const Color warningActive = Color(0xFFB45309);
  static const Color warningForeground = Color(0xFFFFFFFF);
  static const Color warningSubtle = Color(0xFFFEF3C7);

  // Info colors
  static const Color info = Color(0xFF3B82F6);
  static const Color infoHover = Color(0xFF2563EB);
  static const Color infoActive = Color(0xFF1D4ED8);
  static const Color infoForeground = Color(0xFFFFFFFF);
  static const Color infoSubtle = Color(0xFFDBEAFE);

  // Muted colors
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);

  // Accent colors
  static const Color accent = Color(0xFFF1F5F9);
  static const Color accentForeground = Color(0xFF0F172A);

  // Card colors
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF0F172A);

  // Popover colors
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF0F172A);

  // Input colors
  static const Color input = Color(0xFFE2E8F0);
  static const Color inputHover = Color(0xFFCBD5E1);
  static const Color inputFocus = Color(0xFF0EA5E9);

  // Ring color for focus states
  static const Color ring = Color(0xFF0EA5E9);
  static const double ringWidth = 2.0;
  static const double ringOffset = 2.0;
}

/// Dark theme semantic colors
class DarkSemanticColors {
  DarkSemanticColors._();

  // Background colors
  static const Color background = Color(0xFF020617);
  static const Color backgroundSubtle = Color(0xFF0F172A);
  static const Color backgroundMuted = Color(0xFF1E293B);
  static const Color backgroundElevated = Color(0xFF0F172A);

  // Foreground colors
  static const Color foreground = Color(0xFFF8FAFC);
  static const Color foregroundMuted = Color(0xFF94A3B8);
  static const Color foregroundSubtle = Color(0xFF64748B);

  // Border colors
  static const Color border = Color(0xFF1E293B);
  static const Color borderHover = Color(0xFF334155);
  static const Color borderFocus = Color(0xFF0EA5E9);

  // Surface colors
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceHover = Color(0xFF1E293B);
  static const Color surfaceActive = Color(0xFF334155);

  // Primary action colors
  static const Color primary = Color(0xFF0EA5E9);
  static const Color primaryHover = Color(0xFF38BDF8);
  static const Color primaryActive = Color(0xFF7DD3FC);
  static const Color primaryForeground = Color(0xFF020617);

  // Secondary action colors
  static const Color secondary = Color(0xFF1E293B);
  static const Color secondaryHover = Color(0xFF334155);
  static const Color secondaryActive = Color(0xFF475569);
  static const Color secondaryForeground = Color(0xFFF8FAFC);

  // Card colors
  static const Color card = Color(0xFF0F172A);
  static const Color cardForeground = Color(0xFFF8FAFC);

  // Popover colors
  static const Color popover = Color(0xFF0F172A);
  static const Color popoverForeground = Color(0xFFF8FAFC);

  // Input colors
  static const Color input = Color(0xFF1E293B);
  static const Color inputHover = Color(0xFF334155);
  static const Color inputFocus = Color(0xFF0EA5E9);

  // Ring color
  static const Color ring = Color(0xFF0EA5E9);
}

/// Status colors for various states
class StatusColors {
  StatusColors._();

  // Online/Active
  static const Color online = Color(0xFF10B981);
  static const Color onlineSubtle = Color(0xFFD1FAE5);

  // Offline/Inactive
  static const Color offline = Color(0xFF6B7280);
  static const Color offlineSubtle = Color(0xFFE5E7EB);

  // Pending
  static const Color pending = Color(0xFFF59E0B);
  static const Color pendingSubtle = Color(0xFFFEF3C7);

  // Completed
  static const Color completed = Color(0xFF10B981);
  static const Color completedSubtle = Color(0xFFD1FAE5);

  // Cancelled
  static const Color cancelled = Color(0xFFEF4444);
  static const Color cancelledSubtle = Color(0xFFFEE2E2);

  // Processing
  static const Color processing = Color(0xFF3B82F6);
  static const Color processingSubtle = Color(0xFFDBEAFE);
}

/// Chart and data visualization colors
class ChartColors {
  ChartColors._();

  static const List<Color> primary = [
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFFEF4444),
    Color(0xFF14B8A6),
  ];

  static const List<Color> pastel = [
    Color(0xFFBAE6FD),
    Color(0xFFDDD6FE),
    Color(0xFFFBCAFE),
    Color(0xFFFED7AA),
    Color(0xFFA7F3D0),
    Color(0xFFC7D2FE),
    Color(0xFFFECACA),
    Color(0xFF99F6E4),
  ];

  // Gradient pairs
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Color utilities and helpers
class ColorUtils {
  ColorUtils._();

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Mix two colors
  static Color mix(Color color1, Color color2, double amount) {
    return Color.lerp(color1, color2, amount) ?? color1;
  }

  /// Lighten color
  static Color lighten(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

  /// Darken color
  static Color darken(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }

  /// Check if color is light
  static bool isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Get contrasting text color
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLight(backgroundColor) ? Colors.black : Colors.white;
  }
}
