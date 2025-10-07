import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/auth/auth_models.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final client = Supabase.instance.client;
  final initial = client.auth.currentUser;
  if (initial != null) {
    yield _mapUser(initial);
  }
  await for (final event in client.auth.onAuthStateChange) {
    final user = event.session?.user;
    if (user == null) {
      yield null;
    } else {
      yield _mapUser(user);
    }
  }
});

UserProfile _mapUser(User user) {
  final metadata = <String, dynamic>{
    ...user.appMetadata,
    if (user.userMetadata != null)
      ...Map<String, dynamic>.from(user.userMetadata!),
  };
  final role = (metadata['role'] as String? ?? 'buyer').toLowerCase();
  final companyTypeString =
      (metadata['company_type'] as String? ?? 'customer').toLowerCase();
  final companyId = metadata['company_id'] as String? ?? '';
  return UserProfile(
    id: user.id,
    email: user.email ?? '',
    role: _mapRole(role),
    companyType: _mapCompanyType(companyTypeString),
    companyId: companyId,
    displayName: user.userMetadata?['full_name'] as String?,
    locale: user.userMetadata?['locale'] as String?,
  );
}

UserRole _mapRole(String role) {
  switch (role) {
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

CompanyType _mapCompanyType(String value) {
  switch (value) {
    case 'admin':
      return CompanyType.admin;
    case 'vendor':
      return CompanyType.vendor;
    case 'customer':
    default:
      return CompanyType.customer;
  }
}
