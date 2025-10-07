// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      companyType: $enumDecode(_$CompanyTypeEnumMap, json['companyType']),
      companyId: json['companyId'] as String,
      displayName: json['displayName'] as String?,
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'companyType': _$CompanyTypeEnumMap[instance.companyType]!,
      'companyId': instance.companyId,
      'displayName': instance.displayName,
      'locale': instance.locale,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.vendorAdmin: 'vendorAdmin',
  UserRole.vendorUser: 'vendorUser',
  UserRole.customerAdmin: 'customerAdmin',
  UserRole.buyer: 'buyer',
};

const _$CompanyTypeEnumMap = {
  CompanyType.admin: 'admin',
  CompanyType.vendor: 'vendor',
  CompanyType.customer: 'customer',
};
