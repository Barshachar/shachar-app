import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/support/domain/support_ai_models.dart';
import 'package:ashachar_marketplace/src/features/support/domain/support_ai_repository.dart';

final supportAiRepositoryProvider = Provider<SupportAiRepository>((ref) {
  final SupabaseClient client = Supabase.instance.client;
  return SupabaseSupportAiRepository(client: client);
});

class SupabaseSupportAiRepository implements SupportAiRepository {
  SupabaseSupportAiRepository({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  static const String _functionEndpoint = 'support_ai_assistant';

  @override
  Future<SupportAiReply> sendMessage({
    required String message,
    List<SupportAiMessage> history = const <SupportAiMessage>[],
  }) async {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return const SupportAiReply(reply: '');
    }

    final List<Map<String, dynamic>> context = history
        .where((SupportAiMessage message) => message.text.trim().isNotEmpty)
        .take(6)
        .map((SupportAiMessage message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'text': message.text.trim(),
            })
        .toList(growable: false);

    final Map<String, dynamic> payload = <String, dynamic>{
      'message': trimmed,
      'history': context,
    };

    try {
      final FunctionResponse response = await _client.functions.invoke(
        _functionEndpoint,
        body: payload,
      );
      if (response.status >= 400) {
        throw StateError(
          '$_functionEndpoint failed with status ${response.status}',
        );
      }
      final Object? data = response.data;
      if (data is Map) {
        return SupportAiReply.fromJson(Map<String, dynamic>.from(data));
      }
      return const SupportAiReply(reply: '');
    } catch (error) {
      if (_isOfflineError(error)) {
        return const SupportAiReply(
          reply: '',
          suggestions: <String>[
            'How do I track an order?',
            'How do I reorder items?',
            'Where can I find invoices?'
          ],
          isOfflineFallback: true,
        );
      }
      return const SupportAiReply(reply: '', isError: true);
    }
  }

  bool _isOfflineError(Object error) {
    final String message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('name resolution failed') ||
        message.contains('service temporarily unavailable') ||
        message.contains('functionexception') ||
        message.contains('503') ||
        message.contains('network is unreachable') ||
        message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('offline');
  }
}
