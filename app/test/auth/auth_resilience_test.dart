import 'package:ashachar_marketplace/src/auth/auth_resilience.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  const String email = 'user@example.com';
  const String password = 'Secret123!';

  late _MockGoTrueClient mockAuth;
  late List<Duration> awaitedDelays;
  late List<String> logMessages;
  late ResilientAuthSignIn retrier;

  setUp(() {
    mockAuth = _MockGoTrueClient();
    awaitedDelays = <Duration>[];
    logMessages = <String>[];
    retrier = ResilientAuthSignIn(
      authClient: mockAuth,
      delayFn: (duration) {
        awaitedDelays.add(duration);
        return Future<void>.value();
      },
      onLog: logMessages.add,
    );
  });

  test('returns response immediately when first attempt succeeds', () async {
    when(() => mockAuth.signInWithPassword(email: email, password: password))
        .thenAnswer((_) async => AuthResponse());

    final AuthResponse result =
        await retrier.signInWithPassword(email: email, password: password);

    expect(result, isA<AuthResponse>());
    verify(() => mockAuth.signInWithPassword(email: email, password: password))
        .called(1);
    verifyNever(() => mockAuth.signOut());
    expect(awaitedDelays, isEmpty);
  });

  test('retries transient auth failures with backoff and succeeds', () async {
    int attempt = 0;
    when(() => mockAuth.signInWithPassword(email: email, password: password))
        .thenAnswer((_) async {
      attempt++;
      if (attempt < 3) {
        throw AuthException('Temporary failure', statusCode: '500');
      }
      return AuthResponse();
    });

    final AuthResponse result =
        await retrier.signInWithPassword(email: email, password: password);

    expect(result, isA<AuthResponse>());
    verify(() => mockAuth.signInWithPassword(email: email, password: password))
        .called(3);
    expect(awaitedDelays.length, 2);
    expect(awaitedDelays.first, const Duration(milliseconds: 200));
    expect(awaitedDelays.last, greaterThan(awaitedDelays.first));
    verifyNever(() => mockAuth.signOut());
  });

  test('signs out and retries once on invalid credentials', () async {
    int attempt = 0;
    when(() => mockAuth.signInWithPassword(email: email, password: password))
        .thenAnswer((_) async {
      attempt++;
      if (attempt == 1) {
        throw AuthException('Invalid login credentials', statusCode: '401');
      }
      return AuthResponse();
    });
    when(() => mockAuth.signOut()).thenAnswer((_) async {});

    final AuthResponse result =
        await retrier.signInWithPassword(email: email, password: password);

    expect(result, isA<AuthResponse>());
    verify(() => mockAuth.signInWithPassword(email: email, password: password))
        .called(2);
    verify(() => mockAuth.signOut()).called(1);
    expect(awaitedDelays, isEmpty);
  });

  test('rethrows when invalid credentials persist after retry', () async {
    when(() => mockAuth.signInWithPassword(email: email, password: password))
        .thenAnswer((_) async {
      throw AuthException('invalid credentials', statusCode: '401');
    });
    when(() => mockAuth.signOut()).thenAnswer((_) async {});

    await expectLater(
      () => retrier.signInWithPassword(email: email, password: password),
      throwsA(isA<AuthException>()),
    );

    verify(() => mockAuth.signInWithPassword(email: email, password: password))
        .called(2);
    verify(() => mockAuth.signOut()).called(1);
    expect(awaitedDelays, isEmpty);
  });

  test('continues retry when signOut throws during invalid recovery', () async {
    int attempt = 0;
    when(() => mockAuth.signInWithPassword(email: email, password: password))
        .thenAnswer((_) async {
      attempt++;
      if (attempt == 1) {
        throw AuthException('invalid credentials', statusCode: '401');
      }
      return AuthResponse();
    });
    when(() => mockAuth.signOut())
        .thenThrow(AuthException('sign out failed', statusCode: '500'));

    final AuthResponse result =
        await retrier.signInWithPassword(email: email, password: password);

    expect(result, isA<AuthResponse>());
    verify(() => mockAuth.signInWithPassword(email: email, password: password))
        .called(2);
    verify(() => mockAuth.signOut()).called(1);
  });

  test('rethrows non-auth errors after max attempts', () async {
    when(() => mockAuth.signInWithPassword(email: email, password: password))
        .thenAnswer((_) async {
      throw StateError('network down');
    });

    await expectLater(
      () => retrier.signInWithPassword(email: email, password: password),
      throwsA(isA<StateError>()),
    );

    verify(() => mockAuth.signInWithPassword(email: email, password: password))
        .called(3);
    expect(awaitedDelays.length, 2);
  });
}
