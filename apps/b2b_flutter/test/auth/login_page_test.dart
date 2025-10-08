import 'package:ashachar_marketplace/src/auth/login_page.dart';
import 'package:ashachar_marketplace/src/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_harness.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockGoTrueClient mockAuth;
  late AppConfig config;

  setUp(() {
    mockAuth = _MockGoTrueClient();
    config = const AppConfig(
      supabaseUrl: 'https://demo.supabase.co',
      supabaseAnonKey: 'anon-key',
      sentryDsn: '',
      isDebug: true,
      demoEmail: 'demo@example.com',
      demoPassword: 'Demo123!',
    );
  });

  GoRouter buildTestRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin-home',
          builder: (context, state) =>
              const Scaffold(body: Text('Admin Home Screen')),
        ),
        GoRoute(
          path: '/vendor',
          name: 'vendor-home',
          builder: (context, state) =>
              const Scaffold(body: Text('Vendor Home Screen')),
        ),
        GoRoute(
          path: '/customer',
          name: 'customer-home',
          builder: (context, state) => const Scaffold(
            key: ValueKey('customer_home_root'),
            body: SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  group('LoginPage', () {
    testWidgets('navigates to admin home after successful sign in',
        (tester) async {
      final User adminUser = User.fromJson({
        'id': 'user-1',
        'aud': 'authenticated',
        'email': 'admin@example.com',
        'created_at': '2020-01-01T00:00:00Z',
        'app_metadata': {
          'role': 'admin',
          'company_id': 'comp-1',
        },
        'user_metadata': {
          'full_name': 'Admin',
        },
      })!;

      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((invocation) async {
        final String email = invocation.namedArguments[#email] as String;
        final String password = invocation.namedArguments[#password] as String;
        expect(email, 'admin@example.com');
        expect(password, 'Secret123!');
        return AuthResponse(user: adminUser);
      });
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final GoRouter router = buildTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        makeTestApp(
          const LoginPage(),
          router: router,
          overrides: [
            loginAuthClientProvider.overrideWithValue(mockAuth),
            appConfigProvider.overrideWithValue(AsyncValue.data(config)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'admin@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Secret123!',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_btn')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Admin Home Screen'), findsOneWidget);
      verify(() => mockAuth.signInWithPassword(
            email: 'admin@example.com',
            password: 'Secret123!',
          )).called(1);
    });

    testWidgets('uses demo credentials when tapping demo login',
        (tester) async {
      final User buyerUser = User.fromJson({
        'id': 'buyer-1',
        'aud': 'authenticated',
        'email': 'demo@example.com',
        'created_at': '2020-01-01T00:00:00Z',
        'app_metadata': {
          'role': 'buyer',
        },
      })!;

      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((invocation) async {
        final String email = invocation.namedArguments[#email] as String;
        final String password = invocation.namedArguments[#password] as String;
        expect(email, 'demo@example.com');
        expect(password, 'Demo123!');
        return AuthResponse(user: buyerUser);
      });
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final GoRouter router = buildTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        makeTestApp(
          const LoginPage(),
          router: router,
          overrides: [
            loginAuthClientProvider.overrideWithValue(mockAuth),
            appConfigProvider.overrideWithValue(AsyncValue.data(config)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Use demo mode'));
      await tester.pump();
      await tester.pumpAndSettle();

      // חדש: מזהים הגעה ל"בית לקוח" באמצעות Key יציב
      expect(find.byKey(const ValueKey('customer_home_root')), findsOneWidget);
      verify(() => mockAuth.signInWithPassword(
            email: 'demo@example.com',
            password: 'Demo123!',
          )).called(1);
    });

    testWidgets('shows inline error message on invalid credentials',
        (tester) async {
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException('Invalid login', statusCode: '401'));
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final GoRouter router = buildTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        makeTestApp(
          const LoginPage(),
          router: router,
          overrides: [
            loginAuthClientProvider.overrideWithValue(mockAuth),
            appConfigProvider.overrideWithValue(AsyncValue.data(config)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'BadPass1',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      final errorBox = find.byKey(const ValueKey('login_error_inline'));
      expect(errorBox, findsOneWidget);
      expect(
        find.descendant(of: errorBox, matching: find.byType(Text)),
        findsWidgets,
      );
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('shows rate limit error when auth throws 429', (tester) async {
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException('Rate limit', statusCode: '429'));
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final GoRouter router = buildTestRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        makeTestApp(
          const LoginPage(),
          router: router,
          overrides: [
            loginAuthClientProvider.overrideWithValue(mockAuth),
            appConfigProvider.overrideWithValue(AsyncValue.data(config)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'BadPass1',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login_error_inline')), findsOneWidget);
    });
  });
}
