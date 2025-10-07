import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget makeTestApp(
  Widget child, {
  GoRouter? router,
  Locale locale = const Locale('he'),
  List<Object?> overrides = const [],
  List<LocalizationsDelegate<dynamic>> extraDelegates = const [],
  List<Locale> extraSupportedLocales = const [],
}) {
  final GoRouter effectiveRouter = router ??
      GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            name: 'root',
            builder: (context, state) => child,
          ),
          GoRoute(
            path: '/promotions',
            name: 'promotions',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/checkout',
            name: 'checkout',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );

  final List<Locale> locales = <Locale>{
    const Locale('he'),
    const Locale('en'),
    ...extraSupportedLocales,
  }.toList(growable: false);

  final List<LocalizationsDelegate<dynamic>> delegates = [
    ...extraDelegates,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp.router(
      locale: locale,
      supportedLocales: locales,
      localizationsDelegates: delegates,
      debugShowCheckedModeBanner: false,
      routerConfig: effectiveRouter,
    ),
  );
}
