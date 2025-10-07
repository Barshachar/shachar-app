import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:ashachar_marketplace/src/core/logger/app_logger.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final logger = ref.watch(appLoggerProvider);
  return AnalyticsService(logger);
});

class AnalyticsService {
  AnalyticsService(this._logger);

  final Logger _logger;

  Future<void> track(String event, Map<String, dynamic> params) async {
    _logger.info('Event: $event => $params');
    await Sentry.captureMessage('event:$event', level: SentryLevel.info);
  }
}
