/// Session Management Service
/// Enterprise-grade session handling with security features
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Session data model
class Session {
  final String sessionId;
  final String userId;
  final String deviceId;
  final String deviceName;
  final String ipAddress;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final DateTime expiresAt;
  final bool isCurrent;

  Session({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.ipAddress,
    required this.createdAt,
    required this.lastActivityAt,
    required this.expiresAt,
    this.isCurrent = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  Duration get timeSinceLastActivity =>
      DateTime.now().difference(lastActivityAt);

  Session copyWith({
    String? sessionId,
    String? userId,
    String? deviceId,
    String? deviceName,
    String? ipAddress,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    DateTime? expiresAt,
    bool? isCurrent,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      ipAddress: ipAddress ?? this.ipAddress,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'userId': userId,
        'deviceId': deviceId,
        'deviceName': deviceName,
        'ipAddress': ipAddress,
        'createdAt': createdAt.toIso8601String(),
        'lastActivityAt': lastActivityAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isCurrent': isCurrent,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        sessionId: json['sessionId'],
        userId: json['userId'],
        deviceId: json['deviceId'],
        deviceName: json['deviceName'],
        ipAddress: json['ipAddress'],
        createdAt: DateTime.parse(json['createdAt']),
        lastActivityAt: DateTime.parse(json['lastActivityAt']),
        expiresAt: DateTime.parse(json['expiresAt']),
        isCurrent: json['isCurrent'] ?? false,
      );
}

/// Session Manager
class SessionManager extends ChangeNotifier {
  Session? _currentSession;
  final Duration _sessionTimeout = const Duration(hours: 24);
  final Duration _inactivityTimeout = const Duration(minutes: 30);
  Timer? _activityTimer;
  Timer? _refreshTimer;

  Session? get currentSession => _currentSession;
  bool get hasActiveSession =>
      _currentSession != null && !_currentSession!.isExpired;

  /// Initialize session
  Future<void> initializeSession({
    required String sessionId,
    required String userId,
    required String deviceId,
    required String deviceName,
    required String ipAddress,
  }) async {
    final now = DateTime.now();
    _currentSession = Session(
      sessionId: sessionId,
      userId: userId,
      deviceId: deviceId,
      deviceName: deviceName,
      ipAddress: ipAddress,
      createdAt: now,
      lastActivityAt: now,
      expiresAt: now.add(_sessionTimeout),
      isCurrent: true,
    );

    _startActivityMonitoring();
    _startRefreshTimer();
    notifyListeners();
  }

  /// Update last activity
  void updateActivity() {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      lastActivityAt: DateTime.now(),
    );

    _resetActivityTimer();
    notifyListeners();
  }

  /// Refresh session
  Future<void> refreshSession() async {
    if (_currentSession == null) return;

    final now = DateTime.now();
    _currentSession = _currentSession!.copyWith(
      lastActivityAt: now,
      expiresAt: now.add(_sessionTimeout),
    );

    notifyListeners();
  }

  /// End session
  Future<void> endSession() async {
    _activityTimer?.cancel();
    _refreshTimer?.cancel();
    _currentSession = null;
    notifyListeners();
  }

  /// Start activity monitoring
  void _startActivityMonitoring() {
    _activityTimer?.cancel();
    _activityTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkInactivity(),
    );
  }

  /// Check for inactivity timeout
  void _checkInactivity() {
    if (_currentSession == null) return;

    if (_currentSession!.timeSinceLastActivity > _inactivityTimeout) {
      endSession();
    }
  }

  /// Start refresh timer
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    // Refresh 5 minutes before expiry
    final refreshDuration = _sessionTimeout - const Duration(minutes: 5);
    _refreshTimer = Timer(refreshDuration, refreshSession);
  }

  /// Reset activity timer
  void _resetActivityTimer() {
    _startActivityMonitoring();
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Session storage interface
abstract class ISessionStorage {
  Future<void> saveSession(Session session);
  Future<Session?> getSession(String sessionId);
  Future<List<Session>> getUserSessions(String userId);
  Future<void> deleteSession(String sessionId);
  Future<void> deleteAllUserSessions(String userId);
}

/// Device information
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String osVersion;
  final String appVersion;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'platform': platform,
        'osVersion': osVersion,
        'appVersion': appVersion,
      };
}
