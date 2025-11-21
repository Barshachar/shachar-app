import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';

typedef GuardEvaluator = String? Function(Ref ref);

class RouteGuard {
  RouteGuard(this.name, this._evaluate);

  final String name;
  final GuardEvaluator _evaluate;

  String? evaluate(Ref ref) => _evaluate(ref);
}

String? evaluateGuards(Ref ref, List<RouteGuard> guards) {
  for (final RouteGuard guard in guards) {
    final String? redirect = guard.evaluate(ref);
    if (redirect != null) {
      return redirect;
    }
  }
  return null;
}

RouteGuard requireAuthenticated({String redirect = '/login'}) {
  return RouteGuard('auth', (ref) {
    final AsyncValue<UserProfile?> profile = ref.read(userProfileProvider);
    if (profile.isLoading) {
      return '/loading';
    }
    final UserProfile? user = profile.asData?.value;
    if (user == null) {
      return redirect;
    }
    return null;
  });
}

RouteGuard requireRoles(Set<UserRole> roles, {String redirect = '/'}) {
  final String name =
      'roles:${roles.map((UserRole role) => role.name).join(',')}';
  return RouteGuard(name, (ref) {
    final AsyncValue<UserProfile?> profile = ref.read(userProfileProvider);
    final UserProfile? user = profile.asData?.value;
    if (user == null) {
      return redirect;
    }
    if (!roles.contains(user.role)) {
      return redirect;
    }
    return null;
  });
}

RouteGuard requireCompany({String redirect = '/login'}) {
  return RouteGuard('company', (ref) {
    final AsyncValue<UserProfile?> profile = ref.read(userProfileProvider);
    final UserProfile? user = profile.asData?.value;
    if (user == null || user.companyId.isEmpty) {
      return redirect;
    }
    return null;
  });
}
