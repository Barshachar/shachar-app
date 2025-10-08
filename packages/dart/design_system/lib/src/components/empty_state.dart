/// Enterprise-grade Empty & Error State components
/// Professional empty states with illustrations and actions
library;

import 'package:flutter/material.dart';
import 'package:design_system/src/tokens/tokens.dart';
import 'package:design_system/src/components/button.dart';

/// Empty state component
class EmptyState extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? description;
  final List<Widget>? actions;
  final double maxWidth;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.actions,
    this.maxWidth = 400,
  });

  const EmptyState.noData({
    Key? key,
    String title = 'אין נתונים זמינים',
    String? description,
    List<Widget>? actions,
  }) : this(
          key: key,
          icon: const Icon(Icons.inbox_outlined, size: 64),
          title: title,
          description: description,
          actions: actions,
        );

  const EmptyState.noResults({
    Key? key,
    String title = 'לא נמצאו תוצאות',
    String? description = 'נסה לשנות את החיפוש או הסינון',
    List<Widget>? actions,
  }) : this(
          key: key,
          icon: const Icon(Icons.search_off, size: 64),
          title: title,
          description: description,
          actions: actions,
        );

  const EmptyState.noConnection({
    Key? key,
    String title = 'אין חיבור לאינטרנט',
    String? description = 'בדוק את החיבור שלך ונסה שוב',
    List<Widget>? actions,
  }) : this(
          key: key,
          icon: const Icon(Icons.wifi_off, size: 64),
          title: title,
          description: description,
          actions: actions,
        );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: Insets.all6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: SemanticColors.mutedForeground,
                  size: 64,
                ),
                child: icon!,
              ),
              Gaps.v6,
            ],
            Text(
              title,
              style: TypographyPresets.headingSm(),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              Gaps.v3,
              Text(
                description!,
                style: TypographyPresets.bodyMd(
                  color: SemanticColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              Gaps.v6,
              Wrap(
                spacing: Spacing.s2,
                runSpacing: Spacing.s2,
                alignment: WrapAlignment.center,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state component
class ErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final String? error;
  final VoidCallback? onRetry;
  final List<Widget>? actions;
  final double maxWidth;

  const ErrorState({
    super.key,
    required this.title,
    this.description,
    this.error,
    this.onRetry,
    this.actions,
    this.maxWidth = 400,
  });

  const ErrorState.generic({
    Key? key,
    String title = 'משהו השתבש',
    String? description = 'אירעה שגיאה. אנא נסה שוב מאוחר יותר',
    VoidCallback? onRetry,
  }) : this(
          key: key,
          title: title,
          description: description,
          onRetry: onRetry,
        );

  const ErrorState.network({
    Key? key,
    String title = 'שגיאת רשת',
    String? description = 'לא הצלחנו להתחבר. בדוק את החיבור שלך',
    VoidCallback? onRetry,
  }) : this(
          key: key,
          title: title,
          description: description,
          onRetry: onRetry,
        );

  const ErrorState.notFound({
    Key? key,
    String title = 'העמוד לא נמצא',
    String? description = 'העמוד שחיפשת לא קיים',
  }) : this(
          key: key,
          title: title,
          description: description,
        );

  const ErrorState.forbidden({
    Key? key,
    String title = 'אין הרשאה',
    String? description = 'אין לך הרשאה לצפות בתוכן זה',
  }) : this(
          key: key,
          title: title,
          description: description,
        );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: Insets.all6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: Insets.all4,
              decoration: BoxDecoration(
                color: SemanticColors.destructive.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: SemanticColors.destructive,
              ),
            ),
            Gaps.v6,
            Text(
              title,
              style: TypographyPresets.headingSm(),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              Gaps.v3,
              Text(
                description!,
                style: TypographyPresets.bodyMd(
                  color: SemanticColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (error != null) ...[
              Gaps.v4,
              Container(
                padding: Insets.all3,
                decoration: BoxDecoration(
                  color: SemanticColors.muted,
                  borderRadius: BorderRadii.md,
                ),
                child: Text(
                  error!,
                  style: TypographyPresets.code(
                    color: SemanticColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (onRetry != null ||
                (actions != null && actions!.isNotEmpty)) ...[
              Gaps.v6,
              Wrap(
                spacing: Spacing.s2,
                runSpacing: Spacing.s2,
                alignment: WrapAlignment.center,
                children: [
                  if (onRetry != null)
                    AppButton.primary(
                      text: 'נסה שוב',
                      onPressed: onRetry!,
                      leadingIcon: const Icon(Icons.refresh),
                    ),
                  if (actions != null) ...actions!,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Coming soon placeholder
class ComingSoon extends StatelessWidget {
  final String title;
  final String? description;

  const ComingSoon({
    super.key,
    this.title = 'בקרוב',
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: const Icon(Icons.upcoming, size: 64),
      title: title,
      description: description ?? 'תכונה זו תהיה זמינה בקרוב',
    );
  }
}

/// Maintenance mode placeholder
class MaintenanceMode extends StatelessWidget {
  final String title;
  final String? description;

  const MaintenanceMode({
    super.key,
    this.title = 'אתר בתחזוקה',
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: const Icon(Icons.construction, size: 64),
      title: title,
      description: description ?? 'האתר נמצא כרגע בתחזוקה. נחזור בקרוב',
    );
  }
}

/// 404 Not Found page
class NotFoundPage extends StatelessWidget {
  final VoidCallback? onGoHome;

  const NotFoundPage({
    super.key,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ErrorState(
        title: 'העמוד לא נמצא',
        description: 'העמוד שחיפשת לא קיים או הוסר',
        onRetry: onGoHome,
      ),
    );
  }
}

/// No permission placeholder
class NoPermission extends StatelessWidget {
  final String? resource;

  const NoPermission({
    super.key,
    this.resource,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState.forbidden(
      description: resource != null
          ? 'אין לך הרשאה לצפות ב$resource'
          : 'אין לך הרשאה לצפות בתוכן זה',
    );
  }
}
