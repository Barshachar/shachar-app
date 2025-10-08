/// Enterprise-grade Avatar component
/// Professional user avatars with variants
library;

import 'package:flutter/material.dart';
import 'package:design_system/src/tokens/tokens.dart';

/// Avatar sizes
enum AvatarSize { xs, sm, md, lg, xl, xxl }

/// Avatar component
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final IconData? icon;
  final AvatarSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;
  final Widget? badge;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.icon,
    this.size = AvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.badge,
  });

  AppAvatar.user({
    Key? key,
    String? imageUrl,
    required String name,
    AvatarSize size = AvatarSize.md,
    VoidCallback? onTap,
  }) : this(
          key: key,
          imageUrl: imageUrl,
          initials: _getInitials(name),
          size: size,
          onTap: onTap,
        );

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = _getSize();

    Widget avatar = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: backgroundColor ?? SemanticColors.primary,
        shape: BoxShape.circle,
      ),
      child: _buildContent(),
    );

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        borderRadius: BorderRadii.full,
        child: avatar,
      );
    }

    if (badge != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: badge!,
          ),
        ],
      );
    }

    return avatar;
  }

  Widget _buildContent() {
    if (imageUrl != null) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    if (initials != null) {
      return Center(
        child: Text(
          initials!,
          style: _getTextStyle(),
        ),
      );
    }
    if (icon != null) {
      return Icon(
        icon,
        size: _getIconSize(),
        color: foregroundColor ?? SemanticColors.primaryForeground,
      );
    }
    return Icon(
      Icons.person,
      size: _getIconSize(),
      color: foregroundColor ?? SemanticColors.primaryForeground,
    );
  }

  double _getSize() {
    switch (size) {
      case AvatarSize.xs:
        return Sizes.avatarXs;
      case AvatarSize.sm:
        return Sizes.avatarSm;
      case AvatarSize.md:
        return Sizes.avatarMd;
      case AvatarSize.lg:
        return Sizes.avatarLg;
      case AvatarSize.xl:
        return Sizes.avatarXl;
      case AvatarSize.xxl:
        return Sizes.avatar2xl;
    }
  }

  double _getIconSize() {
    return _getSize() * 0.5;
  }

  TextStyle _getTextStyle() {
    final color = foregroundColor ?? SemanticColors.primaryForeground;
    switch (size) {
      case AvatarSize.xs:
        return TypographyPresets.labelSm(color: color);
      case AvatarSize.sm:
        return TypographyPresets.labelMd(color: color);
      case AvatarSize.md:
        return TypographyPresets.labelLg(color: color);
      case AvatarSize.lg:
        return TypographyPresets.headingXs(color: color);
      case AvatarSize.xl:
        return TypographyPresets.headingSm(color: color);
      case AvatarSize.xxl:
        return TypographyPresets.headingMd(color: color);
    }
  }
}

/// Avatar Group - for showing multiple avatars
class AvatarGroup extends StatelessWidget {
  final List<AppAvatar> avatars;
  final int maxVisible;
  final AvatarSize size;
  final double overlap;

  const AvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
    this.size = AvatarSize.md,
    this.overlap = 8,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAvatars = avatars.take(maxVisible).toList();
    final remainingCount = avatars.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleAvatars.asMap().entries.map((entry) {
          final index = entry.key;
          final avatar = entry.value;
          return Transform.translate(
            offset: Offset(-overlap * index, 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: SemanticColors.background,
                  width: 2,
                ),
              ),
              child: avatar,
            ),
          );
        }),
        if (remainingCount > 0)
          Transform.translate(
            offset: Offset(-overlap * maxVisible, 0),
            child: AppAvatar(
              initials: '+$remainingCount',
              size: size,
              backgroundColor: SemanticColors.muted,
              foregroundColor: SemanticColors.foreground,
            ),
          ),
      ],
    );
  }
}
