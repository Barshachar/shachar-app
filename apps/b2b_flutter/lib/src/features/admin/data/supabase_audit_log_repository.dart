import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/admin/data/fake_audit_log_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/audit_log_entry.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/audit_log_repository.dart';

class SupabaseAuditLogRepository implements AuditLogRepository {
  SupabaseAuditLogRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  static const Duration _fetchTimeout = Duration(seconds: 5);
  static const Duration _directoryTimeout = Duration(seconds: 3);

  @override
  Future<List<AuditLogEntry>> fetchEntries() async {
    try {
      final Map<String, _UserInfo> directory = await _fetchUserDirectory();
      final PostgrestList rows = await _client
          .from('audit_log')
          .select(
            'actor_user_id, action, table_name, row_id, metadata, created_at',
          )
          .order('created_at', ascending: false)
          .limit(200)
          .timeout(_fetchTimeout);
      if (rows.isEmpty) {
        return await _fallbackEntries();
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> row) => _mapEntry(row, directory))
          .toList(growable: false);
    } catch (error) {
      debugPrint('[AUDIT_LOG][WARN] fallback due to: $error');
      return await _fallbackEntries();
    }
  }

  Future<Map<String, _UserInfo>> _fetchUserDirectory() async {
    try {
      final PostgrestList rpc = await _client.rpc<PostgrestList>(
        'admin_list_company_users',
        params: <String, dynamic>{'p_company_id': null},
      ).timeout(_directoryTimeout);
      final Map<String, _UserInfo> directory = <String, _UserInfo>{};
      for (final row in rpc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(row as Map);
        final String userId = data['user_id'] as String? ?? '';
        if (userId.isEmpty) {
          continue;
        }
        final String email = data['email'] as String? ?? '';
        final String name = data['full_name'] as String? ?? '';
        directory[userId] = _UserInfo(name: name.trim(), email: email.trim());
      }
      return directory;
    } catch (error) {
      debugPrint('[AUDIT_LOG][WARN] user directory unavailable: $error');
      return const <String, _UserInfo>{};
    }
  }

  Future<List<AuditLogEntry>> _fallbackEntries() {
    return const FakeAuditLogRepository().fetchEntries();
  }

  AuditLogEntry _mapEntry(
    Map<String, dynamic> row,
    Map<String, _UserInfo> directory,
  ) {
    final String actorId = row['actor_user_id'] as String? ?? '';
    final Map<String, dynamic> metadata = _parseMetadata(row['metadata']);
    final _UserInfo? actor = directory[actorId];
    final String actorEmail =
        _stringValue(metadata['actor_email']) ?? actor?.email ?? '';
    final String actorName =
        _stringValue(metadata['actor_name']) ?? actor?.name ?? '';
    final String userName =
        actorName.isNotEmpty ? actorName : _deriveName(actorEmail, actorId);
    final String userEmail =
        actorEmail.isNotEmpty ? actorEmail : _fallbackEmail(actorId);
    final String actionRaw = row['action'] as String? ?? '';
    final String action = _humanize(actionRaw, fallback: 'Activity');
    final String moduleRaw =
        _stringValue(metadata['module']) ?? row['table_name'] as String? ?? '';
    final String module = _humanize(moduleRaw, fallback: 'System');
    final String? rowId = row['row_id'] as String?;
    final String context = _resolveContext(metadata, module, rowId);
    final String client = _stringValue(metadata['client']) ??
        _stringValue(metadata['source']) ??
        'System';
    final DateTime timestamp =
        _parseTimestamp(row['created_at']) ?? DateTime.now();
    final AuditLogStatus status = _resolveStatus(metadata, actionRaw);
    return AuditLogEntry(
      timestamp: timestamp,
      userName: userName,
      userEmail: userEmail,
      action: action,
      module: module,
      context: context,
      status: status,
      client: client,
    );
  }

  Map<String, dynamic> _parseMetadata(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  String? _stringValue(dynamic value) {
    final String? text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  String _deriveName(String email, String actorId) {
    if (email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    }
    if (actorId.isNotEmpty) {
      final String shortId =
          actorId.length > 6 ? actorId.substring(0, 6) : actorId;
      return 'User $shortId';
    }
    return 'System';
  }

  String _fallbackEmail(String actorId) {
    if (actorId.isNotEmpty) {
      return '$actorId@local';
    }
    return 'system@local';
  }

  String _humanize(String value, {required String fallback}) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    final List<String> parts = trimmed
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return fallback;
    }
    return parts
        .map((String part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _resolveContext(
    Map<String, dynamic> metadata,
    String module,
    String? rowId,
  ) {
    final String? context = _stringValue(metadata['context']);
    if (context != null) {
      return context;
    }
    final String? device = _stringValue(metadata['device']);
    final String? ip = _stringValue(metadata['ip']);
    if (device != null || ip != null) {
      final List<String> parts = <String>[
        if (device != null) device,
        if (ip != null) ip,
      ];
      return parts.join(' • ');
    }
    if (rowId != null && rowId.isNotEmpty) {
      return rowId.length > 8 ? rowId.substring(0, 8) : rowId;
    }
    return module;
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }

  AuditLogStatus _resolveStatus(
    Map<String, dynamic> metadata,
    String action,
  ) {
    final String status = (metadata['status'] as String? ?? '').toLowerCase();
    switch (status) {
      case 'error':
      case 'failed':
        return AuditLogStatus.error;
      case 'warning':
      case 'warn':
      case 'pending':
        return AuditLogStatus.warning;
      case 'success':
        return AuditLogStatus.success;
    }
    final String lowered = action.toLowerCase();
    if (lowered.contains('fail') ||
        lowered.contains('error') ||
        lowered.contains('reject')) {
      return AuditLogStatus.error;
    }
    if (lowered.contains('cancel') ||
        lowered.contains('warning') ||
        lowered.contains('suspend')) {
      return AuditLogStatus.warning;
    }
    return AuditLogStatus.success;
  }
}

class _UserInfo {
  const _UserInfo({required this.name, required this.email});

  final String name;
  final String email;
}
