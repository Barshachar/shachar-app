import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

typedef DelayFn = Future<void> Function(Duration duration);

class ResilientAuthSignIn {
  ResilientAuthSignIn({
    required GoTrueClient authClient,
    this.maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 200),
    double backoffMultiplier = 2,
    Duration maxDelay = const Duration(milliseconds: 1200),
    DelayFn? delayFn,
    void Function(String message)? onLog,
  })  : assert(maxAttempts >= 1, 'maxAttempts must be at least 1'),
        _authClient = authClient,
        _initialDelay = initialDelay,
        _backoffMultiplier = backoffMultiplier,
        _maxDelay = maxDelay,
        _delayFn = delayFn ?? _defaultDelay,
        _onLog = onLog;

  final GoTrueClient _authClient;
  final int maxAttempts;
  final Duration _initialDelay;
  final double _backoffMultiplier;
  final Duration _maxDelay;
  final DelayFn _delayFn;
  final void Function(String message)? _onLog;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    Duration currentDelay = _initialDelay;
    Object? lastError;
    StackTrace? lastStackTrace;
    bool invalidRetryUsed = false;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        _log('login=attempt number=$attempt');
        final AuthResponse response = await _authClient.signInWithPassword(
          email: email,
          password: password,
        );
        return response;
      } on AuthException catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;

        final bool invalidCredentials = _isInvalidCredentials(error);
        _log(
          'login=error attempt=$attempt invalid=$invalidCredentials status=${error.statusCode} code=${error.code} message=${error.message}',
        );

        if (invalidCredentials && !invalidRetryUsed) {
          invalidRetryUsed = true;
          await _trySignOut();
          continue;
        }

        if (attempt >= maxAttempts || invalidCredentials) {
          Error.throwWithStackTrace(error, stackTrace);
        }

        await _delayFn(currentDelay);
        currentDelay = _nextDelay(currentDelay);
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;

        _log('login=error attempt=$attempt invalid=false message=$error');

        if (attempt >= maxAttempts) {
          Error.throwWithStackTrace(error, stackTrace);
        }

        await _delayFn(currentDelay);
        currentDelay = _nextDelay(currentDelay);
      }
    }

    if (lastError != null && lastStackTrace != null) {
      Error.throwWithStackTrace(lastError, lastStackTrace);
    }

    throw StateError('Unexpected sign-in failure state');
  }

  Future<void> _trySignOut() async {
    try {
      _log('login=signout_for_invalid');
      await _authClient.signOut();
    } on AuthException catch (error) {
      _log(
        'login=signout_failed status=${error.statusCode} code=${error.code} message=${error.message}',
      );
    } catch (error) {
      _log('login=signout_failed message=$error');
    }
  }

  Duration _nextDelay(Duration current) {
    final double nextDelayMs =
        (current.inMilliseconds * _backoffMultiplier).clamp(
      _initialDelay.inMilliseconds.toDouble(),
      _maxDelay.inMilliseconds.toDouble(),
    );
    return Duration(milliseconds: max(1, nextDelayMs.round()));
  }

  void _log(String message) {
    _onLog?.call(message);
  }

  static Future<void> _defaultDelay(Duration duration) =>
      Future<void>.delayed(duration);

  bool _isInvalidCredentials(AuthException error) {
    final String status = (error.statusCode ?? '').trim();
    final String code = (error.code ?? '').toLowerCase();
    final String message = error.message.toLowerCase();
    return status == '401' ||
        code == 'invalid_login_credentials' ||
        code == 'invalid_credentials' ||
        message.contains('invalid login') ||
        message.contains('invalid email or password') ||
        message.contains('invalid credentials');
  }
}
