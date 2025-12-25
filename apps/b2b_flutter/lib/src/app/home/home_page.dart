import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsDirectional padding = context.pagePadding();
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AColors.foregroundOnDark,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
        title: const Text('א.שחר Marketplace'),
      ),
      body: Stack(
        children: [
          const _AuroraBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                start: padding.start,
                end: padding.end,
                top: ASpacing.xxxl,
                bottom: ASpacing.xxl,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 960;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroSection(isWide: isWide),
                      const SizedBox(height: ASpacing.xxl),
                      _StatsRow(isWide: isWide),
                      const SizedBox(height: ASpacing.xxl),
                      _FeatureGrid(isWide: isWide),
                      const SizedBox(height: ASpacing.xxl),
                      _FlowsSection(isWide: isWide),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AColors.midnight,
              AColors.midnightDeep,
              Color(0xFF04070F),
            ],
          ),
        ),
        child: Stack(
          children: [
            _blurSpot(
              alignment: Alignment.topRight,
              colors: const [AColors.auroraBlue, AColors.auroraCyan],
              size: 340,
              opacity: 0.55,
            ),
            _blurSpot(
              alignment: Alignment.bottomLeft,
              colors: const [AColors.primary, AColors.auroraLime],
              size: 320,
              opacity: 0.42,
            ),
            _blurSpot(
              alignment: Alignment.centerLeft,
              colors: const [AColors.accent, AColors.primary],
              size: 260,
              opacity: 0.35,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.04),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: ASpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurSpot({
    required Alignment alignment,
    required List<Color> colors,
    double size = 280,
    double opacity = 0.4,
  }) {
    final List<Color> gradientColors =
        colors.map((color) => color.withValues(alpha: opacity)).toList();
    final List<double> resolvedStops = gradientColors.length == 3
        ? const [0, 0.4, 1]
        : List<double>.generate(
            gradientColors.length,
            (int index) => gradientColors.length == 1
                ? 0
                : index / (gradientColors.length - 1),
          );

    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: gradientColors,
            stops: resolvedStops,
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget pitch = _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'חוויית מסחר עתידית ל-B2B',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AColors.foregroundOnDark,
            ),
          ),
          const SizedBox(height: ASpacing.md),
          Text(
            'דשבורד אחוד לספקים, לקוחות ואדמין עם רענון חי, רספונסיביות מלאה וזרימות אופליין בטוחות.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: ASpacing.lg),
          Wrap(
            spacing: ASpacing.sm,
            runSpacing: ASpacing.sm,
            children: const [
              _FeatureChip(
                  icon: Icons.timeline_rounded, label: 'עדכוני זמן אמת'),
              _FeatureChip(
                  icon: Icons.shield_moon_outlined, label: 'RLS ללא פשרות'),
              _FeatureChip(
                  icon: Icons.offline_bolt_rounded,
                  label: 'אופליין + דלתא סינק'),
              _FeatureChip(
                  icon: Icons.webhook_outlined, label: 'אוטומציה ו-Edge'),
            ],
          ),
          const SizedBox(height: ASpacing.xl),
          Wrap(
            spacing: ASpacing.md,
            runSpacing: ASpacing.md,
            children: [
              AButton.primary(
                label: 'התחברות מאובטחת',
                icon: const Icon(Icons.lock_open_rounded),
                expand: !isWide,
                onPressed: () => context.goNamed('login'),
              ),
              AButton.secondary(
                label: 'סיור בקטלוג',
                icon: const Icon(Icons.auto_awesome_mosaic_outlined),
                expand: !isWide,
                onPressed: () => context.goNamed('catalog'),
              ),
            ],
          ),
          const SizedBox(height: ASpacing.lg),
          Wrap(
            spacing: ASpacing.md,
            runSpacing: ASpacing.sm,
            children: const [
              _SignalBadge(
                label: '99.95% זמינות',
                icon: Icons.cloud_done_rounded,
              ),
              _SignalBadge(
                label: 'חיווי Live לשערי אשראי',
                icon: Icons.bolt_rounded,
              ),
              _SignalBadge(
                label: 'תורים אופטימיים לאופליין',
                icon: Icons.offline_pin_rounded,
              ),
            ],
          ),
        ],
      ),
    );

    final Widget panel = const _LivePanel();

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: pitch),
          const SizedBox(width: ASpacing.xl),
          Expanded(flex: 2, child: panel),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        pitch,
        const SizedBox(height: ASpacing.lg),
        panel,
      ],
    );
  }
}

class _LivePanel extends StatelessWidget {
  const _LivePanel();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<_LiveStatus> statuses = <_LiveStatus>[
      _LiveStatus(
        label: 'הזמנות',
        detail: '98% מסונכרנות',
        progress: 0.98,
        color: AColors.primary,
      ),
      _LiveStatus(
        label: 'אשראי עסקי',
        detail: 'תקרת אשראי בטוחה',
        progress: 0.72,
        color: AColors.auroraBlue,
      ),
      _LiveStatus(
        label: 'משלוחים חכמים',
        detail: 'ETA דינמי לספקים',
        progress: 0.84,
        color: AColors.accent,
      ),
    ];
    return _GlassCard(
      gradient: const LinearGradient(
        colors: [
          Color(0x112CF6FF),
          Color(0x220CECDD),
          Color(0x1138BDF8),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AColors.primary, AColors.accent],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: const Icon(Icons.radar_rounded,
                    color: Colors.black, size: 20),
              ),
              const SizedBox(width: ASpacing.sm),
              Text(
                'לוח תפעול חי',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            'חיווי בזמן אמת להזמנות, זיכויים ומשלוחים. מוכן ל-RTL, לווב ולדסקטופ אדמין.',
            style: textTheme.bodyMedium?.copyWith(
              color: AColors.mutedForegroundOnDark,
            ),
          ),
          const SizedBox(height: ASpacing.lg),
          ...statuses.map(
            (status) => Padding(
              padding: const EdgeInsets.only(bottom: ASpacing.md),
              child: _StatusMeter(status: status),
            ),
          ),
          const SizedBox(height: ASpacing.md),
          Container(
            padding: const EdgeInsets.all(ASpacing.md),
            decoration: BoxDecoration(
              borderRadius: ARadii.md,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.motion_photos_auto_outlined,
                    color: Colors.white, size: 18),
                const SizedBox(width: ASpacing.sm),
                Expanded(
                  child: Text(
                    'חיבורים ל-Edge Functions ו-Webhooks לשחרור אוטומציות מבוססות אירועים.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final List<_StatPill> stats = const [
      _StatPill(
        icon: Icons.shield_outlined,
        value: '99.95%',
        label: 'זמינות',
        detail: 'פריסת Edge + RLS',
      ),
      _StatPill(
        icon: Icons.speed_rounded,
        value: '120ms',
        label: 'זמן תגובה',
        detail: 'לטעינת דשבורד ממוצעת',
      ),
      _StatPill(
        icon: Icons.offline_bolt_outlined,
        value: 'Offline',
        label: 'סנכרון בטוח',
        detail: 'Delta-sync + תורים אופטימיים',
      ),
    ];
    final double availableWidth =
        MediaQuery.of(context).size.width - (ASpacing.page * 2);
    final double itemWidth =
        isWide ? (availableWidth - (ASpacing.lg * 2)) / 3 : double.infinity;
    return Wrap(
      spacing: ASpacing.lg,
      runSpacing: ASpacing.lg,
      alignment: WrapAlignment.start,
      children: stats
          .map(
            (pill) => SizedBox(
              width: itemWidth,
              child: pill,
            ),
          )
          .toList(),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final List<_FeatureTile> tiles = const [
      _FeatureTile(
        icon: Icons.auto_graph_rounded,
        title: 'דשבורד בקרה חי',
        description:
            'תצוגות מותאמות ללקוחות, ספקים ואדמין עם מסננים חכמים והקשרים עסקיים.',
        tags: ['התראות בזמן אמת', 'ניתוח קטלוג'],
      ),
      _FeatureTile(
        icon: Icons.cloud_sync_rounded,
        title: 'Offline-first',
        description:
            'מחסן מקומי, סנכרון דלתא ותורים אופטימיים בדיוק לפי docs/offline.md.',
        tags: ['Delta-sync', 'Queue orchestration'],
      ),
      _FeatureTile(
        icon: Icons.security_rounded,
        title: 'בידול רב-דיירים',
        description:
            'RLS בסופבייס ללא שימוש במפתחות Service בצד לקוח. הגנות מובנות בכל זרימה.',
        tags: ['RLS', 'Zero-trust'],
      ),
      _FeatureTile(
        icon: Icons.view_compact_alt_rounded,
        title: 'מוכן לווב ולאדמין',
        description:
            'פריסת RTL מלאה, גריד רספונסיבי ומיקרו-אנימציות שמרגישות כמו קונסולת עתיד.',
        tags: ['RTL', 'Web / Desktop'],
      ),
    ];
    final double targetWidth = isWide ? 420 : double.infinity;
    return Wrap(
      spacing: ASpacing.lg,
      runSpacing: ASpacing.lg,
      children: tiles
          .map(
            (tile) => SizedBox(
              width: targetWidth,
              child: tile,
            ),
          )
          .toList(),
    );
  }
}

class _FlowsSection extends StatelessWidget {
  const _FlowsSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final List<_FlowCard> flows = const [
      _FlowCard(
        title: 'מסלול הזמנה דינמי',
        subtitle: 'נתיב אחד לניהול RFQ, הזמנות ורכש תפעולי.',
        steps: [
          'הצעות מחיר עם חיווי SLA וסבבי אישור פנימיים',
          'מיפוי לוגיסטי: שילוח, איסוף ו-SLA שילוב עם ספקים',
          'דיווח אוטומטי ללקוח + נראות אדמין ברמת שורה',
        ],
      ),
      _FlowCard(
        title: 'חוויית ספק עתידית',
        subtitle: 'דפי ספקים חכמים לקטלוג, תמחור ויכולות Web-first.',
        steps: [
          'קונסולת דשבורד וובי עם תמיכה ב-RTL',
          'העלאות מאובטחות, תמחור דינמי וקמפיינים',
          'עדכוני Live על מלאי ואספקה ישירות מהמחסן',
        ],
      ),
    ];

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: flows.first),
          const SizedBox(width: ASpacing.lg),
          Expanded(child: flows.last),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        flows.first,
        const SizedBox(height: ASpacing.lg),
        flows.last,
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(ASpacing.xl),
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = ARadii.xl;
    final Color borderColor =
        Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: gradient ??
                const LinearGradient(
                  colors: [
                    Color(0x22FFFFFF),
                    Color(0x0FFFFFFF),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3300B5FF),
                blurRadius: 32,
                offset: Offset(0, 20),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.md,
        vertical: ASpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: ARadii.pill,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: ASpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _SignalBadge extends StatelessWidget {
  const _SignalBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ASpacing.md,
        vertical: ASpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: ARadii.md,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        color: Colors.white.withValues(alpha: 0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: ASpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _LiveStatus {
  const _LiveStatus({
    required this.label,
    required this.detail,
    required this.progress,
    required this.color,
  });

  final String label;
  final String detail;
  final double progress;
  final Color color;
}

class _StatusMeter extends StatelessWidget {
  const _StatusMeter({required this.status});

  final _LiveStatus status;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              status.label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              status.detail,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        const SizedBox(height: ASpacing.xs),
        ClipRRect(
          borderRadius: ARadii.pill,
          child: LinearProgressIndicator(
            value: status.progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(
                status.color.withValues(alpha: 0.9)),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return _GlassCard(
      padding: const EdgeInsets.all(ASpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ASpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AColors.primary, AColors.accent],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: AColors.primary.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: ASpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: AColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: ASpacing.xs),
                Text(
                  detail,
                  style: textTheme.bodySmall?.copyWith(
                    color: AColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.tags,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ASpacing.sm),
                decoration: BoxDecoration(
                  borderRadius: ARadii.md,
                  color: AColors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  icon,
                  color: AColors.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: ASpacing.sm),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: ASpacing.sm),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: AColors.mutedForeground,
            ),
          ),
          const SizedBox(height: ASpacing.sm),
          Wrap(
            spacing: ASpacing.xs,
            runSpacing: ASpacing.xs,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ASpacing.sm,
                      vertical: ASpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: ARadii.pill,
                      color: AColors.surfaceMuted.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      tag,
                      style: textTheme.labelMedium?.copyWith(
                        color: AColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  final String title;
  final String subtitle;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: ASpacing.xs),
          Text(
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AColors.mutedForeground,
            ),
          ),
          const SizedBox(height: ASpacing.lg),
          ...steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: ASpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepBadge(index: entry.key + 1),
                      const SizedBox(width: ASpacing.sm),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AColors.primary, AColors.accent],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: Text(
          '$index',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
