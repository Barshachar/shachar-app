import 'package:flutter/material.dart';

import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';

/// UI-only model that provides localized label and chip colors for statuses.
class StatusChipStyle {
  const StatusChipStyle({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}

StatusChipStyle resolveStatusChipStyle({
  required String status,
  required MarketplaceLocalizations? l10n,
}) {
  final String normalized = _normalizeStatus(status);
  final _StatusDefinition? definition = _statusDefinitions[normalized];

  final _StatusDefinition effectiveDefinition = definition ??
      _StatusDefinition(
        key: _guessKey(normalized),
        tone: _StatusTone.info,
        fallbackLabel: _humanize(status),
      );

  final String fallbackLabel =
      effectiveDefinition.fallbackLabel ?? _humanize(status);
  final String translated =
      l10n?.translate(effectiveDefinition.key) ?? fallbackLabel;
  final Color foreground = _toneColor(effectiveDefinition.tone);
  return StatusChipStyle(
    label: translated,
    foreground: foreground,
    background: foreground.withValues(alpha: 0.12),
  );
}

String resolveStatusLabel({
  required String status,
  required MarketplaceLocalizations? l10n,
}) {
  final String normalized = _normalizeStatus(status);
  final _StatusDefinition? definition = _statusDefinitions[normalized];
  final _StatusDefinition effectiveDefinition = definition ??
      _StatusDefinition(
        key: _guessKey(normalized),
        tone: _StatusTone.info,
        fallbackLabel: _humanize(status),
      );
  final String fallbackLabel =
      effectiveDefinition.fallbackLabel ?? _humanize(status);
  return l10n?.translate(effectiveDefinition.key) ?? fallbackLabel;
}

String _normalizeStatus(String raw) {
  return raw
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

String _guessKey(String normalized) {
  if (_statusDefinitions.containsKey(normalized)) {
    return _statusDefinitions[normalized]!.key;
  }
  if (normalized.startsWith('rfq_')) {
    return 'rfq.status.${normalized.substring(4)}';
  }
  return 'status.$normalized';
}

String _humanize(String raw) {
  final Iterable<String> parts = raw.split(RegExp(r'[_\s-]+')).where(
        (String part) => part.isNotEmpty,
      );
  if (parts.isEmpty) {
    return raw;
  }
  return parts
      .map(
        (String part) =>
            part[0].toUpperCase() + part.substring(1).toLowerCase(),
      )
      .join(' ');
}

Color _toneColor(_StatusTone tone) {
  switch (tone) {
    case _StatusTone.neutral:
      return AColors.mutedForeground;
    case _StatusTone.success:
      return AColors.success;
    case _StatusTone.warning:
      return AColors.warning;
    case _StatusTone.danger:
      return AColors.danger;
    case _StatusTone.info:
      return AColors.info;
  }
}

class _StatusDefinition {
  const _StatusDefinition({
    required this.key,
    required this.tone,
    this.fallbackLabel,
  });

  final String key;
  final _StatusTone tone;
  final String? fallbackLabel;
}

enum _StatusTone { neutral, info, success, warning, danger }

final Map<String, _StatusDefinition> _statusDefinitions =
    <String, _StatusDefinition>{
  'placed': _StatusDefinition(
    key: 'status.placed',
    tone: _StatusTone.success,
  ),
  'submitted': _StatusDefinition(
    key: 'status.placed',
    tone: _StatusTone.success,
  ),
  'pending': _StatusDefinition(
    key: 'status.pending',
    tone: _StatusTone.warning,
  ),
  'pending_approval': _StatusDefinition(
    key: 'status.pending',
    tone: _StatusTone.warning,
  ),
  'awaiting_approval': _StatusDefinition(
    key: 'status.pending',
    tone: _StatusTone.warning,
  ),
  'approval_pending': _StatusDefinition(
    key: 'status.pending',
    tone: _StatusTone.warning,
  ),
  'needs_approval': _StatusDefinition(
    key: 'status.pending',
    tone: _StatusTone.warning,
  ),
  'approved': _StatusDefinition(
    key: 'status.approved',
    tone: _StatusTone.success,
  ),
  'approval_approved': _StatusDefinition(
    key: 'status.approved',
    tone: _StatusTone.success,
  ),
  'rejected': _StatusDefinition(
    key: 'status.rejected',
    tone: _StatusTone.danger,
  ),
  'approval_rejected': _StatusDefinition(
    key: 'status.rejected',
    tone: _StatusTone.danger,
  ),
  'denied': _StatusDefinition(
    key: 'status.rejected',
    tone: _StatusTone.danger,
  ),
  'rejected_by_vendor': _StatusDefinition(
    key: 'status.rejected',
    tone: _StatusTone.danger,
  ),
  'vendor_rejected': _StatusDefinition(
    key: 'status.rejected',
    tone: _StatusTone.danger,
  ),
  'draft': _StatusDefinition(
    key: 'status.draft',
    tone: _StatusTone.neutral,
  ),
  'cancelled': _StatusDefinition(
    key: 'status.cancelled',
    tone: _StatusTone.neutral,
  ),
  'canceled': _StatusDefinition(
    key: 'status.cancelled',
    tone: _StatusTone.neutral,
  ),
  'processing': _StatusDefinition(
    key: 'status.processing',
    tone: _StatusTone.info,
  ),
  'in_progress': _StatusDefinition(
    key: 'status.processing',
    tone: _StatusTone.info,
  ),
  'completed': _StatusDefinition(
    key: 'status.completed',
    tone: _StatusTone.success,
  ),
  'fulfilled': _StatusDefinition(
    key: 'status.completed',
    tone: _StatusTone.success,
  ),
  'shipped': _StatusDefinition(
    key: 'status.shipped',
    tone: _StatusTone.success,
  ),
  'in_transit': _StatusDefinition(
    key: 'status.shipped',
    tone: _StatusTone.success,
  ),
  'awaiting_quotes': _StatusDefinition(
    key: 'rfq.status.awaiting_quotes',
    tone: _StatusTone.info,
  ),
  'awaiting_quote': _StatusDefinition(
    key: 'rfq.status.awaiting_quotes',
    tone: _StatusTone.info,
  ),
  'open': _StatusDefinition(
    key: 'rfq.status.awaiting_quotes',
    tone: _StatusTone.info,
  ),
  'quoted': _StatusDefinition(
    key: 'rfq.status.quoted',
    tone: _StatusTone.success,
  ),
  'quote_submitted': _StatusDefinition(
    key: 'rfq.status.quoted',
    tone: _StatusTone.success,
  ),
  'quote_sent': _StatusDefinition(
    key: 'rfq.status.quoted',
    tone: _StatusTone.success,
  ),
  'expired': _StatusDefinition(
    key: 'rfq.status.expired',
    tone: _StatusTone.neutral,
  ),
  'quote_expired': _StatusDefinition(
    key: 'rfq.status.expired',
    tone: _StatusTone.neutral,
  ),
  'closed': _StatusDefinition(
    key: 'status.completed',
    tone: _StatusTone.success,
  ),
};
