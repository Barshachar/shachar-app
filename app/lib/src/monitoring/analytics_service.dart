/// Analytics Service
/// Enterprise-grade analytics and event tracking
library;

import 'dart:async';

/// Analytics event
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    this.parameters,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'parameters': parameters,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// User properties
class UserProperties {
  final String userId;
  final Map<String, dynamic> properties;

  UserProperties({
    required this.userId,
    required this.properties,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'properties': properties,
      };
}

/// Analytics service
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final List<AnalyticsEvent> _eventQueue = [];
  String? _userId;
  final Map<String, dynamic> _userProperties = {};
  bool _isEnabled = true;

  /// Initialize analytics
  Future<void> initialize({
    required String apiKey,
    bool debug = false,
  }) async {
    _isEnabled = true;
    // Initialize analytics SDK here
  }

  /// Set user ID
  void setUserId(String userId) {
    _userId = userId;
  }

  /// Set user properties
  void setUserProperties(Map<String, dynamic> properties) {
    _userProperties.addAll(properties);
  }

  /// Track event
  void trackEvent(String name, {Map<String, dynamic>? parameters}) {
    if (!_isEnabled) return;

    final event = AnalyticsEvent(
      name: name,
      parameters: {
        ...?parameters,
        if (_userId != null) 'user_id': _userId,
      },
    );

    _eventQueue.add(event);
    _flushIfNeeded();
  }

  /// Track screen view
  void trackScreenView(String screenName, {String? screenClass}) {
    trackEvent('screen_view', parameters: {
      'screen_name': screenName,
      if (screenClass != null) 'screen_class': screenClass,
    });
  }

  /// Track user action
  void trackAction(String action, {Map<String, dynamic>? parameters}) {
    trackEvent('user_action', parameters: {
      'action': action,
      ...?parameters,
    });
  }

  /// Track error
  void trackError(String error, {String? stackTrace}) {
    trackEvent('error', parameters: {
      'error_message': error,
      if (stackTrace != null) 'stack_trace': stackTrace,
    });
  }

  /// Track timing
  void trackTiming(String category, int milliseconds, {String? label}) {
    trackEvent('timing', parameters: {
      'category': category,
      'duration_ms': milliseconds,
      if (label != null) 'label': label,
    });
  }

  /// Track conversion
  void trackConversion(String conversionId, {double? value, String? currency}) {
    trackEvent('conversion', parameters: {
      'conversion_id': conversionId,
      if (value != null) 'value': value,
      if (currency != null) 'currency': currency,
    });
  }

  /// Track purchase
  void trackPurchase({
    required String transactionId,
    required double value,
    required String currency,
    List<Map<String, dynamic>>? items,
  }) {
    trackEvent('purchase', parameters: {
      'transaction_id': transactionId,
      'value': value,
      'currency': currency,
      if (items != null) 'items': items,
    });
  }

  /// Track search
  void trackSearch(String searchTerm, {int? resultCount}) {
    trackEvent('search', parameters: {
      'search_term': searchTerm,
      if (resultCount != null) 'result_count': resultCount,
    });
  }

  /// Flush events
  Future<void> flush() async {
    if (_eventQueue.isEmpty) return;

    final events = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();

    // Send events to analytics backend
    await _sendEvents(events);
  }

  void _flushIfNeeded() {
    if (_eventQueue.length >= 10) {
      flush();
    }
  }

  Future<void> _sendEvents(List<AnalyticsEvent> events) async {
    // Implementation depends on analytics provider
    // Could be Firebase, Mixpanel, Amplitude, etc.
  }

  /// Enable/disable analytics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Clear user data (GDPR)
  void clearUserData() {
    _userId = null;
    _userProperties.clear();
    _eventQueue.clear();
  }
}

/// Global analytics instance
final analytics = AnalyticsService();

/// Analytics timer for measuring durations
class AnalyticsTimer {
  final String name;
  final DateTime startTime;

  AnalyticsTimer(this.name) : startTime = DateTime.now();

  void stop({Map<String, dynamic>? parameters}) {
    final duration = DateTime.now().difference(startTime);
    analytics.trackTiming(
      name,
      duration.inMilliseconds,
      label: parameters?['label'],
    );
  }
}

/// Screen tracking mixin
mixin AnalyticsScreenTracking {
  String get screenName;

  void trackScreenView() {
    analytics.trackScreenView(screenName);
  }
}
