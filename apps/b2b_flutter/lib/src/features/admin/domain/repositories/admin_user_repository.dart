import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_managed_user.dart';
import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_user_action_result.dart';

abstract class AdminUserRepository {
  Future<List<AdminManagedUser>> fetchUsers({bool includeDisabled = true});

  Future<AdminUserActionResult> inviteUser({
    required String email,
    required UserRole role,
    String? fullName,
  });

  Future<AdminUserActionResult> deactivateUser(
    String userId, {
    String? reason,
  });

  Future<AdminUserActionResult> activateUser(String userId);
}
