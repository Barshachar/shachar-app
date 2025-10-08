/// Network Retry Policy
/// Enterprise-grade retry logic with exponential backoff
library;

import 'dart:async';
import 'dart:math';

/// Retry policy configuration
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool Function(dynamic error)? shouldRetry;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.shouldRetry,
  });

  static const aggressive = RetryPolicy(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
  );

  static const conservative = RetryPolicy(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 60),
  );

  static const none = RetryPolicy(maxAttempts: 1);
}

/// Execute function with retry policy
Future<T> withRetry<T>({
  required Future<T> Function() action,
  RetryPolicy policy = const RetryPolicy(),
  void Function(int attempt, dynamic error)? onRetry,
}) async {
  int attempt = 0;
  Duration delay = policy.initialDelay;

  while (true) {
    attempt++;

    try {
      return await action();
    } catch (error) {
      if (attempt >= policy.maxAttempts) {
        rethrow;
      }

      if (policy.shouldRetry != null && !policy.shouldRetry!(error)) {
        rethrow;
      }

      onRetry?.call(attempt, error);

      await Future<void>.delayed(delay);

      // Exponential backoff with jitter
      delay = Duration(
        milliseconds: min(
          (delay.inMilliseconds * policy.backoffMultiplier).toInt(),
          policy.maxDelay.inMilliseconds,
        ),
      );

      // Add jitter (±25%)
      final jitter = Random().nextDouble() * 0.5 - 0.25;
      delay = Duration(
        milliseconds: (delay.inMilliseconds * (1 + jitter)).toInt(),
      );
    }
  }
}

/// Debounce utility
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

/// Throttle utility
class Throttler {
  final Duration duration;
  DateTime? _lastCall;

  Throttler({required this.duration});

  void call(void Function() action) {
    final now = DateTime.now();
    if (_lastCall == null || now.difference(_lastCall!) >= duration) {
      _lastCall = now;
      action();
    }
  }
}

/// Network timeout helper
Future<T> withTimeout<T>({
  required Future<T> Function() action,
  Duration timeout = const Duration(seconds: 30),
  FutureOr<T> Function()? onTimeout,
}) async {
  try {
    return await action().timeout(timeout);
  } on TimeoutException {
    if (onTimeout != null) {
      return await onTimeout();
    }
    rethrow;
  }
}

/// Batch processor for API calls
class BatchProcessor<T, R> {
  final Future<R> Function(List<T> items) processor;
  final int batchSize;
  final Duration delay;

  BatchProcessor({
    required this.processor,
    this.batchSize = 50,
    this.delay = const Duration(milliseconds: 100),
  });

  final List<T> _queue = [];
  final List<Completer<R>> _completers = [];
  Timer? _timer;

  Future<R> add(T item) {
    final completer = Completer<R>();
    _queue.add(item);
    _completers.add(completer);

    _timer?.cancel();
    _timer = Timer(delay, _processBatch);

    if (_queue.length >= batchSize) {
      _processBatch();
    }

    return completer.future;
  }

  Future<void> _processBatch() async {
    if (_queue.isEmpty) return;

    final items = List<T>.from(_queue);
    final completers = List<Completer<R>>.from(_completers);

    _queue.clear();
    _completers.clear();

    try {
      final result = await processor(items);
      for (final completer in completers) {
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      }
    } catch (error) {
      for (final completer in completers) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      }
    }
  }
}

/// Circuit breaker pattern
class CircuitBreaker {
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  int _failureCount = 0;
  DateTime? _lastFailureTime;
  bool _isOpen = false;

  CircuitBreaker({
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 30),
    this.resetTimeout = const Duration(seconds: 60),
  });

  Future<T> execute<T>(Future<T> Function() action) async {
    if (_isOpen) {
      if (_shouldAttemptReset()) {
        _isOpen = false;
        _failureCount = 0;
      } else {
        throw CircuitBreakerException('Circuit breaker is open');
      }
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } catch (error) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _isOpen = true;
    }
  }

  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return false;
    return DateTime.now().difference(_lastFailureTime!) >= resetTimeout;
  }

  void reset() {
    _failureCount = 0;
    _isOpen = false;
    _lastFailureTime = null;
  }
}

class CircuitBreakerException implements Exception {
  final String message;
  CircuitBreakerException(this.message);

  @override
  String toString() => message;
}
