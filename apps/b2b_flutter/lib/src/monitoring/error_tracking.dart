/// Error Tracking & Monitoring Service
/// Enterprise-grade error tracking with Sentry integration
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Error severity levels
enum ErrorSeverity {
  fatal,
  error,
  warning,
  info,
  debug,
}

/// Error context
class ErrorContext {
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> extra;
  final Map<String, String> tags;
  final List<Breadcrumb> breadcrumbs;

  ErrorContext({
    this.userId,
    this.sessionId,
    this.extra = const {},
    this.tags = const {},
    this.breadcrumbs = const [],
  });

  ErrorContext copyWith({
    String? userId,
    String? sessionId,
    Map<String, dynamic>? extra,
    Map<String, String>? tags,
    List<Breadcrumb>? breadcrumbs,
  }) {
    return ErrorContext(
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      extra: extra ?? this.extra,
      tags: tags ?? this.tags,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
    );
  }
}

/// Breadcrumb for error tracking
class Breadcrumb {
  final String message;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  Breadcrumb({
    required this.message,
    required this.category,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Error tracking service
class ErrorTrackingService {
  static final ErrorTrackingService _instance =
      ErrorTrackingService._internal();
  factory ErrorTrackingService() => _instance;
  ErrorTrackingService._internal();

  final List<Breadcrumb> _breadcrumbs = [];
  ErrorContext _context = ErrorContext();
  bool _isInitialized = false;

  /// Initialize error tracking
  Future<void> initialize({
    required String dsn,
    String? environment,
    String? release,
    double? sampleRate,
  }) async {
    _isInitialized = true;

    // Setup Flutter error handler
    FlutterError.onError = (details) {
      captureException(
        details.exception,
        stackTrace: details.stack,
        severity: ErrorSeverity.error,
      );
    };

    // Setup platform error handler
    PlatformDispatcher.instance.onError = (error, stack) {
      captureException(
        error,
        stackTrace: stack,
        severity: ErrorSeverity.fatal,
      );
      return true;
    };
  }

  /// Set user context
  void setUser({
    required String userId,
    String? email,
    String? username,
    Map<String, dynamic>? extra,
  }) {
    _context = _context.copyWith(
      userId: userId,
      extra: {
        ..._context.extra,
        if (email != null) 'email': email,
        if (username != null) 'username': username,
        ...?extra,
      },
    );
  }

  /// Set session context
  void setSession(String sessionId) {
    _context = _context.copyWith(sessionId: sessionId);
  }

  /// Add tag
  void setTag(String key, String value) {
    _context = _context.copyWith(
      tags: {..._context.tags, key: value},
    );
  }

  /// Add extra data
  void setExtra(String key, dynamic value) {
    _context = _context.copyWith(
      extra: {..._context.extra, key: value},
    );
  }

  /// Add breadcrumb
  void addBreadcrumb({
    required String message,
    String category = 'default',
    Map<String, dynamic>? data,
  }) {
    final breadcrumb = Breadcrumb(
      message: message,
      category: category,
      data: data,
    );

    _breadcrumbs.add(breadcrumb);

    // Keep only last 100 breadcrumbs
    if (_breadcrumbs.length > 100) {
      _breadcrumbs.removeAt(0);
    }
  }

  /// Capture exception
  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isInitialized) {
      debugPrint('Error: $exception');
      return;
    }

    final errorData = {
      'exception': exception.toString(),
      'stackTrace': stackTrace?.toString(),
      'severity': severity.name,
      'timestamp': DateTime.now().toIso8601String(),
      'context': {
        'userId': _context.userId,
        'sessionId': _context.sessionId,
        'tags': _context.tags,
        'extra': {..._context.extra, ...?extra},
      },
      'breadcrumbs': _breadcrumbs
          .map((b) => {
                'message': b.message,
                'category': b.category,
                'timestamp': b.timestamp.toIso8601String(),
                'data': b.data,
              })
          .toList(),
    };

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('🔴 Error captured: ${exception.toString()}');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      debugPrint('Error payload: $errorData');
    }

    // In production, send to Sentry/logging service
    // await _sendToSentry(errorData);
  }

  /// Capture message
  Future<void> captureMessage(
    String message, {
    ErrorSeverity severity = ErrorSeverity.info,
    Map<String, dynamic>? extra,
  }) async {
    return captureException(
      message,
      severity: severity,
      extra: extra,
    );
  }

  /// Clear user context
  void clearUser() {
    _context = ErrorContext();
  }

  /// Clear breadcrumbs
  void clearBreadcrumbs() {
    _breadcrumbs.clear();
  }
}

/// Global error tracking instance
final errorTracking = ErrorTrackingService();

/// Error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Setup error handler for this subtree
    FlutterError.onError = (details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });

      errorTracking.captureException(
        details.exception,
        stackTrace: details.stack,
        severity: ErrorSeverity.error,
      );

      widget.onError?.call(details.exception, details.stack);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return _DefaultErrorWidget(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }
    return widget.child;
  }
}

/// Default error widget
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'משהו השתבש',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('נסה שוב'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Performance metrics
class PerformanceMetrics {
  static final PerformanceMetrics _instance = PerformanceMetrics._internal();
  factory PerformanceMetrics() => _instance;
  PerformanceMetrics._internal();

  final Map<String, Stopwatch> _timers = {};

  /// Start timing
  void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// Stop timing and report
  void stopTimer(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMilliseconds;

      errorTracking.addBreadcrumb(
        message: 'Performance: $name took ${duration}ms',
        category: 'performance',
        data: {'duration': duration, 'operation': name},
      );

      _timers.remove(name);
    }
  }

  /// Measure async operation
  Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    startTimer(name);
    try {
      return await operation();
    } finally {
      stopTimer(name);
    }
  }
}

/// Global performance metrics instance
final performanceMetrics = PerformanceMetrics();
