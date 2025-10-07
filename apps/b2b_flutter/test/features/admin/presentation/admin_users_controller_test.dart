import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_managed_user.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_user_action_result.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/repositories/admin_user_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/data/supabase_admin_user_repository.dart';
import 'package:ashachar_marketplace/src/features/admin/presentation/admin_users_controller.dart';

void main() {
  group('AdminUsersController', () {
    late _FakeAdminUserRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeAdminUserRepository();
      container = ProviderContainer(
        overrides: [
          adminUserRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads existing users on build', () async {
      final AdminManagedUser existing =
          _user('1', email: 'existing@example.com');
      repository.users = <AdminManagedUser>[existing];

      await container.read(adminUsersControllerProvider.notifier).refresh();
      final AsyncValue<List<AdminManagedUser>> state =
          container.read(adminUsersControllerProvider);

      expect(state.value, <AdminManagedUser>[existing]);
    });

    test('inviteUser merges returned user into state', () async {
      final AdminManagedUser existing = _user('1', email: 'alpha@example.com');
      final AdminManagedUser invited = _user(
        '2',
        email: 'beta@example.com',
        fullName: 'Beta Levi',
        role: UserRole.admin,
      );
      repository.users = <AdminManagedUser>[existing];
      repository.inviteResult = AdminUserActionResult(user: invited);

      await container.read(adminUsersControllerProvider.notifier).refresh();
      final AdminUsersController controller =
          container.read(adminUsersControllerProvider.notifier);

      final AdminUserActionResult result = await controller.inviteUser(
        email: invited.email,
        role: invited.role,
        fullName: invited.fullName,
      );

      expect(result.queued, isFalse);
      final AsyncValue<List<AdminManagedUser>> updated =
          container.read(adminUsersControllerProvider);
      expect(updated.value, isNotNull);
      expect(updated.value, containsAll(<AdminManagedUser>[existing, invited]));
    });

    test('inviteUser leaves state untouched when queued', () async {
      final AdminManagedUser existing = _user('1', email: 'only@example.com');
      repository.users = <AdminManagedUser>[existing];
      repository.inviteResult = const AdminUserActionResult(queued: true);

      await container.read(adminUsersControllerProvider.notifier).refresh();
      final AdminUsersController controller =
          container.read(adminUsersControllerProvider.notifier);

      final AdminUserActionResult result = await controller.inviteUser(
        email: 'queued@example.com',
        role: UserRole.customerAdmin,
      );

      expect(result.queued, isTrue);
      final AsyncValue<List<AdminManagedUser>> updated =
          container.read(adminUsersControllerProvider);
      expect(updated.value, equals(<AdminManagedUser>[existing]));
    });

    test('deactivateUser updates existing entry', () async {
      final AdminManagedUser existing = _user('1', email: 'member@example.com');
      final AdminManagedUser disabled = existing.copyWith(
        status: AdminUserStatus.disabled,
        bannedUntil: DateTime(2099),
      );
      repository.users = <AdminManagedUser>[existing];
      repository.deactivateResult = AdminUserActionResult(user: disabled);

      await container.read(adminUsersControllerProvider.notifier).refresh();
      final AdminUsersController controller =
          container.read(adminUsersControllerProvider.notifier);

      final AdminUserActionResult result =
          await controller.deactivateUser(existing.id);

      expect(result.queued, isFalse);
      final AsyncValue<List<AdminManagedUser>> updated =
          container.read(adminUsersControllerProvider);
      expect(updated.value, isNotNull);
      expect(updated.value!.first.status, equals(AdminUserStatus.disabled));
    });

    test('activateUser restores entry when repository returns updated user',
        () async {
      final AdminManagedUser disabled = _user(
        '1',
        email: 'member@example.com',
        status: AdminUserStatus.disabled,
      );
      final AdminManagedUser active = disabled.copyWith(
        status: AdminUserStatus.active,
        bannedUntil: null,
      );
      repository.users = <AdminManagedUser>[disabled];
      repository.activateResult = AdminUserActionResult(user: active);

      await container.read(adminUsersControllerProvider.notifier).refresh();
      final AdminUsersController controller =
          container.read(adminUsersControllerProvider.notifier);

      final AdminUserActionResult result =
          await controller.activateUser(disabled.id);

      expect(result.queued, isFalse);
      final AsyncValue<List<AdminManagedUser>> updated =
          container.read(adminUsersControllerProvider);
      expect(updated.value, isNotNull);
      expect(updated.value!.single.status, equals(AdminUserStatus.active));
    });
  });
}

class _FakeAdminUserRepository implements AdminUserRepository {
  List<AdminManagedUser> users = <AdminManagedUser>[];
  AdminUserActionResult inviteResult = const AdminUserActionResult();
  AdminUserActionResult deactivateResult = const AdminUserActionResult();
  AdminUserActionResult activateResult = const AdminUserActionResult();

  @override
  Future<List<AdminManagedUser>> fetchUsers(
          {bool includeDisabled = true}) async =>
      List<AdminManagedUser>.from(users);

  @override
  Future<AdminUserActionResult> inviteUser({
    required String email,
    required UserRole role,
    String? fullName,
  }) async {
    return inviteResult;
  }

  @override
  Future<AdminUserActionResult> deactivateUser(
    String userId, {
    String? reason,
  }) async {
    return deactivateResult;
  }

  @override
  Future<AdminUserActionResult> activateUser(String userId) async {
    return activateResult;
  }
}

AdminManagedUser _user(
  String id, {
  required String email,
  String? fullName,
  UserRole role = UserRole.customerAdmin,
  AdminUserStatus status = AdminUserStatus.active,
  DateTime? invitedAt,
  DateTime? lastSignInAt,
  DateTime? bannedUntil,
}) {
  return AdminManagedUser(
    id: id,
    email: email,
    role: role,
    status: status,
    invitedAt: invitedAt ?? DateTime(2024, 1, 1),
    fullName: fullName,
    companyName: 'Admin HQ',
    lastSignInAt: lastSignInAt,
    bannedUntil: bannedUntil,
  );
}

extension on AdminManagedUser {
  AdminManagedUser copyWith({
    AdminUserStatus? status,
    DateTime? bannedUntil,
  }) {
    return AdminManagedUser(
      id: id,
      email: email,
      role: role,
      status: status ?? this.status,
      invitedAt: invitedAt,
      fullName: fullName,
      companyName: companyName,
      lastSignInAt: lastSignInAt,
      bannedUntil: bannedUntil ?? this.bannedUntil,
    );
  }
}
