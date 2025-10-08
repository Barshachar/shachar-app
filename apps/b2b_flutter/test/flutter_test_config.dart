import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(const <String, Object>{});

  FlutterError.demangleStackTrace = (StackTrace stack) {
    final List<String> lines = stack
        .toString()
        .split('\n')
        .where((String line) => !line
            .startsWith('===== asynchronous gap ==========================='))
        .toList(growable: false);
    return StackTrace.fromString(lines.join('\n'));
  };

  Future<Socket> blockSocket(
    dynamic host,
    int port, {
    dynamic sourceAddress,
    int sourcePort = 0,
    Duration? timeout,
  }) {
    return Future<Socket>.error(
      SocketException('Network disabled for widget tests ($host:$port)'),
    );
  }

  bool shouldSuppress(Object error) {
    if (error is SocketException ||
        error is WebSocketException ||
        error is HandshakeException) {
      return true;
    }
    if (error.runtimeType.toString() == 'WebSocketChannelException') {
      return true;
    }
    if (error is ArgumentError) {
      final Object? message = error.message;
      if (message is String && message.contains('No host specified')) {
        return true;
      }
    }
    return false;
  }

  final Future<void> runFuture = IOOverrides.runZoned<Future<void>>(
    () {
      return runZoned<Future<void>>(
        () async {
          await testMain();
        },
        zoneSpecification: ZoneSpecification(
          handleUncaughtError: (
            Zone self,
            ZoneDelegate parent,
            Zone zone,
            Object error,
            StackTrace stackTrace,
          ) {
            if (shouldSuppress(error)) {
              return;
            }
            parent.handleUncaughtError(zone, error, stackTrace);
          },
        ),
      );
    },
    socketConnect: blockSocket,
    socketStartConnect: (host, int port,
            {dynamic sourceAddress, int sourcePort = 0}) =>
        Future<ConnectionTask<Socket>>.error(
      SocketException('Network disabled for widget tests ($host:$port)'),
    ),
  );

  await runFuture;
}
