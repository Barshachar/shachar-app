/// Enterprise-grade animation system
/// Consistent timing, easing, and animation presets
library;

import 'package:flutter/material.dart';

/// Animation duration constants
class AnimationDurations {
  AnimationDurations._();

  // Standard durations (in milliseconds)
  static const instant = Duration(milliseconds: 0);
  static const fastest = Duration(milliseconds: 50);
  static const faster = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 300);
  static const slower = Duration(milliseconds: 400);
  static const slowest = Duration(milliseconds: 500);
  static const verySlow = Duration(milliseconds: 700);
  static const extremelySlow = Duration(milliseconds: 1000);

  // Semantic durations for specific interactions
  static const hover = fast;
  static const focus = faster;
  static const press = fastest;
  static const tooltip = faster;
  static const toast = normal;
  static const dialog = slow;
  static const drawer = normal;
  static const modal = slow;
  static const pageTransition = normal;
  static const collapse = normal;
  static const expand = normal;
  static const fadeIn = fast;
  static const fadeOut = fast;
  static const slideIn = normal;
  static const slideOut = normal;
  static const scaleIn = faster;
  static const scaleOut = faster;
}

/// Easing curves for animations
class Easings {
  Easings._();

  // Standard Material curves
  static const linear = Curves.linear;
  static const ease = Curves.ease;
  static const easeIn = Curves.easeIn;
  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;

  // Cubic curves
  static const easeInCubic = Curves.easeInCubic;
  static const easeOutCubic = Curves.easeOutCubic;
  static const easeInOutCubic = Curves.easeInOutCubic;

  // Sine curves
  static const easeInSine = Curves.easeInSine;
  static const easeOutSine = Curves.easeOutSine;
  static const easeInOutSine = Curves.easeInOutSine;

  // Quad curves
  static const easeInQuad = Curves.easeInQuad;
  static const easeOutQuad = Curves.easeOutQuad;
  static const easeInOutQuad = Curves.easeInOutQuad;

  // Expo curves
  static const easeInExpo = Curves.easeInExpo;
  static const easeOutExpo = Curves.easeOutExpo;
  static const easeInOutExpo = Curves.easeInOutExpo;

  // Circ curves
  static const easeInCirc = Curves.easeInCirc;
  static const easeOutCirc = Curves.easeOutCirc;
  static const easeInOutCirc = Curves.easeInOutCirc;

  // Back curves
  static const easeInBack = Curves.easeInBack;
  static const easeOutBack = Curves.easeOutBack;
  static const easeInOutBack = Curves.easeInOutBack;

  // Elastic curves
  static const elasticIn = Curves.elasticIn;
  static const elasticOut = Curves.elasticOut;
  static const elasticInOut = Curves.elasticInOut;

  // Bounce curves
  static const bounceIn = Curves.bounceIn;
  static const bounceOut = Curves.bounceOut;
  static const bounceInOut = Curves.bounceInOut;

  // Fast out slow in (Material Design recommended)
  static const fastOutSlowIn = Curves.fastOutSlowIn;
  static const slowMiddle = Curves.slowMiddle;

  // Custom curves for specific use cases
  static const smooth = Cubic(0.4, 0.0, 0.2, 1.0);
  static const snappy = Cubic(0.4, 0.0, 0.6, 1.0);
  static const emphasized = Cubic(0.2, 0.0, 0, 1.0);
  static const decelerated = Cubic(0.0, 0.0, 0.2, 1.0);
  static const accelerated = Cubic(0.4, 0.0, 1.0, 1.0);
}

/// Animation configuration presets
class AnimationConfig {
  final Duration duration;
  final Curve curve;

  const AnimationConfig({
    required this.duration,
    required this.curve,
  });

  // Fade animations
  static const fadeIn = AnimationConfig(
    duration: AnimationDurations.fadeIn,
    curve: Easings.easeOut,
  );

  static const fadeOut = AnimationConfig(
    duration: AnimationDurations.fadeOut,
    curve: Easings.easeIn,
  );

  // Scale animations
  static const scaleIn = AnimationConfig(
    duration: AnimationDurations.scaleIn,
    curve: Easings.easeOutBack,
  );

  static const scaleOut = AnimationConfig(
    duration: AnimationDurations.scaleOut,
    curve: Easings.easeInBack,
  );

  // Slide animations
  static const slideIn = AnimationConfig(
    duration: AnimationDurations.slideIn,
    curve: Easings.fastOutSlowIn,
  );

  static const slideOut = AnimationConfig(
    duration: AnimationDurations.slideOut,
    curve: Easings.fastOutSlowIn,
  );

  // Interactive animations
  static const hover = AnimationConfig(
    duration: AnimationDurations.hover,
    curve: Easings.easeOut,
  );

  static const press = AnimationConfig(
    duration: AnimationDurations.press,
    curve: Easings.easeOut,
  );

  // UI element animations
  static const dialog = AnimationConfig(
    duration: AnimationDurations.dialog,
    curve: Easings.emphasized,
  );

  static const drawer = AnimationConfig(
    duration: AnimationDurations.drawer,
    curve: Easings.emphasized,
  );

  static const collapse = AnimationConfig(
    duration: AnimationDurations.collapse,
    curve: Easings.fastOutSlowIn,
  );

  static const expand = AnimationConfig(
    duration: AnimationDurations.expand,
    curve: Easings.fastOutSlowIn,
  );
}

/// Page transition builders
class PageTransitions {
  PageTransitions._();

  /// Fade transition
  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Slide from right transition
  static Widget slideFromRight({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Easings.fastOutSlowIn,
      )),
      child: child,
    );
  }

  /// Slide from left transition
  static Widget slideFromLeft({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Easings.fastOutSlowIn,
      )),
      child: child,
    );
  }

  /// Slide from bottom transition
  static Widget slideFromBottom({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Easings.fastOutSlowIn,
      )),
      child: child,
    );
  }

  /// Scale transition
  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Easings.easeOutBack,
      ),
      child: child,
    );
  }

  /// Fade + Scale transition
  static Widget fadeScaleTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Easings.easeOutBack,
          ),
        ),
        child: child,
      ),
    );
  }

  /// Fade + Slide transition
  static Widget fadeSlideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(0.0, 0.3),
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Easings.fastOutSlowIn,
        )),
        child: child,
      ),
    );
  }
}

/// Loading animation types
class LoadingAnimations {
  LoadingAnimations._();

  // Shimmer effect durations
  static const shimmerDuration = Duration(milliseconds: 1500);
  static const shimmerCurve = Easings.linear;

  // Pulse effect
  static const pulseDuration = Duration(milliseconds: 1000);
  static const pulseCurve = Easings.easeInOut;

  // Spin effect
  static const spinDuration = Duration(milliseconds: 1000);
  static const spinCurve = Easings.linear;

  // Bounce effect
  static const bounceDuration = Duration(milliseconds: 600);
  static const bounceCurve = Easings.bounceOut;

  // Wave effect
  static const waveDuration = Duration(milliseconds: 1200);
  static const waveCurve = Easings.easeInOut;
}

/// Micro-interaction animations
class MicroInteractions {
  MicroInteractions._();

  // Button press animation
  static const buttonPress = AnimationConfig(
    duration: Duration(milliseconds: 100),
    curve: Easings.easeOut,
  );

  // Button release animation
  static const buttonRelease = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Easings.easeOut,
  );

  // Checkbox check animation
  static const checkboxCheck = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Easings.easeOutBack,
  );

  // Switch toggle animation
  static const switchToggle = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Easings.fastOutSlowIn,
  );

  // Ripple effect
  static const ripple = AnimationConfig(
    duration: Duration(milliseconds: 300),
    curve: Easings.easeOut,
  );

  // Icon rotation
  static const iconRotation = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Easings.easeInOut,
  );

  // Badge pulse
  static const badgePulse = AnimationConfig(
    duration: Duration(milliseconds: 1000),
    curve: Easings.easeInOut,
  );
}

/// Stagger animation utilities
class StaggerAnimations {
  StaggerAnimations._();

  /// Create staggered delay for list items
  static Duration getStaggerDelay(
    int index, {
    Duration baseDelay = const Duration(milliseconds: 50),
    int maxItems = 10,
  }) {
    final clampedIndex = index.clamp(0, maxItems - 1);
    return baseDelay * clampedIndex;
  }

  /// Create interval for staggered animations
  static Interval getStaggerInterval(
    int index,
    int total, {
    double overlap = 0.0,
  }) {
    if (total == 0) return const Interval(0.0, 1.0);

    final itemDuration = 1.0 / total;
    final begin = (itemDuration * index).clamp(0.0, 1.0);
    final end = (begin + itemDuration + overlap).clamp(0.0, 1.0);

    return Interval(begin, end, curve: Easings.fastOutSlowIn);
  }
}

/// Animation controller helpers
class AnimationHelpers {
  AnimationHelpers._();

  /// Create a standard animation controller
  static AnimationController createController({
    required TickerProvider vsync,
    Duration duration = AnimationDurations.normal,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
    );
  }

  /// Create a repeating animation controller
  static AnimationController createRepeatingController({
    required TickerProvider vsync,
    Duration duration = AnimationDurations.normal,
    bool reverse = true,
  }) {
    final controller = AnimationController(
      vsync: vsync,
      duration: duration,
    );

    if (reverse) {
      controller.repeat(reverse: true);
    } else {
      controller.repeat();
    }

    return controller;
  }

  /// Create a curved animation
  static Animation<double> createCurvedAnimation({
    required AnimationController controller,
    Curve curve = Easings.easeInOut,
  }) {
    return CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  /// Create a tween animation
  static Animation<T> createTween<T>({
    required AnimationController controller,
    required T begin,
    required T end,
    Curve curve = Easings.easeInOut,
  }) {
    return Tween<T>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }
}
