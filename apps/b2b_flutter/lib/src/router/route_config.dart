import 'package:go_router/go_router.dart';

import 'package:ashachar_marketplace/src/router/guards/auth_guards.dart';

class RouteDefinition {
  RouteDefinition({
    required this.path,
    required this.name,
    this.builder,
    this.redirect,
    this.routes = const <RouteDefinition>[],
    this.guards = const <RouteGuard>[],
  });

  final String path;
  final String name;
  final GoRouterWidgetBuilder? builder;
  final GoRouterRedirect? redirect;
  final List<RouteDefinition> routes;
  final List<RouteGuard> guards;
}

class RouteSnapshot {
  RouteSnapshot({
    required this.path,
    required this.name,
    required this.guards,
  });

  final String path;
  final String name;
  final List<String> guards;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'path': path,
        'name': name,
        'guards': guards,
      };
}
