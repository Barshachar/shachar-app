import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ashachar_marketplace/src/app/app_state.dart';
import 'package:ashachar_marketplace/src/app/theme/tokens.dart';
import 'package:ashachar_marketplace/src/auth/auth_models.dart';
import 'package:ashachar_marketplace/src/auth/user_profile_provider.dart';
import 'package:ashachar_marketplace/src/router/guards/auth_guards.dart';
import 'package:ashachar_marketplace/src/router/route_config.dart';
import 'package:ashachar_marketplace/src/router/routes_admin.dart';
import 'package:ashachar_marketplace/src/router/routes_catalog.dart';
import 'package:ashachar_marketplace/src/router/routes_orders.dart';
import 'package:ashachar_marketplace/src/widgets/loading_scaffold.dart';

const String _initialOverride =
    String.fromEnvironment('INITIAL_ROUTE', defaultValue: '/');

final List<RouteDefinition> _shellRoutes = <RouteDefinition>[
  ...buildCatalogRoutes(),
  ...buildOrderRoutes(),
  ...buildAdminRoutes(),
];

final appRouterProvider = Provider<GoRouter>((ref) {
  final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);
  final LoggingNavigatorObserver navObserver = LoggingNavigatorObserver();
  final ProviderSubscription<AsyncValue<UserProfile?>> sub =
      ref.listen<AsyncValue<UserProfile?>>(
    userProfileProvider,
    (_, __) => refreshNotifier.value++,
    fireImmediately: true,
  );
  ref.onDispose(sub.close);
  final GoRouter router = GoRouter(
    initialLocation: _initialOverride,
    refreshListenable: refreshNotifier,
    observers: [navObserver],
    routes: [
      loadingRoute,
      _buildRootRoute(ref),
      ShellRoute(
        builder: (context, state, child) => child,
        routes: _buildShellRoutes(ref),
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(userProfileProvider);
      if (auth.isLoading) {
        return state.uri.toString() == '/loading' ? null : '/loading';
      }
      if (state.matchedLocation == '/loading' && auth.hasValue) {
        return '/';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
  navObserver.attach(router);
  ref.onDispose(() {
    refreshNotifier.dispose();
  });
  return router;
});

GoRoute _buildRootRoute(Ref ref) {
  return GoRoute(
    path: '/',
    name: 'root',
    redirect: (context, state) {
      final UserProfile? user = ref.read(userProfileProvider).asData?.value;
      if (user == null) {
        return '/home';
      }
      switch (user.role) {
        case UserRole.admin:
          return '/admin';
        case UserRole.vendorAdmin:
        case UserRole.vendorUser:
          return '/vendor';
        case UserRole.customerAdmin:
        case UserRole.buyer:
          return '/customer';
      }
    },
  );
}

List<RouteBase> _buildShellRoutes(Ref ref) {
  return _shellRoutes
      .map((RouteDefinition def) => _buildGoRoute(def, ref, const []))
      .toList();
}

GoRoute _buildGoRoute(
  RouteDefinition def,
  Ref ref,
  List<RouteGuard> inherited,
) {
  final List<RouteGuard> combined = <RouteGuard>[
    ...inherited,
    ...def.guards,
  ];
  return GoRoute(
    path: def.path,
    name: def.name,
    builder: def.builder,
    redirect: (context, state) {
      final String? guardRedirect = evaluateGuards(ref, combined);
      if (guardRedirect != null) {
        return guardRedirect;
      }
      return def.redirect?.call(context, state);
    },
    routes: def.routes
        .map((RouteDefinition child) => _buildGoRoute(child, ref, combined))
        .toList(),
  );
}

List<RouteSnapshot> buildRouteSnapshot() {
  final List<RouteSnapshot> snapshots = <RouteSnapshot>[
    RouteSnapshot(path: '/loading', name: 'loading', guards: const []),
    RouteSnapshot(path: '/', name: 'root', guards: const []),
  ];
  _collectSnapshots(_shellRoutes, snapshots, '', const []);
  return snapshots;
}

void _collectSnapshots(
  List<RouteDefinition> routes,
  List<RouteSnapshot> acc,
  String parentPath,
  List<RouteGuard> inherited,
) {
  for (final RouteDefinition def in routes) {
    final List<RouteGuard> combined = <RouteGuard>[
      ...inherited,
      ...def.guards,
    ];
    final String fullPath = _resolvePath(parentPath, def.path);
    acc.add(
      RouteSnapshot(
        path: fullPath,
        name: def.name,
        guards: combined.map((RouteGuard guard) => guard.name).toList(),
      ),
    );
    _collectSnapshots(def.routes, acc, fullPath, combined);
  }
}

String _resolvePath(String parent, String child) {
  if (child.startsWith('/')) {
    return child;
  }
  if (parent.isEmpty || parent == '/') {
    final String normalized =
        child.startsWith('/') ? child.substring(1) : child;
    return '/$normalized';
  }
  return '$parent/${child.replaceAll('//', '/')}';
}

final appThemeProvider = Provider<AppTheme>(
  (ref) => AppTheme(mode: ref.watch(themeModeProvider)),
);

class LoggingNavigatorObserver extends NavigatorObserver {
  GoRouter? _router;

  void attach(GoRouter router) {
    _router = router;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('replace', newRoute, oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('remove', route, previousRoute);
  }

  void _log(
      String event, Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final GoRouter? router = _router;
    if (router == null) {
      return;
    }
    GoRouterState? state;
    try {
      if (router.routerDelegate.currentConfiguration.isNotEmpty) {
        state = router.routerDelegate.state;
      }
    } on Object {
      state = null;
    }
    final Map<String, String> params =
        state?.pathParameters ?? const <String, String>{};
    final String name =
        state?.name ?? state?.fullPath ?? route?.settings.name ?? 'unknown';
    final String location = state?.uri.toString() ?? 'unknown';
    final String previous =
        previousRoute?.settings.name ?? state?.matchedLocation ?? 'none';
    debugPrint(
      '[NAV] event=$event location=$location name=$name params=$params prev=$previous',
    );
  }
}

final loadingRoute = GoRoute(
  path: '/loading',
  name: 'loading',
  builder: (context, state) => const LoadingScaffold(),
);

class AppTheme {
  AppTheme({required ThemeMode mode}) : _mode = mode;

  final ThemeMode _mode;

  ThemeData get lightTheme => _buildTheme(Brightness.light);

  ThemeData get darkTheme => _buildTheme(Brightness.dark);

  ThemeMode get mode => _mode;

  ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = _colorScheme(brightness);
    final TextTheme baseTextTheme = GoogleFonts.spaceGroteskTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(
      bodyColor: isDark ? AColors.foregroundOnDark : AColors.foreground,
      displayColor: isDark ? AColors.foregroundOnDark : AColors.foreground,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AColors.midnight : AColors.background,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: (isDark ? AColors.midnight : AColors.background)
            .withValues(alpha: 0.82),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AColors.foreground,
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AColors.foreground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? AColors.surfaceGlassDark.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.92),
        shadowColor: scheme.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: ARadii.lg,
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : AColors.cardBorder.withValues(alpha: 0.75),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: (isDark ? Colors.white : AColors.surfaceMuted)
            .withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(borderRadius: ARadii.md),
        labelStyle: baseTextTheme.labelMedium?.copyWith(
          color: isDark ? AColors.foregroundOnDark : AColors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.08) : AColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ASpacing.xl,
          vertical: ASpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: ARadii.md,
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : AColors.cardBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ARadii.md,
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : AColors.cardBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ARadii.md,
          borderSide: BorderSide(
            color: scheme.primary,
            width: 1.6,
          ),
        ),
        labelStyle: baseTextTheme.bodyMedium?.copyWith(
          color:
              isDark ? AColors.mutedForegroundOnDark : AColors.mutedForeground,
        ),
      ),
      dividerColor: (isDark ? Colors.white : AColors.borderSubtle)
          .withValues(alpha: 0.32),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: (isDark ? AColors.midnight : AColors.surface)
            .withValues(alpha: 0.9),
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.all(
          baseTextTheme.labelMedium?.copyWith(
            color: isDark ? AColors.foregroundOnDark : AColors.foreground,
            letterSpacing: 0.2,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: ARadii.md),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: ARadii.md),
        iconColor: scheme.primary,
        textColor: isDark ? AColors.foregroundOnDark : AColors.foreground,
      ),
    );
  }

  ColorScheme _colorScheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme base = ColorScheme.fromSeed(
      seedColor: AColors.primary,
      brightness: brightness,
    );
    return base.copyWith(
      primary: AColors.primary,
      onPrimary: Colors.black,
      secondary: AColors.accent,
      onSecondary: Colors.white,
      surface: isDark ? AColors.surfaceGlassDark : AColors.surface,
      surfaceContainerLowest: isDark ? AColors.midnight : AColors.background,
      onSurface: isDark ? AColors.foregroundOnDark : AColors.foreground,
      surfaceTint: AColors.primary,
      outline:
          isDark ? Colors.white.withValues(alpha: 0.2) : AColors.borderStrong,
      primaryContainer: isDark ? const Color(0xFF123B3D) : AColors.primaryLight,
      onPrimaryContainer:
          isDark ? AColors.foregroundOnDark : AColors.foreground,
      secondaryContainer:
          isDark ? const Color(0xFF0F172A) : AColors.surfaceSubtle,
      onSecondaryContainer:
          isDark ? AColors.foregroundOnDark : AColors.foreground,
      tertiary: AColors.accent,
      onTertiary: Colors.white,
      error: AColors.danger,
      onError: Colors.white,
    );
  }
}
