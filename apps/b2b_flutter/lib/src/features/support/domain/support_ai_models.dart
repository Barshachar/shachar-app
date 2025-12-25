class SupportAiMessage {
  SupportAiMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class SupportAiReply {
  const SupportAiReply({
    required this.reply,
    this.suggestions = const <String>[],
    this.isOfflineFallback = false,
    this.isError = false,
  });

  final String reply;
  final List<String> suggestions;
  final bool isOfflineFallback;
  final bool isError;

  factory SupportAiReply.fromJson(Map<String, dynamic> json) {
    final List<String> suggestions = <String>[];
    final Object? raw = json['suggestions'];
    if (raw is List) {
      for (final Object? item in raw) {
        if (item is String && item.trim().isNotEmpty) {
          suggestions.add(item.trim());
        }
      }
    }
    return SupportAiReply(
      reply: (json['reply'] as String?) ?? '',
      suggestions: suggestions,
      isOfflineFallback: false,
      isError: false,
    );
  }
}
