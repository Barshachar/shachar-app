import 'package:ashachar_marketplace/src/features/support/domain/support_ai_models.dart';

abstract class SupportAiRepository {
  Future<SupportAiReply> sendMessage({
    required String message,
    List<SupportAiMessage> history = const <SupportAiMessage>[],
  });
}
