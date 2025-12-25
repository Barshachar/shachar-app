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
    return _toRfqStatusKey(normalized.substring(4));
  }
  return _toStatusKey(normalized);
}

String _toStatusKey(String normalized) {
  return 'status${_toPascalCase(normalized)}';
}

String _toRfqStatusKey(String normalized) {
  return 'rfqStatus${_toPascalCase(normalized)}';
}

String _toPascalCase(String value) {
  return value
      .split('_')
      .where((segment) => segment.isNotEmpty)
      .map((segment) => segment[0].toUpperCase() + segment.substring(1))
      .join();
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
    key: 'statusPlaced',
    tone: _StatusTone.success,
  ),
  'submitted': _StatusDefinition(
    key: 'statusPlaced',
    tone: _StatusTone.success,
  ),
  'pending': _StatusDefinition(
    key: 'statusPending',
    tone: _StatusTone.warning,
  ),
  'pending_approval': _StatusDefinition(
    key: 'statusPending',
    tone: _StatusTone.warning,
  ),
  'awaiting_approval': _StatusDefinition(
    key: 'statusPending',
    tone: _StatusTone.warning,
  ),
  'approval_pending': _StatusDefinition(
    key: 'statusPending',
    tone: _StatusTone.warning,
  ),
  'needs_approval': _StatusDefinition(
    key: 'statusPending',
    tone: _StatusTone.warning,
  ),
  'approved': _StatusDefinition(
    key: 'statusApproved',
    tone: _StatusTone.success,
  ),
  'approval_approved': _StatusDefinition(
    key: 'statusApproved',
    tone: _StatusTone.success,
  ),
  'rejected': _StatusDefinition(
    key: 'statusRejected',
    tone: _StatusTone.danger,
  ),
  'approval_rejected': _StatusDefinition(
    key: 'statusRejected',
    tone: _StatusTone.danger,
  ),
  'denied': _StatusDefinition(
    key: 'statusRejected',
    tone: _StatusTone.danger,
  ),
  'rejected_by_vendor': _StatusDefinition(
    key: 'statusRejected',
    tone: _StatusTone.danger,
  ),
  'vendor_rejected': _StatusDefinition(
    key: 'statusRejected',
    tone: _StatusTone.danger,
  ),
  'draft': _StatusDefinition(
    key: 'statusDraft',
    tone: _StatusTone.neutral,
  ),
  'cancelled': _StatusDefinition(
    key: 'statusCancelled',
    tone: _StatusTone.neutral,
  ),
  'canceled': _StatusDefinition(
    key: 'statusCancelled',
    tone: _StatusTone.neutral,
  ),
  'processing': _StatusDefinition(
    key: 'statusProcessing',
    tone: _StatusTone.info,
  ),
  'in_progress': _StatusDefinition(
    key: 'statusProcessing',
    tone: _StatusTone.info,
  ),
  'completed': _StatusDefinition(
    key: 'statusCompleted',
    tone: _StatusTone.success,
  ),
  'fulfilled': _StatusDefinition(
    key: 'statusCompleted',
    tone: _StatusTone.success,
  ),
  'shipped': _StatusDefinition(
    key: 'statusShipped',
    tone: _StatusTone.success,
  ),
  'in_transit': _StatusDefinition(
    key: 'statusShipped',
    tone: _StatusTone.success,
  ),
  'requested': _StatusDefinition(
    key: 'statusRequested',
    tone: _StatusTone.info,
  ),
  'received': _StatusDefinition(
    key: 'statusReceived',
    tone: _StatusTone.info,
  ),
  'refunded': _StatusDefinition(
    key: 'statusRefunded',
    tone: _StatusTone.success,
  ),
  'awaiting_quotes': _StatusDefinition(
    key: 'rfqStatusAwaitingQuotes',
    tone: _StatusTone.info,
  ),
  'awaiting_quote': _StatusDefinition(
    key: 'rfqStatusAwaitingQuotes',
    tone: _StatusTone.info,
  ),
  'open': _StatusDefinition(
    key: 'rfqStatusAwaitingQuotes',
    tone: _StatusTone.info,
  ),
  'quoted': _StatusDefinition(
    key: 'rfqStatusQuoted',
    tone: _StatusTone.success,
  ),
  'quote_submitted': _StatusDefinition(
    key: 'rfqStatusQuoted',
    tone: _StatusTone.success,
  ),
  'quote_sent': _StatusDefinition(
    key: 'rfqStatusQuoted',
    tone: _StatusTone.success,
  ),
  'expired': _StatusDefinition(
    key: 'rfqStatusExpired',
    tone: _StatusTone.neutral,
  ),
  'quote_expired': _StatusDefinition(
    key: 'rfqStatusExpired',
    tone: _StatusTone.neutral,
  ),
  'closed': _StatusDefinition(
    key: 'statusCompleted',
    tone: _StatusTone.success,
  ),
};
