import 'package:equatable/equatable.dart';

import 'package:ashachar_marketplace/src/auth/auth_models.dart';

enum AdminUserStatus { active, disabled }

class AdminManagedUser extends Equatable {
  const AdminManagedUser({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.invitedAt,
    this.fullName,
    this.companyName,
    this.lastSignInAt,
    this.bannedUntil,
  });

  final String id;
  final String email;
  final UserRole role;
  final AdminUserStatus status;
  final DateTime? invitedAt;
  final String? fullName;
  final String? companyName;
  final DateTime? lastSignInAt;
  final DateTime? bannedUntil;

  bool get isDisabled => status == AdminUserStatus.disabled;

  @override
  List<Object?> get props => <Object?>[
        id,
        email,
        role,
        status,
        invitedAt,
        fullName,
        companyName,
        lastSignInAt,
        bannedUntil,
      ];
}
