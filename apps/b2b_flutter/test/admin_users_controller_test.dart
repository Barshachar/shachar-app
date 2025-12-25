import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_managed_user.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_user_action_result.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_users_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdminRepo implements AdminUserRepository {
  _FakeAdminRepo({
    this.users = const <AdminManagedUser>[],
    this.shouldThrow = false,
  });

  final List<AdminManagedUser> users;
  final bool shouldThrow;

  @override
  Future<List<AdminManagedUser>> fetchUsers(
      {bool includeDisabled = true}) async {
    if (shouldThrow) {
      throw Exception('fetch failed');
    }
    return users;
  }

  @override
  Future<AdminUserActionResult> activateUser(String userId) async {
    throw UnimplementedError();
  }

  @override
  Future<AdminUserActionResult> deactivateUser(String userId,
      {String? reason}) async {
    throw UnimplementedError();
  }

  @override
  Future<AdminUserActionResult> inviteUser({
    required String email,
    required UserRole role,
    String? fullName,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  final AdminManagedUser sampleUser = AdminManagedUser(
    id: 'u1',
    email: 'user@example.com',
    role: UserRole.admin,
    status: AdminUserStatus.active,
  );

  test('initial state exposes fallback users', () {
    final controller = AdminUsersController(repository: _FakeAdminRepo());
    expect(controller.state.value, AdminUsersController.fallbackUsers);
  });

  test('refresh with empty result keeps fallback users', () async {
    final controller =
        AdminUsersController(repository: _FakeAdminRepo(users: const []));
    await controller.refresh();
    expect(controller.state.value, AdminUsersController.fallbackUsers);
  });

  test('refresh with data replaces fallback users', () async {
    final controller = AdminUsersController(
        repository: _FakeAdminRepo(users: <AdminManagedUser>[sampleUser]));
    await controller.refresh();
    expect(controller.state.value, contains(sampleUser));
    expect(controller.state.value!.length, 1);
  });

  test('refresh with error uses fallback users', () async {
    final controller =
        AdminUsersController(repository: _FakeAdminRepo(shouldThrow: true));
    await controller.refresh();
    expect(controller.state.value, AdminUsersController.fallbackUsers);
  });
}
