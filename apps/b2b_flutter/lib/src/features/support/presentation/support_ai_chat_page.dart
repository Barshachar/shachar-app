import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';
import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/support/data/supabase_support_ai_repository.dart';
import 'package:ashachar_marketplace/src/features/support/domain/support_ai_models.dart';
import 'package:ashachar_marketplace/src/features/support/domain/support_ai_repository.dart';

class SupportAiChatPage extends ConsumerStatefulWidget {
  const SupportAiChatPage({super.key});

  @override
  ConsumerState<SupportAiChatPage> createState() => _SupportAiChatPageState();
}

class _SupportAiChatPageState extends ConsumerState<SupportAiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<SupportAiMessage> _messages = <SupportAiMessage>[];
  List<String> _suggestions = const <String>[];
  bool _isSending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final MarketplaceLocalizations? l10n =
          Localizations.of<MarketplaceLocalizations>(
        context,
        MarketplaceLocalizations,
      );
      final String intro = l10n?.translate('supportAiIntro') ??
          'Hi! I can help with orders, returns, and account questions.';
      _messages.add(SupportAiMessage(text: intro, isUser: false));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String title =
        l10n?.translate('supportAiTitle') ?? 'AI Support Assistant';
    final String subtitle = l10n?.translate('supportAiSubtitle') ??
        'Ask about orders, invoices, or vendor policies.';
    final String hint = l10n?.translate('supportAiHint') ?? 'Ask a question...';
    final String sendLabel = l10n?.translate('supportAiSend') ?? 'Send';
    final String disclaimer = l10n?.translate('supportAiDisclaimer') ??
        'AI answers are best-effort. Verify critical details.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              ASpacing.lg,
              0,
              ASpacing.lg,
              ASpacing.md,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                subtitle,
                style: ATypography.bodySm.copyWith(
                  color: AColors.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(ASpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final SupportAiMessage message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          if (_suggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ASpacing.lg),
              child: Wrap(
                spacing: ASpacing.sm,
                runSpacing: ASpacing.sm,
                children: _suggestions
                    .map(
                      (String suggestion) => ActionChip(
                        label: Text(suggestion),
                        onPressed:
                            _isSending ? null : () => _sendMessage(suggestion),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ASpacing.lg,
              ASpacing.md,
              ASpacing.lg,
              ASpacing.sm,
            ),
            child: Text(
              disclaimer,
              style: ATypography.bodyXs.copyWith(
                color: AColors.mutedForeground,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ASpacing.lg,
                ASpacing.sm,
                ASpacing.lg,
                ASpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('support_ai_input'),
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(_controller.text),
                      decoration: InputDecoration(
                        hintText: hint,
                      ),
                    ),
                  ),
                  const SizedBox(width: ASpacing.sm),
                  ElevatedButton(
                    key: const ValueKey('support_ai_send'),
                    onPressed: _isSending
                        ? null
                        : () => _sendMessage(_controller.text),
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(sendLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _controller.clear();
    setState(() {
      _messages.add(SupportAiMessage(text: trimmed, isUser: true));
      _isSending = true;
      _suggestions = const <String>[];
    });
    _scrollToBottom();

    final SupportAiRepository repository =
        ref.read(supportAiRepositoryProvider);
    final SupportAiReply reply = await repository.sendMessage(
      message: trimmed,
      history: _messages,
    );

    if (!mounted) {
      return;
    }

    final MarketplaceLocalizations? l10n =
        Localizations.of<MarketplaceLocalizations>(
      context,
      MarketplaceLocalizations,
    );
    final String fallbackOffline = l10n
            ?.translate('supportAiOfflineFallback') ??
        'You are offline. I can share general guidance, but account-specific answers need a connection.';
    final String fallbackError = l10n?.translate('supportAiError') ??
        'Could not reach the assistant. Try again.';
    final String responseText = reply.isOfflineFallback
        ? fallbackOffline
        : reply.isError
            ? fallbackError
            : reply.reply.isNotEmpty
                ? reply.reply
                : fallbackError;

    setState(() {
      _messages.add(SupportAiMessage(text: responseText, isUser: false));
      _suggestions = reply.suggestions;
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final SupportAiMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final Alignment alignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final Color background = isUser ? AColors.primary : AColors.neutral100;
    final Color foreground = isUser ? Colors.white : AColors.neutral900;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: ASpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: ASpacing.lg,
          vertical: ASpacing.md,
        ),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: ATypography.bodyMd.copyWith(color: foreground),
        ),
      ),
    );
  }
}
