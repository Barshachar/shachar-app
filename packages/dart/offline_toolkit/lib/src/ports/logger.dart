/// Logger contract used by the offline toolkit.
abstract class OTLogger {
  void debug(String message, [Object? context]);
  void info(String message, [Object? context]);
  void warn(String message, [Object? context]);
  void error(String message, [Object? context]);
}

/// No-op logger used when the host app does not supply one.
class OTNoopLogger implements OTLogger {
  const OTNoopLogger();

  @override
  void debug(String message, [Object? context]) {}

  @override
  void info(String message, [Object? context]) {}

  @override
  void warn(String message, [Object? context]) {}

  @override
  void error(String message, [Object? context]) {}
}
