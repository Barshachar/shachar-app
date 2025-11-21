import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/router/app_router.dart';
import 'package:ashachar_marketplace/src/router/route_config.dart';
import 'package:ashachar_marketplace/src/router/guards/auth_guards.dart';

void main() {
  test('route map matches snapshot', () {
    final List<Map<String, dynamic>> actual = buildRouteSnapshot()
        .map((RouteSnapshot snapshot) => snapshot.toJson())
        .toList();
    final File snapshotFile = File('test/router/route_map_snapshot.json');
    final List<Map<String, dynamic>> expected =
        (jsonDecode(snapshotFile.readAsStringSync()) as List<dynamic>)
            .map((dynamic value) =>
                Map<String, dynamic>.from(value as Map<dynamic, dynamic>))
            .toList();
    final List<Map<String, dynamic>> stableActual = _canonicalizeRoutes(actual);
    final List<Map<String, dynamic>> stableExpected =
        _canonicalizeRoutes(expected);
    expect(stableActual, stableExpected);
  });

  group('route guards', () {
    test('buyer without session redirected to login', () {
      final ProviderContainer container = _containerWithUser(null);
      addTearDown(container.dispose);
      expect(container.read(_buyerGuardProvider), '/login');
    });

    test('buyer with session passes guards', () {
      final UserProfile user = UserProfile(
        id: 'buyer',
        email: 'buyer@test.local',
        role: UserRole.buyer,
        companyType: CompanyType.customer,
        companyId: 'company-123',
      );
      final ProviderContainer container = _containerWithUser(user);
      addTearDown(container.dispose);
      expect(container.read(_buyerGuardProvider), isNull);
    });

    test('admin guard requires admin role', () {
      final UserProfile admin = UserProfile(
        id: 'admin',
        email: 'admin@test.local',
        role: UserRole.admin,
        companyType: CompanyType.admin,
        companyId: 'hq',
      );
      final ProviderContainer container = _containerWithUser(admin);
      addTearDown(container.dispose);
      expect(container.read(_adminGuardProvider), isNull);
    });
  });
}

final Provider<String?> _buyerGuardProvider = Provider<String?>((ref) {
  return evaluateGuards(ref, <RouteGuard>[
    requireAuthenticated(),
    requireCompany(),
    requireRoles(<UserRole>{UserRole.customerAdmin, UserRole.buyer}),
  ]);
});

final Provider<String?> _adminGuardProvider = Provider<String?>((ref) {
  return evaluateGuards(ref, <RouteGuard>[
    requireAuthenticated(),
    requireRoles(<UserRole>{UserRole.admin}),
  ]);
});

ProviderContainer _containerWithUser(UserProfile? user) {
  return ProviderContainer(
    overrides: [
      userProfileProvider.overrideWithValue(AsyncData<UserProfile?>(user)),
    ],
  );
}

List<Map<String, dynamic>> _canonicalizeRoutes(
    List<Map<String, dynamic>> routes) {
  final List<Map<String, dynamic>> filtered = routes
      .where((Map<String, dynamic> route) => route['dev'] != true)
      .map((Map<String, dynamic> route) => Map<String, dynamic>.from(route))
      .toList();
  filtered.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
    final int byName = (a['name'] as String).compareTo(b['name'] as String);
    if (byName != 0) {
      return byName;
    }
    return (a['path'] as String).compareTo(b['path'] as String);
  });
  return filtered;
}
