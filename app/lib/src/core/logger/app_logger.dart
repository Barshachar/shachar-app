import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLoggerProvider = Provider<Logger>((ref) {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((event) {
    // ignore: avoid_print
    print('[${event.level.name}] ${event.loggerName}: ${event.message}');
  });
  return Logger('Marketplace');
});
