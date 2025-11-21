/// Clock contract so tests can control timestamps.
abstract class OTClock {
  DateTime now();
}

/// Default clock that returns `DateTime.now()`.
class SystemOTClock implements OTClock {
  const SystemOTClock();

  @override
  DateTime now() => DateTime.now();
}
