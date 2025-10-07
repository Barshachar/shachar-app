/// Enterprise-grade Loading components
/// Professional loading states with animations
library;

import 'package:flutter/material.dart';
import 'package:design_system/src/tokens/tokens.dart';

/// Loading spinner sizes
enum SpinnerSize { sm, md, lg, xl }

/// Loading Spinner
class AppSpinner extends StatelessWidget {
  final SpinnerSize size;
  final Color? color;
  final double? strokeWidth;

  const AppSpinner({
    super.key,
    this.size = SpinnerSize.md,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final dimension = _getSize();
    final stroke = strokeWidth ?? _getStrokeWidth();

    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: stroke,
        valueColor: AlwaysStoppedAnimation(
          color ?? SemanticColors.primary,
        ),
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case SpinnerSize.sm:
        return 16;
      case SpinnerSize.md:
        return 24;
      case SpinnerSize.lg:
        return 32;
      case SpinnerSize.xl:
        return 48;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case SpinnerSize.sm:
        return 2;
      case SpinnerSize.md:
        return 3;
      case SpinnerSize.lg:
        return 4;
      case SpinnerSize.xl:
        return 5;
    }
  }
}

/// Loading overlay - covers entire screen
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppSpinner(size: SpinnerSize.lg),
                  if (message != null) ...[
                    Gaps.v4,
                    Text(
                      message!,
                      style: TypographyPresets.bodyMd(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton loader - for content placeholders
class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  const Skeleton.text({
    Key? key,
    double? width,
    double height = 16,
  }) : this(
            key: key,
            width: width,
            height: height,
            borderRadius: BorderRadii.sm);

  const Skeleton.avatar({
    Key? key,
    double size = 40,
  }) : this(
          key: key,
          width: size,
          height: size,
          borderRadius: BorderRadii.full,
        );

  const Skeleton.rect({
    Key? key,
    double? width,
    double? height,
  }) : this(
            key: key,
            width: width,
            height: height,
            borderRadius: BorderRadii.md);

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LoadingAnimations.shimmerDuration,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: LoadingAnimations.shimmerCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadii.md,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                SemanticColors.muted,
                SemanticColors.muted.withValues(alpha: 0.5),
                SemanticColors.muted,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer effect - for loading content
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LoadingAnimations.shimmerDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor ?? SemanticColors.muted,
                widget.highlightColor ??
                    SemanticColors.muted.withValues(alpha: 0.5),
                widget.baseColor ?? SemanticColors.muted,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Pulse animation - for loading indicators
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration? duration;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? LoadingAnimations.pulseDuration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: LoadingAnimations.pulseCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}

/// Dots loader - animated dots
class DotsLoader extends StatefulWidget {
  final Color? color;
  final double size;
  final int dotCount;

  const DotsLoader({
    super.key,
    this.color,
    this.size = 8,
    this.dotCount = 3,
  });

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = (Curves.easeInOut.transform(value) * 0.5) + 0.5;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                margin: EdgeInsets.symmetric(horizontal: widget.size / 4),
                decoration: BoxDecoration(
                  color: widget.color ?? SemanticColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Progress bar - linear progress indicator
class AppProgressBar extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;
  final BorderRadius? borderRadius;
  final String? label;

  const AppProgressBar({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.height = 8,
    this.borderRadius,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: TypographyPresets.labelSm(),
              ),
              if (value != null)
                Text(
                  '${(value! * 100).toInt()}%',
                  style: TypographyPresets.labelSm(
                    color: SemanticColors.mutedForeground,
                  ),
                ),
            ],
          ),
          Gaps.v2,
        ],
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadii.full,
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: backgroundColor ?? SemanticColors.muted,
              valueColor: AlwaysStoppedAnimation(
                valueColor ?? SemanticColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular progress indicator with percentage
class CircularProgress extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Widget? child;

  const CircularProgress({
    super.key,
    required this.value,
    this.size = 100,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.valueColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? SemanticColors.muted,
            valueColor: AlwaysStoppedAnimation(
              valueColor ?? SemanticColors.primary,
            ),
          ),
          if (child != null)
            Center(child: child!)
          else
            Center(
              child: Text(
                '${(value * 100).toInt()}%',
                style: TypographyPresets.headingSm(),
              ),
            ),
        ],
      ),
    );
  }
}
