import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

enum UserRole {
  admin,
  vendorAdmin,
  vendorUser,
  customerAdmin,
  buyer,
}

enum CompanyType { admin, vendor, customer }

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required UserRole role,
    required CompanyType companyType,
    required String companyId,
    String? displayName,
    String? locale,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
