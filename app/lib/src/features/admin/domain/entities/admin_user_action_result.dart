import 'package:ashachar_marketplace/src/features/admin/domain/entities/admin_managed_user.dart';

class AdminUserActionResult {
  const AdminUserActionResult({
    this.user,
    this.queued = false,
  });

  final AdminManagedUser? user;
  final bool queued;
}
