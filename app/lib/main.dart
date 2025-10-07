import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/app_bootstrap.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/router/app_router.dart';
import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/widgets/loading_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[AUTH_FLOW] FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrintStack(stackTrace: details.stack, label: '[AUTH_FLOW]');
    }
  };
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[AUTH_FLOW] Uncaught platform error: $error');
    debugPrintStack(stackTrace: stack, label: '[AUTH_FLOW]');
    return true;
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('[AUTH_FLOW] ErrorWidget: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack, label: '[AUTH_FLOW]');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                SizedBox(height: 12),
                Text('משהו השתבש'),
              ],
            ),
          ),
        ),
      ),
    );
  };
  const String initialRoute =
      String.fromEnvironment('INITIAL_ROUTE', defaultValue: '/');
  const String env = String.fromEnvironment('ENV', defaultValue: 'prod');
  debugPrint('[NAV] initial=$initialRoute (ENV=$env)');
  final container = ProviderContainer();
  final Future<void> bootstrapFuture =
      AppBootstrap(container: container).initialize();
  runApp(UncontrolledProviderScope(
    container: container,
    child: _BootstrapApp(bootstrapFuture: bootstrapFuture),
  ));
}

class _BootstrapApp extends StatelessWidget {
  const _BootstrapApp({required this.bootstrapFuture});

  final Future<void> bootstrapFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: bootstrapFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoadingScaffold(),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _BootstrapErrorView(
              error: snapshot.error!,
              stackTrace: snapshot.stackTrace,
            ),
          );
        }
        return const MarketplaceApp();
      },
    );
  }
}

class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AColors.primary),
    );
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AColors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AColors.danger),
                  const SizedBox(height: 16),
                  Text(
                    'שמנו לב לתקלה באתחול',
                    style: ATypography.titleMd,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'בדקו שהשרת המקומי של Supabase פעיל ושפרטי ההתחברות בקובצי ההגדרות תקינים, ואז הפעילו מחדש את האפליקציה.',
                    style: ATypography.bodyMd
                        .copyWith(color: AColors.mutedForeground),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AColors.surfaceSubtle,
                      borderRadius: ARadii.md,
                    ),
                    child: Text(
                      error.toString(),
                      style: ATypography.bodySm,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (stackTrace != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: SingleChildScrollView(
                        child: Text(
                          stackTrace.toString(),
                          style: ATypography.caption,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MarketplaceApp extends ConsumerWidget {
  const MarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: 'א.שחר Marketplace',
      routerConfig: router,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('he'),
        Locale('en'),
      ],
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        MarketplaceLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
