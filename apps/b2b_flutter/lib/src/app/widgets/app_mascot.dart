import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';

/// The brand mascot ("ברזי") — a friendly chrome faucet character used to add
/// personality to marketing surfaces, empty states and celebratory moments.
///
/// Variants are backed by transparent PNG assets under `assets/mascot/`. The
/// widget degrades gracefully to a themed icon if an asset cannot be loaded
/// (e.g. in a minimal test environment), so it is always safe to render.
enum AppMascotVariant {
  /// Confident "cool" Barzi with sunglasses — used on the promotions banner.
  cool,
}

class AppMascot extends StatelessWidget {
  const AppMascot({
    super.key,
    this.variant = AppMascotVariant.cool,
    this.size = 96,
    this.semanticLabel = 'ברזי',
  });

  /// Which mascot pose/costume to show.
  final AppMascotVariant variant;

  /// Target height in logical pixels. Width follows the asset's aspect ratio.
  final double size;

  final String semanticLabel;

  String get _assetPath {
    switch (variant) {
      case AppMascotVariant.cool:
        return 'assets/mascot/barzi_cool.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _MascotFallback(size: size),
    );
  }
}

/// Lightweight stand-in shown when the mascot asset is unavailable.
class _MascotFallback extends StatelessWidget {
  const _MascotFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double diameter = size * 0.62;
    return SizedBox(
      height: size,
      width: size,
      child: Center(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.white.withValues(alpha: 0.28),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: AColors.premiumGoldLight.withValues(alpha: 0.7),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.local_offer_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
