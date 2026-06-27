import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';

/// A premium, eye-catching promotions banner intended for the customer home
/// surface. It layers a brand gradient, a soft animated sheen, gold accents and
/// a glassy call-to-action to give discounts a high-end "members club" feel.
///
/// The widget is fully RTL-aware and degrades gracefully on narrow screens.
class PremiumPromotionsBanner extends StatefulWidget {
  const PremiumPromotionsBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.badgeLabel,
    required this.highlight,
    required this.onTap,
  });

  /// Headline, e.g. "מבצעי הקיץ".
  final String title;

  /// Supporting line under the title.
  final String subtitle;

  /// Call-to-action label rendered inside the pill button.
  final String cta;

  /// Small uppercase-ish chip label, e.g. "מועדון פרימיום".
  final String badgeLabel;

  /// Bold savings highlight, e.g. "עד 40% הנחה".
  final String highlight;

  final VoidCallback onTap;

  @override
  State<PremiumPromotionsBanner> createState() =>
      _PremiumPromotionsBannerState();
}

class _PremiumPromotionsBannerState extends State<PremiumPromotionsBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_fade);
    // A single forward pass keeps `pumpAndSettle` happy in widget tests.
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _BannerBody(
          isRtl: isRtl,
          title: widget.title,
          subtitle: widget.subtitle,
          cta: widget.cta,
          badgeLabel: widget.badgeLabel,
          highlight: widget.highlight,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody({
    required this.isRtl,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.badgeLabel,
    required this.highlight,
    required this.onTap,
  });

  final bool isRtl;
  final String title;
  final String subtitle;
  final String cta;
  final String badgeLabel;
  final String highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$badgeLabel. $title. $highlight',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const ValueKey('home_campaign_banner'),
          borderRadius: ARadii.lg,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: ARadii.lg,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFD4453A),
                  AColors.primary,
                  Color(0xFF7E211A),
                ],
                stops: <double>[0.0, 0.5, 1.0],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AColors.primaryDark.withValues(alpha: 0.38),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: ARadii.lg,
              child: Stack(
                children: <Widget>[
                  // Decorative gold glow, anchored to the trailing top corner.
                  PositionedDirectional(
                    top: -56,
                    end: -36,
                    child: _GlowOrb(
                      size: 168,
                      colors: <Color>[
                        AColors.premiumGoldLight.withValues(alpha: 0.55),
                        AColors.premiumGold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  // Cool counter-glow on the opposite corner for depth.
                  PositionedDirectional(
                    bottom: -64,
                    start: -48,
                    child: _GlowOrb(
                      size: 150,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  // Diagonal sheen sweeping across the surface.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _SheenPainter(isRtl: isRtl),
                      ),
                    ),
                  ),
                  // Hairline highlight along the top edge for a glassy lift.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: ARadii.lg,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      ASpacing.xl,
                      ASpacing.xl,
                      ASpacing.xl,
                      ASpacing.xl,
                    ),
                    child: _BannerContent(
                      isRtl: isRtl,
                      title: title,
                      subtitle: subtitle,
                      cta: cta,
                      badgeLabel: badgeLabel,
                      highlight: highlight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({
    required this.isRtl,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.badgeLabel,
    required this.highlight,
  });

  final bool isRtl;
  final String title;
  final String subtitle;
  final String cta;
  final String badgeLabel;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _PremiumBadge(label: badgeLabel),
              const SizedBox(height: ASpacing.md),
              Text(
                title,
                style: ATypography.titleLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: ASpacing.xs),
              _HighlightText(highlight: highlight),
              const SizedBox(height: ASpacing.sm),
              Text(
                subtitle,
                style: ATypography.bodySm.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: ASpacing.lg),
              _CtaPill(label: cta, isRtl: isRtl),
            ],
          ),
        ),
        const SizedBox(width: ASpacing.md),
        const _MedallionIcon(),
      ],
    );
  }
}

/// Glassy pill with a sparkle marking the promotion as premium.
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        ASpacing.sm,
        ASpacing.xs,
        ASpacing.md,
        ASpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: ARadii.pill,
        border: Border.all(
          color: AColors.premiumGoldLight.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.auto_awesome,
            size: 15,
            color: AColors.premiumGoldLight,
          ),
          const SizedBox(width: ASpacing.xs),
          Text(
            label,
            style: ATypography.chip.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Large savings line rendered with a warm gold gradient.
class _HighlightText extends StatelessWidget {
  const _HighlightText({required this.highlight});

  final String highlight;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = ATypography.headline2.copyWith(
      fontWeight: FontWeight.w900,
      height: 1.05,
      letterSpacing: -0.5,
    );
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => const LinearGradient(
        colors: <Color>[
          AColors.premiumGoldLight,
          AColors.premiumGold,
          AColors.premiumGoldDeep,
        ],
      ).createShader(bounds),
      child: Text(
        highlight,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Light call-to-action pill with a directional chevron.
class _CtaPill extends StatelessWidget {
  const _CtaPill({required this.label, required this.isRtl});

  final String label;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        ASpacing.lg,
        ASpacing.sm,
        ASpacing.md,
        ASpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ARadii.pill,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AColors.primaryDark.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              style: ATypography.button.copyWith(color: AColors.primaryDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          const SizedBox(width: ASpacing.xs),
          Icon(
            isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            size: 18,
            color: AColors.primaryDark,
          ),
        ],
      ),
    );
  }
}

/// Gold-ringed glass medallion housing the offer icon.
class _MedallionIcon extends StatelessWidget {
  const _MedallionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
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
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AColors.premiumGold.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: -2,
          ),
        ],
      ),
      child: const Icon(
        Icons.local_offer_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

/// Soft radial glow used as a decorative light source.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

/// Paints a single translucent diagonal sheen band across the banner.
class _SheenPainter extends CustomPainter {
  const _SheenPainter({required this.isRtl});

  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    final double bandWidth = size.width * 0.32;
    // Position the band around the leading third of the surface.
    final double center = isRtl ? size.width * 0.66 : size.width * 0.34;

    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromLTWH(center - bandWidth, 0, bandWidth * 2, size.height),
      );

    canvas.save();
    // Skew the band ~18° so it reads as a light streak rather than a stripe.
    final double skew = math.tan(18 * math.pi / 180);
    canvas.transform(Matrix4(
      1, 0, 0, 0, //
      -skew, 1, 0, 0, //
      0, 0, 1, 0, //
      0, 0, 0, 1, //
    ).storage);

    canvas.drawRect(
      Rect.fromLTWH(center - bandWidth, -size.height,
          bandWidth * 2, size.height * 3),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SheenPainter oldDelegate) => oldDelegate.isRtl != isRtl;
}
