/// Network availability contract used by schedulers.
abstract class OTNetStatus {
  Future<bool> isOnline();
}

/// Utility implementation that always returns the same value.
class StaticNetStatus implements OTNetStatus {
  const StaticNetStatus(this.online);

  final bool online;

  @override
  Future<bool> isOnline() async => online;
}
