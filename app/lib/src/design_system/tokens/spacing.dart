/// Enterprise-grade spacing system
/// Consistent spacing scale for layouts and components
library;

import 'package:flutter/widgets.dart';

/// Spacing scale based on 4px base unit
class Spacing {
  Spacing._();

  // Base unit
  static const double unit = 4.0;

  // Spacing scale (4px increments)
  static const double px = 1.0;
  static const double s0 = 0.0;
  static const double s0_5 = 2.0; // 0.5 * 4
  static const double s1 = 4.0; // 1 * 4
  static const double s1_5 = 6.0; // 1.5 * 4
  static const double s2 = 8.0; // 2 * 4
  static const double s2_5 = 10.0; // 2.5 * 4
  static const double s3 = 12.0; // 3 * 4
  static const double s3_5 = 14.0; // 3.5 * 4
  static const double s4 = 16.0; // 4 * 4
  static const double s5 = 20.0; // 5 * 4
  static const double s6 = 24.0; // 6 * 4
  static const double s7 = 28.0; // 7 * 4
  static const double s8 = 32.0; // 8 * 4
  static const double s9 = 36.0; // 9 * 4
  static const double s10 = 40.0; // 10 * 4
  static const double s11 = 44.0; // 11 * 4
  static const double s12 = 48.0; // 12 * 4
  static const double s14 = 56.0; // 14 * 4
  static const double s16 = 64.0; // 16 * 4
  static const double s20 = 80.0; // 20 * 4
  static const double s24 = 96.0; // 24 * 4
  static const double s28 = 112.0; // 28 * 4
  static const double s32 = 128.0; // 32 * 4
  static const double s36 = 144.0; // 36 * 4
  static const double s40 = 160.0; // 40 * 4
  static const double s44 = 176.0; // 44 * 4
  static const double s48 = 192.0; // 48 * 4
  static const double s52 = 208.0; // 52 * 4
  static const double s56 = 224.0; // 56 * 4
  static const double s60 = 240.0; // 60 * 4
  static const double s64 = 256.0; // 64 * 4
  static const double s72 = 288.0; // 72 * 4
  static const double s80 = 320.0; // 80 * 4
  static const double s96 = 384.0; // 96 * 4

  // Semantic spacing - component-specific
  static const double iconXs = s3; // 12px
  static const double iconSm = s4; // 16px
  static const double iconMd = s5; // 20px
  static const double iconLg = s6; // 24px
  static const double iconXl = s8; // 32px
  static const double icon2xl = s12; // 48px

  // Button padding
  static const double buttonPaddingXs = s2; // 8px
  static const double buttonPaddingSm = s3; // 12px
  static const double buttonPaddingMd = s4; // 16px
  static const double buttonPaddingLg = s5; // 20px
  static const double buttonPaddingXl = s6; // 24px

  // Input padding
  static const double inputPaddingXs = s2; // 8px
  static const double inputPaddingSm = s3; // 12px
  static const double inputPaddingMd = s4; // 16px
  static const double inputPaddingLg = s5; // 20px

  // Card padding
  static const double cardPaddingXs = s3; // 12px
  static const double cardPaddingSm = s4; // 16px
  static const double cardPaddingMd = s6; // 24px
  static const double cardPaddingLg = s8; // 32px
  static const double cardPaddingXl = s10; // 40px

  // Container padding
  static const double containerPaddingXs = s4; // 16px
  static const double containerPaddingSm = s6; // 24px
  static const double containerPaddingMd = s8; // 32px
  static const double containerPaddingLg = s12; // 48px
  static const double containerPaddingXl = s16; // 64px

  // Section spacing
  static const double sectionSpacingXs = s8; // 32px
  static const double sectionSpacingSm = s12; // 48px
  static const double sectionSpacingMd = s16; // 64px
  static const double sectionSpacingLg = s24; // 96px
  static const double sectionSpacingXl = s32; // 128px

  // Gap between elements
  static const double gapXs = s1; // 4px
  static const double gapSm = s2; // 8px
  static const double gapMd = s4; // 16px
  static const double gapLg = s6; // 24px
  static const double gapXl = s8; // 32px

  // Stack/list item spacing
  static const double listItemSpacingSm = s2; // 8px
  static const double listItemSpacingMd = s3; // 12px
  static const double listItemSpacingLg = s4; // 16px

  // Divider spacing
  static const double dividerSpacingSm = s2; // 8px
  static const double dividerSpacingMd = s4; // 16px
  static const double dividerSpacingLg = s6; // 24px
}

/// Inset spacing (padding) presets
class Insets {
  Insets._();

  // All sides equal
  static const all0 = EdgeInsets.zero;
  static const all1 = EdgeInsets.all(Spacing.s1);
  static const all2 = EdgeInsets.all(Spacing.s2);
  static const all3 = EdgeInsets.all(Spacing.s3);
  static const all4 = EdgeInsets.all(Spacing.s4);
  static const all5 = EdgeInsets.all(Spacing.s5);
  static const all6 = EdgeInsets.all(Spacing.s6);
  static const all8 = EdgeInsets.all(Spacing.s8);
  static const all10 = EdgeInsets.all(Spacing.s10);
  static const all12 = EdgeInsets.all(Spacing.s12);
  static const all16 = EdgeInsets.all(Spacing.s16);
  static const all20 = EdgeInsets.all(Spacing.s20);
  static const all24 = EdgeInsets.all(Spacing.s24);

  // Horizontal only
  static const horizontalXs = EdgeInsets.symmetric(horizontal: Spacing.s2);
  static const horizontalSm = EdgeInsets.symmetric(horizontal: Spacing.s3);
  static const horizontalMd = EdgeInsets.symmetric(horizontal: Spacing.s4);
  static const horizontalLg = EdgeInsets.symmetric(horizontal: Spacing.s6);
  static const horizontalXl = EdgeInsets.symmetric(horizontal: Spacing.s8);

  // Vertical only
  static const verticalXs = EdgeInsets.symmetric(vertical: Spacing.s2);
  static const verticalSm = EdgeInsets.symmetric(vertical: Spacing.s3);
  static const verticalMd = EdgeInsets.symmetric(vertical: Spacing.s4);
  static const verticalLg = EdgeInsets.symmetric(vertical: Spacing.s6);
  static const verticalXl = EdgeInsets.symmetric(vertical: Spacing.s8);

  // Specific sides
  static const topXs = EdgeInsets.only(top: Spacing.s2);
  static const topSm = EdgeInsets.only(top: Spacing.s3);
  static const topMd = EdgeInsets.only(top: Spacing.s4);
  static const topLg = EdgeInsets.only(top: Spacing.s6);
  static const topXl = EdgeInsets.only(top: Spacing.s8);

  static const bottomXs = EdgeInsets.only(bottom: Spacing.s2);
  static const bottomSm = EdgeInsets.only(bottom: Spacing.s3);
  static const bottomMd = EdgeInsets.only(bottom: Spacing.s4);
  static const bottomLg = EdgeInsets.only(bottom: Spacing.s6);
  static const bottomXl = EdgeInsets.only(bottom: Spacing.s8);

  static const leftXs = EdgeInsets.only(left: Spacing.s2);
  static const leftSm = EdgeInsets.only(left: Spacing.s3);
  static const leftMd = EdgeInsets.only(left: Spacing.s4);
  static const leftLg = EdgeInsets.only(left: Spacing.s6);
  static const leftXl = EdgeInsets.only(left: Spacing.s8);

  static const rightXs = EdgeInsets.only(right: Spacing.s2);
  static const rightSm = EdgeInsets.only(right: Spacing.s3);
  static const rightMd = EdgeInsets.only(right: Spacing.s4);
  static const rightLg = EdgeInsets.only(right: Spacing.s6);
  static const rightXl = EdgeInsets.only(right: Spacing.s8);

  // Page/screen padding
  static const pageSm = EdgeInsets.all(Spacing.s4);
  static const pageMd = EdgeInsets.all(Spacing.s6);
  static const pageLg = EdgeInsets.all(Spacing.s8);

  // Card padding
  static const cardSm = EdgeInsets.all(Spacing.cardPaddingSm);
  static const cardMd = EdgeInsets.all(Spacing.cardPaddingMd);
  static const cardLg = EdgeInsets.all(Spacing.cardPaddingLg);

  // Button padding
  static const buttonSm = EdgeInsets.symmetric(
    horizontal: Spacing.s3,
    vertical: Spacing.s2,
  );
  static const buttonMd = EdgeInsets.symmetric(
    horizontal: Spacing.s4,
    vertical: Spacing.s2_5,
  );
  static const buttonLg = EdgeInsets.symmetric(
    horizontal: Spacing.s6,
    vertical: Spacing.s3,
  );

  // Input padding
  static const inputSm = EdgeInsets.symmetric(
    horizontal: Spacing.s3,
    vertical: Spacing.s2,
  );
  static const inputMd = EdgeInsets.symmetric(
    horizontal: Spacing.s4,
    vertical: Spacing.s2_5,
  );
  static const inputLg = EdgeInsets.symmetric(
    horizontal: Spacing.s4,
    vertical: Spacing.s3,
  );

  // Dialog/Modal padding
  static const dialogSm = EdgeInsets.all(Spacing.s6);
  static const dialogMd = EdgeInsets.all(Spacing.s8);
  static const dialogLg = EdgeInsets.all(Spacing.s10);

  // List item padding
  static const listItemSm = EdgeInsets.symmetric(
    horizontal: Spacing.s4,
    vertical: Spacing.s2,
  );
  static const listItemMd = EdgeInsets.symmetric(
    horizontal: Spacing.s4,
    vertical: Spacing.s3,
  );
  static const listItemLg = EdgeInsets.symmetric(
    horizontal: Spacing.s6,
    vertical: Spacing.s4,
  );
}

/// Gap spacing for Flex widgets (Row, Column, Wrap)
class Gaps {
  Gaps._();

  // Vertical gaps (for Column)
  static const v0 = SizedBox(height: Spacing.s0);
  static const v1 = SizedBox(height: Spacing.s1);
  static const v2 = SizedBox(height: Spacing.s2);
  static const v3 = SizedBox(height: Spacing.s3);
  static const v4 = SizedBox(height: Spacing.s4);
  static const v5 = SizedBox(height: Spacing.s5);
  static const v6 = SizedBox(height: Spacing.s6);
  static const v8 = SizedBox(height: Spacing.s8);
  static const v10 = SizedBox(height: Spacing.s10);
  static const v12 = SizedBox(height: Spacing.s12);
  static const v16 = SizedBox(height: Spacing.s16);
  static const v20 = SizedBox(height: Spacing.s20);
  static const v24 = SizedBox(height: Spacing.s24);
  static const v32 = SizedBox(height: Spacing.s32);

  // Horizontal gaps (for Row)
  static const h0 = SizedBox(width: Spacing.s0);
  static const h1 = SizedBox(width: Spacing.s1);
  static const h2 = SizedBox(width: Spacing.s2);
  static const h3 = SizedBox(width: Spacing.s3);
  static const h4 = SizedBox(width: Spacing.s4);
  static const h5 = SizedBox(width: Spacing.s5);
  static const h6 = SizedBox(width: Spacing.s6);
  static const h8 = SizedBox(width: Spacing.s8);
  static const h10 = SizedBox(width: Spacing.s10);
  static const h12 = SizedBox(width: Spacing.s12);
  static const h16 = SizedBox(width: Spacing.s16);
  static const h20 = SizedBox(width: Spacing.s20);
  static const h24 = SizedBox(width: Spacing.s24);
  static const h32 = SizedBox(width: Spacing.s32);
}

/// Container constraints
class Constraints {
  Constraints._();

  // Max widths for content containers
  static const double maxWidthXs = 320.0;
  static const double maxWidthSm = 480.0;
  static const double maxWidthMd = 768.0;
  static const double maxWidthLg = 1024.0;
  static const double maxWidthXl = 1280.0;
  static const double maxWidth2xl = 1536.0;
  static const double maxWidthFull = double.infinity;

  // Common constraints
  static const constraintsXs = BoxConstraints(maxWidth: maxWidthXs);
  static const constraintsSm = BoxConstraints(maxWidth: maxWidthSm);
  static const constraintsMd = BoxConstraints(maxWidth: maxWidthMd);
  static const constraintsLg = BoxConstraints(maxWidth: maxWidthLg);
  static const constraintsXl = BoxConstraints(maxWidth: maxWidthXl);
  static const constraints2xl = BoxConstraints(maxWidth: maxWidth2xl);

  // Breakpoints for responsive design
  static const double breakpointSm = 640.0;
  static const double breakpointMd = 768.0;
  static const double breakpointLg = 1024.0;
  static const double breakpointXl = 1280.0;
  static const double breakpoint2xl = 1536.0;
}

/// Sizing presets for common UI elements
class Sizes {
  Sizes._();

  // Icon sizes
  static const double iconXs = Spacing.iconXs;
  static const double iconSm = Spacing.iconSm;
  static const double iconMd = Spacing.iconMd;
  static const double iconLg = Spacing.iconLg;
  static const double iconXl = Spacing.iconXl;
  static const double icon2xl = Spacing.icon2xl;

  // Button heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;
  static const double buttonHeightXl = 56.0;

  // Input heights
  static const double inputHeightSm = 32.0;
  static const double inputHeightMd = 40.0;
  static const double inputHeightLg = 48.0;

  // Avatar sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
  static const double avatarXl = 64.0;
  static const double avatar2xl = 96.0;

  // Badge/Chip sizes
  static const double badgeSm = 16.0;
  static const double badgeMd = 20.0;
  static const double badgeLg = 24.0;

  // Divider thickness
  static const double dividerThin = 1.0;
  static const double dividerMedium = 2.0;
  static const double dividerThick = 4.0;
}
