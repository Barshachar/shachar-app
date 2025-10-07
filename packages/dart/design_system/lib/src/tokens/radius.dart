/// Enterprise-grade border radius system
/// Consistent corner rounding for UI components
library;

import 'package:flutter/material.dart';

/// Border radius values
class RadiusValues {
  RadiusValues._();

  // Base radius values
  static const double none = 0.0;
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xl2 = 16.0;
  static const double xl3 = 24.0;
  static const double full = 9999.0; // Pill shape

  // Semantic radius for components
  static const double button = md;
  static const double input = md;
  static const double card = lg;
  static const double dialog = xl;
  static const double popover = lg;
  static const double tooltip = sm;
  static const double badge = full;
  static const double avatar = full;
  static const double chip = full;
  static const double tag = sm;
  static const double image = md;
}

/// BorderRadius presets
class BorderRadii {
  BorderRadii._();

  // All corners
  static const none = BorderRadius.zero;
  static const xs = BorderRadius.all(Radius.circular(RadiusValues.xs));
  static const sm = BorderRadius.all(Radius.circular(RadiusValues.sm));
  static const md = BorderRadius.all(Radius.circular(RadiusValues.md));
  static const lg = BorderRadius.all(Radius.circular(RadiusValues.lg));
  static const xl = BorderRadius.all(Radius.circular(RadiusValues.xl));
  static const xl2 = BorderRadius.all(Radius.circular(RadiusValues.xl2));
  static const xl3 = BorderRadius.all(Radius.circular(RadiusValues.xl3));
  static const full = BorderRadius.all(Radius.circular(RadiusValues.full));

  // Top corners only
  static const topSm = BorderRadius.only(
    topLeft: Radius.circular(RadiusValues.sm),
    topRight: Radius.circular(RadiusValues.sm),
  );
  static const topMd = BorderRadius.only(
    topLeft: Radius.circular(RadiusValues.md),
    topRight: Radius.circular(RadiusValues.md),
  );
  static const topLg = BorderRadius.only(
    topLeft: Radius.circular(RadiusValues.lg),
    topRight: Radius.circular(RadiusValues.lg),
  );
  static const topXl = BorderRadius.only(
    topLeft: Radius.circular(RadiusValues.xl),
    topRight: Radius.circular(RadiusValues.xl),
  );

  // Bottom corners only
  static const bottomSm = BorderRadius.only(
    bottomLeft: Radius.circular(RadiusValues.sm),
    bottomRight: Radius.circular(RadiusValues.sm),
  );
  static const bottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(RadiusValues.md),
    bottomRight: Radius.circular(RadiusValues.md),
  );
  static const bottomLg = BorderRadius.only(
    bottomLeft: Radius.circular(RadiusValues.lg),
    bottomRight: Radius.circular(RadiusValues.lg),
  );
  static const bottomXl = BorderRadius.only(
    bottomLeft: Radius.circular(RadiusValues.xl),
    bottomRight: Radius.circular(RadiusValues.xl),
  );

  // Left corners only (for RTL support)
  static const leftSm = BorderRadius.only(
    topLeft: Radius.circular(RadiusValues.sm),
    bottomLeft: Radius.circular(RadiusValues.sm),
  );
  static const leftMd = BorderRadius.only(
    topLeft: Radius.circular(RadiusValues.md),
    bottomLeft: Radius.circular(RadiusValues.md),
  );
  static const leftLg = BorderRadius.only(
    topLeft: Radius.circular(RadiusValues.lg),
    bottomLeft: Radius.circular(RadiusValues.lg),
  );

  // Right corners only (for RTL support)
  static const rightSm = BorderRadius.only(
    topRight: Radius.circular(RadiusValues.sm),
    bottomRight: Radius.circular(RadiusValues.sm),
  );
  static const rightMd = BorderRadius.only(
    topRight: Radius.circular(RadiusValues.md),
    bottomRight: Radius.circular(RadiusValues.md),
  );
  static const rightLg = BorderRadius.only(
    topRight: Radius.circular(RadiusValues.lg),
    bottomRight: Radius.circular(RadiusValues.lg),
  );

  // Component-specific
  static const button = BorderRadius.all(Radius.circular(RadiusValues.button));
  static const input = BorderRadius.all(Radius.circular(RadiusValues.input));
  static const card = BorderRadius.all(Radius.circular(RadiusValues.card));
  static const dialog = BorderRadius.all(Radius.circular(RadiusValues.dialog));
  static const popover =
      BorderRadius.all(Radius.circular(RadiusValues.popover));
  static const tooltip =
      BorderRadius.all(Radius.circular(RadiusValues.tooltip));
  static const badge = BorderRadius.all(Radius.circular(RadiusValues.badge));
  static const avatar = BorderRadius.all(Radius.circular(RadiusValues.avatar));
  static const chip = BorderRadius.all(Radius.circular(RadiusValues.chip));
  static const tag = BorderRadius.all(Radius.circular(RadiusValues.tag));
  static const image = BorderRadius.all(Radius.circular(RadiusValues.image));
}

/// Circular radius (50% on all sides) - for perfect circles
class CircularRadius {
  CircularRadius._();

  static BorderRadius circular(double size) {
    return BorderRadius.circular(size / 2);
  }
}

/// Radius utilities
class RadiusUtils {
  RadiusUtils._();

  /// Create custom border radius
  static BorderRadius custom({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  /// Create asymmetric radius for interesting designs
  static BorderRadius asymmetric({
    required double horizontal,
    required double vertical,
  }) {
    return BorderRadius.only(
      topLeft: Radius.elliptical(horizontal, vertical),
      topRight: Radius.elliptical(horizontal, vertical),
      bottomLeft: Radius.elliptical(horizontal, vertical),
      bottomRight: Radius.elliptical(horizontal, vertical),
    );
  }

  /// Get radius for RTL layouts
  static BorderRadius getRTLRadius(BorderRadius radius, bool isRTL) {
    if (!isRTL) return radius;

    // Flip horizontal corners for RTL
    return BorderRadius.only(
      topLeft: radius.topRight,
      topRight: radius.topLeft,
      bottomLeft: radius.bottomRight,
      bottomRight: radius.bottomLeft,
    );
  }
}

/// Clip behavior for widgets
class ClipBehaviors {
  ClipBehaviors._();

  static const none = Clip.none;
  static const hardEdge = Clip.hardEdge;
  static const antiAlias = Clip.antiAlias;
  static const antiAliasWithSaveLayer = Clip.antiAliasWithSaveLayer;
}
