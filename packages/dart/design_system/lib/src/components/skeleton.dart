/// Skeleton loading components
/// Professional shimmer/skeleton loaders for better perceived performance
library;

import 'package:flutter/material.dart';
import 'package:design_system/src/tokens/tokens.dart';

/// Shimmer effect for skeleton loaders
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? Colors.grey.shade300;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton box - basic building block
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isLoading;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: isLoading,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadii.md,
        ),
      ),
    );
  }
}

/// Skeleton circle - for avatars
class SkeletonCircle extends StatelessWidget {
  final double size;
  final bool isLoading;

  const SkeletonCircle({
    super.key,
    this.size = 48,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      isLoading: isLoading,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Skeleton text line
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final bool isLoading;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 16,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(height / 2),
      isLoading: isLoading,
    );
  }
}

/// Skeleton product card
class SkeletonProductCard extends StatelessWidget {
  final bool isLoading;

  const SkeletonProductCard({
    super.key,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: Insets.all4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              height: 150,
              isLoading: isLoading,
            ),
            Gaps.v3,
            SkeletonLine(
              width: double.infinity,
              height: 20,
              isLoading: isLoading,
            ),
            Gaps.v2,
            SkeletonLine(
              width: 150,
              height: 16,
              isLoading: isLoading,
            ),
            Gaps.v2,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(
                  width: 80,
                  height: 24,
                  isLoading: isLoading,
                ),
                SkeletonBox(
                  width: 100,
                  height: 36,
                  isLoading: isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list tile
class SkeletonListTile extends StatelessWidget {
  final bool isLoading;
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListTile({
    super.key,
    this.isLoading = true,
    this.hasLeading = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Insets.all4,
      child: Row(
        children: [
          if (hasLeading) ...[
            SkeletonCircle(size: 48, isLoading: isLoading),
            Gaps.h3,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(
                  width: double.infinity,
                  height: 18,
                  isLoading: isLoading,
                ),
                Gaps.v2,
                SkeletonLine(
                  width: 200,
                  height: 14,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            Gaps.h3,
            SkeletonBox(
              width: 60,
              height: 32,
              isLoading: isLoading,
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton order card
class SkeletonOrderCard extends StatelessWidget {
  final bool isLoading;

  const SkeletonOrderCard({
    super.key,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: Insets.all4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(
                  width: 120,
                  height: 20,
                  isLoading: isLoading,
                ),
                SkeletonBox(
                  width: 80,
                  height: 24,
                  isLoading: isLoading,
                ),
              ],
            ),
            Gaps.v3,
            SkeletonLine(
              width: 200,
              height: 16,
              isLoading: isLoading,
            ),
            Gaps.v2,
            SkeletonLine(
              width: 150,
              height: 16,
              isLoading: isLoading,
            ),
            Gaps.v3,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(
                  width: 100,
                  height: 24,
                  isLoading: isLoading,
                ),
                SkeletonBox(
                  width: 100,
                  height: 36,
                  isLoading: isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton grid - for product grids
class SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final bool isLoading;

  const SkeletonGrid({
    super.key,
    this.itemCount = 6,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.isLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: Spacing.s4,
          mainAxisSpacing: Spacing.s4,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: Spacing.s4,
        mainAxisSpacing: Spacing.s4,
      ),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const SkeletonProductCard(),
    );
  }
}

/// Skeleton list - for lists
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;
  final bool isLoading;
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonList({
    super.key,
    this.itemCount = 10,
    this.itemBuilder,
    this.isLoading = true,
    this.hasLeading = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && itemBuilder != null) {
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder!,
      );
    }

    return ListView.separated(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => SkeletonListTile(
        hasLeading: hasLeading,
        hasTrailing: hasTrailing,
      ),
    );
  }
}

/// Loading overlay with spinner (skeleton themed)
class SkeletonLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const SkeletonLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black38,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: Insets.all6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        if (message != null) ...[
                          Gaps.v4,
                          Text(
                            message!,
                            style: TypographyPresets.bodyMd(),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
