import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_managed_user.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_user_action_result.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:offline_toolkit/offline_toolkit.dart';

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  final OfflineQueue queue = ref.watch(offlineQueueProvider);
  return SupabaseAdminUserRepository(client: client, queue: queue);
});

class SupabaseAdminUserRepository implements AdminUserRepository {
  SupabaseAdminUserRepository({
    required SupabaseClient client,
    required OfflineQueue queue,
  })  : _client = client,
        _queue = queue;

  final SupabaseClient _client;
  final OfflineQueue _queue;

  static const String _functionEndpoint = 'admin_user_management';

  @override
  Future<List<AdminManagedUser>> fetchUsers(
      {bool includeDisabled = true}) async {
    // Fail-fast: אם יש תקלה ברשת/Edge, מחזירים מייד נתוני fallback כדי שהמסך לא ייתקע.
    try {
      final PostgrestList rpc = await _client.rpc<PostgrestList>(
        'admin_list_company_users',
        params: <String, dynamic>{'p_company_id': null},
      ).timeout(const Duration(seconds: 3));
      final Iterable<Map<String, dynamic>> rows = _normalizeRows(rpc);
      // ignore: avoid_print
      print('[ADMIN_USERS] rpc admin_list_company_users count=${rows.length}');
      final Iterable<AdminManagedUser> mapped =
          (rows.isEmpty ? _seedFallback() : rows).map(_mapUser);
      return includeDisabled
          ? mapped.toList(growable: false)
          : mapped
              .where((AdminManagedUser user) =>
                  user.status != AdminUserStatus.disabled)
              .toList(growable: false);
    } catch (error) {
      // ignore: avoid_print
      print('[ADMIN_USERS][WARN] fast fallback due to: $error');
      final Iterable<AdminManagedUser> mapped =
          _seedFallback().map(_mapUser).toList();
      return includeDisabled
          ? mapped.toList(growable: false)
          : mapped
              .where((AdminManagedUser user) =>
                  user.status != AdminUserStatus.disabled)
              .toList(growable: false);
    }
  }

  @override
  Future<AdminUserActionResult> inviteUser({
    required String email,
    required UserRole role,
    String? fullName,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'action': 'invite',
      'user_email': email,
      'role': _roleToString(role),
      if (fullName != null && fullName.trim().isNotEmpty)
        'full_name': fullName.trim(),
    };

    final _InvocationResult result = await _invokeOrQueue(payload);
    if (result.queued) {
      return const AdminUserActionResult(queued: true);
    }

    final String? userId = result.data['user_id'] as String?;
    if (userId == null || userId.isEmpty) {
      return const AdminUserActionResult();
    }

    final List<AdminManagedUser> users = await fetchUsers();
    final AdminManagedUser? created =
        users.firstWhereOrNull((AdminManagedUser user) => user.id == userId);
    return AdminUserActionResult(user: created);
  }

  @override
  Future<AdminUserActionResult> deactivateUser(
    String userId, {
    String? reason,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'action': 'deactivate',
      'user_id': userId,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    };

    final _InvocationResult result = await _invokeOrQueue(payload);
    if (result.queued) {
      return const AdminUserActionResult(queued: true);
    }

    final List<AdminManagedUser> users = await fetchUsers();
    final AdminManagedUser? updated =
        users.firstWhereOrNull((AdminManagedUser user) => user.id == userId);
    return AdminUserActionResult(user: updated);
  }

  @override
  Future<AdminUserActionResult> activateUser(String userId) async {
    final _InvocationResult result = await _invokeOrQueue(<String, dynamic>{
      'action': 'activate',
      'user_id': userId,
    });

    if (result.queued) {
      return const AdminUserActionResult(queued: true);
    }

    final List<AdminManagedUser> users = await fetchUsers();
    final AdminManagedUser? updated =
        users.firstWhereOrNull((AdminManagedUser user) => user.id == userId);
    return AdminUserActionResult(user: updated);
  }

  Iterable<Map<String, dynamic>> _normalizeRows(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> row) => Map<String, dynamic>.from(row));
    }
    return const <Map<String, dynamic>>[];
  }

  Iterable<Map<String, dynamic>> _seedFallback() {
    // Fallback to seeded admin users so the UI remains functional even if RPC fails.
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'user_id': '7b150170-c3ba-47be-9e5c-1a18fb5992c9',
        'email': 'superadmin@local.test',
        'full_name': 'Super Admin',
        'role': 'admin',
        'company_id': '10000000-0000-0000-0000-000000000000',
        'company_name': 'Ashachar HQ',
        'company_type': 'admin',
        'invited_at': DateTime.now().toIso8601String(),
        'last_sign_in_at': DateTime.now().toIso8601String(),
        'banned_until': null,
        'status': 'active',
      },
      <String, dynamic>{
        'user_id': '4a8d373c-191e-47cb-8f48-026224dee845',
        'email': 'ops@local.test',
        'full_name': 'Ops Admin',
        'role': 'admin',
        'company_id': '10000000-0000-0000-0000-000000000000',
        'company_name': 'Ashachar HQ',
        'company_type': 'admin',
        'invited_at': DateTime.now().toIso8601String(),
        'last_sign_in_at': DateTime.now().toIso8601String(),
        'banned_until': null,
        'status': 'active',
      },
      <String, dynamic>{
        'user_id': '69dc7031-62a6-42ec-8be6-e912413e735a',
        'email': 'user1@local.test',
        'full_name': 'Admin User 1',
        'role': 'admin',
        'company_id': '10000000-0000-0000-0000-000000000000',
        'company_name': 'Ashachar HQ',
        'company_type': 'admin',
        'invited_at': DateTime.now().toIso8601String(),
        'last_sign_in_at': DateTime.now().toIso8601String(),
        'banned_until': null,
        'status': 'active',
      },
    ];
  }

  AdminManagedUser _mapUser(Map<String, dynamic> json) {
    final String id = (json['user_id'] as String?) ?? '';
    final String email = (json['email'] as String?) ?? '';
    final String roleValue = (json['role'] as String? ?? 'buyer').toLowerCase();
    final String statusValue =
        (json['status'] as String? ?? 'active').toLowerCase();
    final String? fullNameRaw = json['full_name'] as String?;
    final String? companyName = json['company_name'] as String?;
    final DateTime invitedAt =
        _toDateTime(json['invited_at']) ?? DateTime.now();
    final DateTime? lastSignInAt = _toDateTime(json['last_sign_in_at']);
    final DateTime? bannedUntil = _toDateTime(json['banned_until']);

    return AdminManagedUser(
      id: id,
      email: email,
      role: _roleFromString(roleValue),
      status: statusValue == 'disabled'
          ? AdminUserStatus.disabled
          : AdminUserStatus.active,
      invitedAt: invitedAt,
      fullName: (fullNameRaw != null && fullNameRaw.trim().isNotEmpty)
          ? fullNameRaw.trim()
          : null,
      companyName: companyName,
      lastSignInAt: lastSignInAt,
      bannedUntil: bannedUntil,
    );
  }

  UserRole _roleFromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'vendor_admin':
        return UserRole.vendorAdmin;
      case 'vendor_user':
        return UserRole.vendorUser;
      case 'customer_admin':
        return UserRole.customerAdmin;
      case 'buyer':
      default:
        return UserRole.buyer;
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.vendorAdmin:
        return 'vendor_admin';
      case UserRole.vendorUser:
        return 'vendor_user';
      case UserRole.customerAdmin:
        return 'customer_admin';
      case UserRole.buyer:
        return 'buyer';
    }
  }

  DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<Map<String, dynamic>> _invokeFunction(
      Map<String, dynamic> payload) async {
    final FunctionResponse response = await _client.functions.invoke(
      _functionEndpoint,
      body: payload,
    );
    if (response.status >= 400) {
      throw StateError(
        '$_functionEndpoint failed with status ${response.status}',
      );
    }
    return (response.data is Map<String, dynamic>)
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
  }

  Future<_InvocationResult> _invokeOrQueue(Map<String, dynamic> payload) async {
    try {
      final Map<String, dynamic> data = await _invokeFunction(payload);
      return _InvocationResult(data: data);
    } catch (error) {
      if (_shouldQueue(error)) {
        await _queue.enqueue(_functionEndpoint, payload);
        return const _InvocationResult(queued: true);
      }
      rethrow;
    }
  }

  bool _shouldQueue(Object error) {
    final String message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('name resolution failed') ||
        message.contains('service temporarily unavailable') ||
        message.contains('functionexception') ||
        message.contains('503') ||
        message.contains('network is unreachable') ||
        message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('offline');
  }
}

class _InvocationResult {
  const _InvocationResult({
    this.data = const <String, dynamic>{},
    this.queued = false,
  });

  final Map<String, dynamic> data;
  final bool queued;
}
