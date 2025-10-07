/// Admin Dashboard Components
/// Enterprise-grade admin dashboard widgets
library;

import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Metric card for dashboard
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool? isPositiveTrend;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.trend,
    this.isPositiveTrend,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: Insets.all4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: Insets.all2,
                    decoration: BoxDecoration(
                      color: (color ?? SemanticColors.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadii.md,
                    ),
                    child: Icon(
                      icon,
                      color: color ?? SemanticColors.primary,
                      size: Sizes.iconMd,
                    ),
                  ),
                  Gaps.h3,
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TypographyPresets.labelMd(
                      color: SemanticColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
            Gaps.v3,
            Text(
              value,
              style: TypographyPresets.headingLg(),
            ),
            if (subtitle != null || trend != null) ...[
              Gaps.v2,
              Row(
                children: [
                  if (subtitle != null)
                    Expanded(
                      child: Text(
                        subtitle!,
                        style: TypographyPresets.bodySm(
                          color: SemanticColors.mutedForeground,
                        ),
                      ),
                    ),
                  if (trend != null) ...[
                    Icon(
                      isPositiveTrend == true
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: Sizes.iconSm,
                      color: isPositiveTrend == true
                          ? SemanticColors.success
                          : SemanticColors.destructive,
                    ),
                    Gaps.h1,
                    Text(
                      trend!,
                      style: TypographyPresets.labelSm(
                        color: isPositiveTrend == true
                            ? SemanticColors.success
                            : SemanticColors.destructive,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// System health indicator
class SystemHealthCard extends StatelessWidget {
  final String title;
  final double healthScore; // 0-100
  final List<HealthMetric> metrics;

  const SystemHealthCard({
    super.key,
    required this.title,
    required this.healthScore,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: Insets.all4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TypographyPresets.headingSm(),
                  ),
                ),
                StatusBadge(status: _getStatusText()),
              ],
            ),
            Gaps.v4,
            CircularProgress(
              value: healthScore / 100,
              size: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${healthScore.toInt()}%',
                    style: TypographyPresets.headingMd(),
                  ),
                  Text(
                    _getStatusText(),
                    style: TypographyPresets.labelSm(
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
            Gaps.v4,
            ...metrics.map((metric) => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.s2),
                  child: _HealthMetricRow(metric: metric),
                )),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    if (healthScore >= 90) return 'מצוין';
    if (healthScore >= 70) return 'טוב';
    if (healthScore >= 50) return 'בינוני';
    return 'דורש תשומת לב';
  }

  Color _getStatusColor() {
    if (healthScore >= 90) return SemanticColors.success;
    if (healthScore >= 70) return SemanticColors.info;
    if (healthScore >= 50) return SemanticColors.warning;
    return SemanticColors.destructive;
  }
}

/// Health metric
class HealthMetric {
  final String name;
  final double value; // 0-100
  final String status;

  HealthMetric({
    required this.name,
    required this.value,
    required this.status,
  });
}

class _HealthMetricRow extends StatelessWidget {
  final HealthMetric metric;

  const _HealthMetricRow({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            metric.name,
            style: TypographyPresets.bodySm(),
          ),
        ),
        Gaps.h2,
        SizedBox(
          width: 100,
          child: AppProgressBar(
            value: metric.value / 100,
            height: 6,
          ),
        ),
        Gaps.h2,
        SizedBox(
          width: 60,
          child: Text(
            '${metric.value.toInt()}%',
            style: TypographyPresets.labelSm(
              color: SemanticColors.mutedForeground,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Quick actions card
class QuickActionsCard extends StatelessWidget {
  final String title;
  final List<QuickAction> actions;

  const QuickActionsCard({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: Insets.all4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TypographyPresets.headingSm(),
            ),
            Gaps.v4,
            Wrap(
              spacing: Spacing.s2,
              runSpacing: Spacing.s2,
              children: actions.map((action) {
                return AppButton(
                  text: action.label,
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  leadingIcon: action.icon != null ? Icon(action.icon) : null,
                  onPressed: action.onTap,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action
class QuickAction {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  QuickAction({
    required this.label,
    this.icon,
    required this.onTap,
  });
}

/// Activity feed card
class ActivityFeedCard extends StatelessWidget {
  final String title;
  final List<ActivityItem> activities;
  final VoidCallback? onViewAll;

  const ActivityFeedCard({
    super.key,
    required this.title,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: Insets.all4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TypographyPresets.headingSm(),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('הצג הכל'),
                  ),
              ],
            ),
            Gaps.v3,
            ...activities.map((activity) => _ActivityItemWidget(
                  activity: activity,
                )),
          ],
        ),
      ),
    );
  }
}

/// Activity item
class ActivityItem {
  final String title;
  final String? description;
  final DateTime timestamp;
  final IconData? icon;
  final Color? color;

  ActivityItem({
    required this.title,
    this.description,
    required this.timestamp,
    this.icon,
    this.color,
  });
}

class _ActivityItemWidget extends StatelessWidget {
  final ActivityItem activity;

  const _ActivityItemWidget({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (activity.color ?? SemanticColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadii.md,
            ),
            child: Icon(
              activity.icon ?? Icons.circle,
              size: Sizes.iconSm,
              color: activity.color ?? SemanticColors.primary,
            ),
          ),
          Gaps.h3,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TypographyPresets.bodyMd(),
                ),
                if (activity.description != null) ...[
                  Gaps.v1,
                  Text(
                    activity.description!,
                    style: TypographyPresets.bodySm(
                      color: SemanticColors.mutedForeground,
                    ),
                  ),
                ],
                Gaps.v1,
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: TypographyPresets.labelXs(
                    color: SemanticColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'עכשיו';
    if (diff.inMinutes < 60) return 'לפני ${diff.inMinutes} דקות';
    if (diff.inHours < 24) return 'לפני ${diff.inHours} שעות';
    return 'לפני ${diff.inDays} ימים';
  }
}

/// Chart card (placeholder for real charts)
class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final List<ChartLegendItem>? legend;

  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: Insets.all4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TypographyPresets.headingSm(),
            ),
            if (subtitle != null) ...[
              Gaps.v1,
              Text(
                subtitle!,
                style: TypographyPresets.bodySm(
                  color: SemanticColors.mutedForeground,
                ),
              ),
            ],
            Gaps.v4,
            chart,
            if (legend != null && legend!.isNotEmpty) ...[
              Gaps.v4,
              Wrap(
                spacing: Spacing.s4,
                runSpacing: Spacing.s2,
                children: legend!.map((item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadii.sm,
                        ),
                      ),
                      Gaps.h2,
                      Text(
                        item.label,
                        style: TypographyPresets.labelSm(),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chart legend item
class ChartLegendItem {
  final String label;
  final Color color;

  ChartLegendItem({
    required this.label,
    required this.color,
  });
}
