/// Rate Limiting Service
/// Prevents abuse by limiting request frequency
library;

import 'dart:async';

/// Rate limit result
class RateLimitResult {
  final bool allowed;
  final int remaining;
  final DateTime resetTime;
  final Duration retryAfter;

  RateLimitResult({
    required this.allowed,
    required this.remaining,
    required this.resetTime,
    required this.retryAfter,
  });
}

/// Rate limit bucket
class RateLimitBucket {
  final int maxRequests;
  final Duration window;
  final List<DateTime> requests = [];

  RateLimitBucket({
    required this.maxRequests,
    required this.window,
  });

  /// Check if request is allowed
  RateLimitResult checkLimit() {
    _cleanOldRequests();

    final now = DateTime.now();
    final allowed = requests.length < maxRequests;

    if (allowed) {
      requests.add(now);
    }

    final resetTime = requests.isEmpty ? now : requests.first.add(window);

    final retryAfter = allowed ? Duration.zero : resetTime.difference(now);

    return RateLimitResult(
      allowed: allowed,
      remaining: maxRequests - requests.length,
      resetTime: resetTime,
      retryAfter: retryAfter,
    );
  }

  /// Remove old requests outside the window
  void _cleanOldRequests() {
    final cutoff = DateTime.now().subtract(window);
    requests.removeWhere((time) => time.isBefore(cutoff));
  }

  /// Reset the bucket
  void reset() {
    requests.clear();
  }
}

/// Rate limiter
class RateLimiter {
  final Map<String, RateLimitBucket> _buckets = {};

  /// Check rate limit for a key
  RateLimitResult checkLimit({
    required String key,
    required int maxRequests,
    required Duration window,
  }) {
    final bucketKey = '$key:$maxRequests:${window.inSeconds}';

    _buckets[bucketKey] ??= RateLimitBucket(
      maxRequests: maxRequests,
      window: window,
    );

    return _buckets[bucketKey]!.checkLimit();
  }

  /// Reset limit for a key
  void reset(String key) {
    _buckets.remove(key);
  }

  /// Clear all limits
  void clear() {
    _buckets.clear();
  }
}

/// Global rate limiter instance
final globalRateLimiter = RateLimiter();

/// Rate limit configurations
class RateLimitConfig {
  static const loginAttempts = RateLimitRule(
    maxRequests: 5,
    window: Duration(minutes: 15),
  );

  static const apiRequests = RateLimitRule(
    maxRequests: 100,
    window: Duration(minutes: 1),
  );

  static const passwordReset = RateLimitRule(
    maxRequests: 3,
    window: Duration(hours: 1),
  );

  static const otpVerification = RateLimitRule(
    maxRequests: 5,
    window: Duration(minutes: 10),
  );

  static const searchQueries = RateLimitRule(
    maxRequests: 50,
    window: Duration(minutes: 1),
  );
}

/// Rate limit rule
class RateLimitRule {
  final int maxRequests;
  final Duration window;

  const RateLimitRule({
    required this.maxRequests,
    required this.window,
  });
}

/// Rate limit middleware
class RateLimitMiddleware {
  final RateLimiter _limiter;

  RateLimitMiddleware(this._limiter);

  /// Check if request is allowed
  Future<RateLimitResult> checkRequest({
    required String identifier,
    required RateLimitRule rule,
  }) async {
    return _limiter.checkLimit(
      key: identifier,
      maxRequests: rule.maxRequests,
      window: rule.window,
    );
  }

  /// Execute function with rate limit
  Future<T> executeWithLimit<T>({
    required String identifier,
    required RateLimitRule rule,
    required Future<T> Function() action,
    Future<T> Function()? onRateLimited,
  }) async {
    final result = await checkRequest(
      identifier: identifier,
      rule: rule,
    );

    if (!result.allowed) {
      if (onRateLimited != null) {
        return onRateLimited();
      }
      throw RateLimitException(
        'Rate limit exceeded. Try again in ${result.retryAfter.inSeconds} seconds.',
        result,
      );
    }

    return action();
  }
}

/// Rate limit exception
class RateLimitException implements Exception {
  final String message;
  final RateLimitResult result;

  RateLimitException(this.message, this.result);

  @override
  String toString() => message;
}

/// IP-based rate limiter
class IPRateLimiter {
  final RateLimiter _limiter = RateLimiter();

  RateLimitResult checkIP({
    required String ipAddress,
    required int maxRequests,
    required Duration window,
  }) {
    return _limiter.checkLimit(
      key: 'ip:$ipAddress',
      maxRequests: maxRequests,
      window: window,
    );
  }
}

/// User-based rate limiter
class UserRateLimiter {
  final RateLimiter _limiter = RateLimiter();

  RateLimitResult checkUser({
    required String userId,
    required String action,
    required int maxRequests,
    required Duration window,
  }) {
    return _limiter.checkLimit(
      key: 'user:$userId:$action',
      maxRequests: maxRequests,
      window: window,
    );
  }
}
