import 'package:ashachar_marketplace/src/features/pricing/price_resolution_service.dart'
    as price_service;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String _offlineSupabaseUrl = 'https://example.supabase.co';
const String _offlineAnonKey = 'anon-test-key';

bool _supabaseInitializedForTests = false;
typedef _OnErrorCallback = bool Function(Object error, StackTrace stackTrace);

_OnErrorCallback? _previousOnError;
FlutterExceptionHandler? _previousFlutterOnError;
bool _realtimeErrorGuardInstalled = false;

Future<void> ensureSupabaseForTests() async {
  if (_supabaseInitializedForTests) {
    return;
  }

  await Supabase.initialize(
    url: _offlineSupabaseUrl,
    anonKey: _offlineAnonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: false,
      detectSessionInUri: false,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      timeout: Duration(milliseconds: 1),
      logLevel: RealtimeLogLevel.error,
    ),
    debug: false,
  );

  final client = Supabase.instance.client;
  client.auth.stopAutoRefresh();

  final realtime = client.realtime;
  realtime.reconnectAfterMs = (_) => 1 << 30;
  realtime.reconnectTimer.reset();
  await realtime.disconnect();
  realtime.channels.clear();

  _installRealtimeErrorGuard();
  price_service.suppressPriceResolutionLogs = true;

  _supabaseInitializedForTests = true;
}

void _installRealtimeErrorGuard() {
  if (_realtimeErrorGuardInstalled) {
    return;
  }

  final PlatformDispatcher dispatcher = PlatformDispatcher.instance;
  _previousOnError = dispatcher.onError;
  dispatcher.onError = (Object error, StackTrace stackTrace) {
    if (_shouldSwallowWebSocket(error)) {
      return true;
    }
    final _OnErrorCallback? previous = _previousOnError;
    if (previous != null) {
      return previous(error, stackTrace);
    }
    return false;
  };

  _previousFlutterOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (_shouldSwallowWebSocket(details.exception)) {
      return;
    }
    final FlutterExceptionHandler? previous = _previousFlutterOnError;
    if (previous != null) {
      previous(details);
      return;
    }
    FlutterError.presentError(details);
  };

  _realtimeErrorGuardInstalled = true;
}

bool _shouldSwallowWebSocket(Object error) {
  if (error is WebSocketChannelException) {
    final String description = error.toString();
    if (description.contains('WebSocketChannelException') ||
        description.contains('SocketException') ||
        description.contains('Connection refused')) {
      return true;
    }
  }
  return false;
}
