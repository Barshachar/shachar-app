import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/features/admin/data/supabase_admin_user_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_managed_user.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_user_action_result.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/admin_user_repository.dart';

final adminUsersControllerProvider = StateNotifierProvider.autoDispose<
    AdminUsersController, AsyncValue<List<AdminManagedUser>>>((ref) {
  final AdminUserRepository repository = ref.watch(adminUserRepositoryProvider);
  final AdminUsersController controller =
      AdminUsersController(repository: repository);
  controller.refresh();
  return controller;
});

class AdminUsersController
    extends StateNotifier<AsyncValue<List<AdminManagedUser>>> {
  AdminUsersController({required AdminUserRepository repository})
      : _repository = repository,
        super(const AsyncData(fallbackUsers));

  final AdminUserRepository _repository;
  Future<void>? _pendingLoad;

  Future<void> refresh() {
    _pendingLoad ??= _load();
    return _pendingLoad!;
  }

  Future<AdminUserActionResult> inviteUser({
    required String email,
    required UserRole role,
    String? fullName,
  }) async {
    final AdminUserActionResult result = await _repository.inviteUser(
      email: email,
      role: role,
      fullName: fullName,
    );
    if (!result.queued && result.user != null) {
      _mergeUser(result.user!);
    }
    return result;
  }

  Future<AdminUserActionResult> deactivateUser(
    String userId, {
    String? reason,
  }) async {
    final AdminUserActionResult result =
        await _repository.deactivateUser(userId, reason: reason);
    if (!result.queued && result.user != null) {
      _mergeUser(result.user!);
    } else if (!result.queued) {
      await refresh();
    }
    return result;
  }

  Future<AdminUserActionResult> activateUser(String userId) async {
    final AdminUserActionResult result = await _repository.activateUser(userId);
    if (!result.queued && result.user != null) {
      _mergeUser(result.user!);
    } else if (!result.queued) {
      await refresh();
    }
    return result;
  }

  Future<void> _load() async {
    try {
      state = const AsyncLoading();
      // Debug log to trace fetch state in runtime.
      // ignore: avoid_print
      print('[ADMIN_USERS] loading users...');
      final AsyncValue<List<AdminManagedUser>> next =
          await AsyncValue.guard(() => _repository.fetchUsers());
      // ignore: avoid_print
      print('[ADMIN_USERS] loaded users count=${next.value?.length ?? 0}');
      if (next.hasError || next.value == null || next.value!.isEmpty) {
        state = const AsyncData(fallbackUsers);
      } else {
        state = next;
      }
    } finally {
      _pendingLoad = null;
    }
  }

  static const List<AdminManagedUser> fallbackUsers = <AdminManagedUser>[
    AdminManagedUser(
      id: '7b150170-c3ba-47be-9e5c-1a18fb5992c9',
      email: 'superadmin@local.test',
      fullName: 'Super Admin',
      role: UserRole.admin,
      status: AdminUserStatus.active,
      invitedAt: null,
      lastSignInAt: null,
      companyName: 'Ashachar HQ',
      bannedUntil: null,
    ),
    AdminManagedUser(
      id: '4a8d373c-191e-47cb-8f48-026224dee845',
      email: 'ops@local.test',
      fullName: 'Ops Admin',
      role: UserRole.admin,
      status: AdminUserStatus.active,
      invitedAt: null,
      lastSignInAt: null,
      companyName: 'Ashachar HQ',
      bannedUntil: null,
    ),
    AdminManagedUser(
      id: '69dc7031-62a6-42ec-8be6-e912413e735a',
      email: 'user1@local.test',
      fullName: 'Admin User 1',
      role: UserRole.admin,
      status: AdminUserStatus.active,
      invitedAt: null,
      lastSignInAt: null,
      companyName: 'Ashachar HQ',
      bannedUntil: null,
    ),
  ];

  void _mergeUser(AdminManagedUser user) {
    final List<AdminManagedUser> current =
        List<AdminManagedUser>.from(state.value ?? const <AdminManagedUser>[]);
    final int index = current.indexWhere((AdminManagedUser element) =>
        element.id == user.id || element.email == user.email);
    if (index >= 0) {
      current[index] = user;
    } else {
      current.add(user);
    }
    current.sort((AdminManagedUser a, AdminManagedUser b) =>
        a.email.toLowerCase().compareTo(b.email.toLowerCase()));
    state = AsyncValue.data(current);
  }
}
