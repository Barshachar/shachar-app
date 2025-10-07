/// Enterprise-grade shadow system
/// Elevation and depth tokens for UI components
library;

import 'package:flutter/material.dart';
import 'package:ashachar_marketplace/src/design_system/tokens/colors.dart';

/// Shadow elevation levels
class Shadows {
  Shadows._();

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Extra small shadow - for subtle depth
  static final List<BoxShadow> xs = [
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  /// Small shadow - for cards and small elevated elements
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.1),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.06),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  /// Medium shadow - for buttons and interactive elements
  static final List<BoxShadow> md = [
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.1),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.06),
      blurRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];

  /// Large shadow - for modals and popovers
  static final List<BoxShadow> lg = [
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.1),
      blurRadius: 15,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.05),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  /// Extra large shadow - for dialogs and important overlays
  static final List<BoxShadow> xl = [
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.1),
      blurRadius: 25,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 8),
    ),
  ];

  /// 2XL shadow - for maximum elevation
  static final List<BoxShadow> xl2 = [
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.25),
      blurRadius: 50,
      offset: const Offset(0, 25),
    ),
  ];

  /// Inner shadow effect
  static final List<BoxShadow> inner = [
    BoxShadow(
      color: SemanticColors.foreground.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 2),
      spreadRadius: -1,
    ),
  ];
}

/// Dark mode shadows
class DarkShadows {
  DarkShadows._();

  static const List<BoxShadow> none = [];

  static final List<BoxShadow> xs = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 6,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 25,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 10,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> xl2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 50,
      offset: const Offset(0, 25),
    ),
  ];

  static final List<BoxShadow> inner = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 2,
      offset: const Offset(0, 2),
      spreadRadius: -1,
    ),
  ];
}

/// Colored shadows for emphasis
class ColoredShadows {
  ColoredShadows._();

  /// Primary colored shadow
  static final List<BoxShadow> primary = [
    BoxShadow(
      color: SemanticColors.primary.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Success colored shadow
  static final List<BoxShadow> success = [
    BoxShadow(
      color: SemanticColors.success.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Warning colored shadow
  static final List<BoxShadow> warning = [
    BoxShadow(
      color: SemanticColors.warning.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Danger colored shadow
  static final List<BoxShadow> danger = [
    BoxShadow(
      color: SemanticColors.destructive.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Info colored shadow
  static final List<BoxShadow> info = [
    BoxShadow(
      color: SemanticColors.info.withValues(alpha: 0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Shadow utilities
class ShadowUtils {
  ShadowUtils._();

  /// Get shadow based on elevation level (Material Design style)
  static List<BoxShadow> getElevation(int level, {bool isDark = false}) {
    if (isDark) {
      switch (level) {
        case 0:
          return DarkShadows.none;
        case 1:
          return DarkShadows.xs;
        case 2:
          return DarkShadows.sm;
        case 3:
        case 4:
          return DarkShadows.md;
        case 5:
        case 6:
          return DarkShadows.lg;
        case 7:
        case 8:
          return DarkShadows.xl;
        default:
          return DarkShadows.xl2;
      }
    } else {
      switch (level) {
        case 0:
          return Shadows.none;
        case 1:
          return Shadows.xs;
        case 2:
          return Shadows.sm;
        case 3:
        case 4:
          return Shadows.md;
        case 5:
        case 6:
          return Shadows.lg;
        case 7:
        case 8:
          return Shadows.xl;
        default:
          return Shadows.xl2;
      }
    }
  }

  /// Create custom shadow
  static BoxShadow custom({
    required Color color,
    required double blur,
    required Offset offset,
    double spread = 0,
  }) {
    return BoxShadow(
      color: color,
      blurRadius: blur,
      offset: offset,
      spreadRadius: spread,
    );
  }

  /// Create glow effect
  static List<BoxShadow> glow({
    required Color color,
    double intensity = 0.5,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 20,
        spreadRadius: 5,
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.5),
        blurRadius: 40,
        spreadRadius: 10,
      ),
    ];
  }
}

/// Neumorphic shadow styles
class NeumorphicShadows {
  NeumorphicShadows._();

  /// Light neumorphic shadow (raised)
  static final List<BoxShadow> raised = [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.7),
      blurRadius: 10,
      offset: const Offset(-5, -5),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 10,
      offset: const Offset(5, 5),
    ),
  ];

  /// Dark neumorphic shadow (pressed)
  static final List<BoxShadow> pressed = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(4, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.7),
      blurRadius: 8,
      offset: const Offset(-4, -4),
      spreadRadius: -2,
    ),
  ];

  /// Flat neumorphic (no shadow)
  static const List<BoxShadow> flat = [];
}

/// Text shadow presets
class TextShadows {
  TextShadows._();

  /// Subtle text shadow
  static final Shadow subtle = Shadow(
    color: Colors.black.withValues(alpha: 0.25),
    blurRadius: 2,
    offset: const Offset(0, 1),
  );

  /// Standard text shadow
  static final Shadow standard = Shadow(
    color: Colors.black.withValues(alpha: 0.3),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  /// Strong text shadow
  static final Shadow strong = Shadow(
    color: Colors.black.withValues(alpha: 0.5),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  /// Glow effect for text
  static final List<Shadow> glow = [
    Shadow(
      color: SemanticColors.primary.withValues(alpha: 0.5),
      blurRadius: 10,
    ),
    Shadow(
      color: SemanticColors.primary.withValues(alpha: 0.3),
      blurRadius: 20,
    ),
  ];
}
