import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_message.dart';

/// Signature for sending a chat message. Returns true when the message was
/// delivered so the panel can clear its input.
typedef ChatSendCallback = Future<bool> Function(String message);

/// Realtime discussion chat: message bubbles, an empty state and a text input
/// with a character counter. The input is hidden-disabled when [enabled] is
/// false (e.g. outside the discussion phase the panel is not mounted at all).
class ChatPanel extends StatefulWidget {
  const ChatPanel({
    super.key,
    required this.messages,
    required this.myPlayerId,
    required this.onSend,
    this.height = 400,
    this.enabled = true,
  });

  final List<ChatMessage> messages;
  final String myPlayerId;
  final ChatSendCallback onSend;
  final double height;
  final bool enabled;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  bool _tooLong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend =>
      widget.enabled && !_sending && _controller.text.trim().isNotEmpty;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (!widget.enabled || _sending || text.isEmpty) return;

    if (text.length > ChatMessage.maxLength) {
      setState(() => _tooLong = true);
      return;
    }
    setState(() {
      _tooLong = false;
      _sending = true;
    });
    final ok = await widget.onSend(text);
    if (!mounted) return;
    if (ok) _controller.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceHigh),
      ),
      child: Column(
        children: [
          Expanded(
            child: widget.messages.isEmpty
                ? _buildEmptyState(l10n)
                : ListView.builder(
                    key: const ValueKey('chat-list'),
                    reverse: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          widget.messages[widget.messages.length - 1 - index];
                      return _MessageBubble(
                        message: message,
                        isMine: message.playerId == widget.myPlayerId,
                      );
                    },
                  ),
          ),
          _buildInputRow(l10n),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.forum_outlined, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(l10n.chatEmpty, style: AppTypography.bodyBold(context)),
          const SizedBox(height: 4),
          Text(l10n.chatEmptyHint, style: AppTypography.caption(context)),
        ],
      ),
    );
  }

  Widget _buildInputRow(AppLocalizations l10n) {
    final length = _controller.text.length;
    final atLimit = length >= ChatMessage.maxLength;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.surfaceHigh)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('chat-input'),
                  controller: _controller,
                  enabled: widget.enabled && !_sending,
                  textInputAction: TextInputAction.send,
                  style: AppTypography.body(context).copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: l10n.chatInputHint,
                    hintStyle: AppTypography.caption(context),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceHigh.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() => _tooLong = false),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              _buildSendButton(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 6),
            child: Text(
              _tooLong
                  ? l10n.chatMessageTooLong
                  : l10n.chatMessageLength(length, ChatMessage.maxLength),
              textAlign: TextAlign.end,
              style: AppTypography.caption(context).copyWith(
                fontSize: 11,
                color: _tooLong
                    ? AppColors.danger
                    : atLimit
                        ? AppColors.warning
                        : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final enabled = _canSend;
    return GestureDetector(
      key: const ValueKey('chat-send'),
      onTap: enabled ? _send : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.4,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: enabled ? null : AppColors.surfaceHigh,
            shape: BoxShape.circle,
          ),
          child: _sending
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.send, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.violet : AppColors.surfaceHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.playerName,
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(
              message.message,
              style: AppTypography.body(context).copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
