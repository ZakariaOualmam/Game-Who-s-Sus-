import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/haptics.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../voice/voice_participant.dart';

/// Voice chat UI for the discussion phase.
///
/// Shows the connection status, each player's voice state (speaking / muted /
/// connecting / reconnecting / offline) and a push-to-talk button. All state is
/// passed in from [VoiceChatService] via the screen; this widget never talks
/// to a realtime SDK.
class VoicePanel extends StatelessWidget {
  const VoicePanel({
    super.key,
    required this.participants,
    required this.state,
    required this.failure,
    required this.micEnabled,
    required this.myPlayerId,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onRetry,
    required this.onAllowMicrophone,
    required this.onContinueWithoutVoice,
  });

  /// One entry per room player, already merged by the screen.
  final List<VoiceParticipant> participants;
  final VoiceConnectionState state;
  final VoiceFailure? failure;
  final bool micEnabled;
  final String myPlayerId;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;
  final VoidCallback onRetry;
  final VoidCallback onAllowMicrophone;
  final VoidCallback onContinueWithoutVoice;

  bool get _showMicRecovery =>
      state == VoiceConnectionState.connected &&
      (failure == VoiceFailure.permissionDenied ||
          failure == VoiceFailure.microphoneUnavailable);

  @override
  Widget build(BuildContext context) {
    if (state == VoiceConnectionState.disabled) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final statusText = _statusText(l10n);

    return Container(
      key: const ValueKey('voice-panel'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.voiceTitle,
                  style: AppTypography.title(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (statusText != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: _StatusChip(label: statusText, color: _statusColor()),
                ),
              ],
            ],
          ),
          if (_showActions) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _actionButtons(l10n),
            ),
          ],
          if (_showMicRecovery) ...[
            const SizedBox(height: 10),
            _PillButton(
              label: l10n.voiceAllowMicrophone,
              onTap: onAllowMicrophone,
              colors: AppColors.primaryGradient,
            ),
          ],
          if (participants.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: ListView.separated(
                key: const ValueKey('voice-participants'),
                itemCount: participants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return _VoiceParticipantRow(
                    participant: participant,
                    isSelf: participant.playerId == myPlayerId,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          _HoldToTalkButton(
            enabled: state == VoiceConnectionState.connected,
            active: micEnabled,
            onHoldStart: onHoldStart,
            onHoldEnd: onHoldEnd,
          ),
        ],
      ),
    );
  }

  bool get _showActions =>
      state == VoiceConnectionState.permissionDenied ||
      state == VoiceConnectionState.failed ||
      state == VoiceConnectionState.disconnected;

  List<Widget> _actionButtons(AppLocalizations l10n) {
    return switch (state) {
      VoiceConnectionState.permissionDenied => [
          _PillButton(
            label: l10n.voiceAllowMicrophone,
            onTap: onAllowMicrophone,
            colors: AppColors.primaryGradient,
          ),
          _PillButton(
            label: l10n.voiceContinueWithoutVoice,
            onTap: onContinueWithoutVoice,
          ),
        ],
      VoiceConnectionState.failed ||
      VoiceConnectionState.disconnected => [
          _PillButton(
            label: l10n.voiceRetry,
            onTap: onRetry,
            colors: AppColors.primaryGradient,
          ),
          _PillButton(
            label: l10n.voiceContinueWithoutVoice,
            onTap: onContinueWithoutVoice,
          ),
        ],
      _ => const [],
    };
  }

  String? _statusText(AppLocalizations l10n) {
    return switch (state) {
      VoiceConnectionState.joining => l10n.voiceConnecting,
      VoiceConnectionState.reconnecting => l10n.voiceReconnecting,
      VoiceConnectionState.disconnected => l10n.voiceDisconnected,
      VoiceConnectionState.permissionDenied => l10n.voicePermissionRequired,
      VoiceConnectionState.failed => switch (failure) {
          VoiceFailure.notConfigured => l10n.voiceNotConfigured,
          VoiceFailure.microphoneUnavailable => l10n.voiceMicUnavailable,
          VoiceFailure.permissionDenied => l10n.voicePermissionRequired,
          VoiceFailure.connectionFailed || null => l10n.voiceConnectionFailed,
        },
      VoiceConnectionState.connected => switch (failure) {
          VoiceFailure.permissionDenied => l10n.voicePermissionRequired,
          VoiceFailure.microphoneUnavailable => l10n.voiceMicUnavailable,
          VoiceFailure.connectionFailed || VoiceFailure.notConfigured || null =>
            null,
        },
      VoiceConnectionState.disabled => null,
    };
  }

  Color _statusColor() {
    return switch (state) {
      VoiceConnectionState.connected =>
        failure == null ? AppColors.success : AppColors.warning,
      VoiceConnectionState.permissionDenied => AppColors.warning,
      VoiceConnectionState.reconnecting => AppColors.warning,
      VoiceConnectionState.failed => AppColors.danger,
      VoiceConnectionState.disconnected => AppColors.danger,
      VoiceConnectionState.joining => AppColors.secondary,
      VoiceConnectionState.disabled => AppColors.textMuted,
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption(context).copyWith(color: color),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.colors = const [AppColors.surfaceHigh, AppColors.surfaceHigh],
  });

  final String label;
  final VoidCallback onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: colors.length > 1 && colors[0] != colors[1]
              ? LinearGradient(colors: colors)
              : null,
          color: colors[0] == colors[1] ? colors[0] : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceHigh),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.caption(context).copyWith(
            color: colors == [AppColors.surfaceHigh, AppColors.surfaceHigh]
                ? AppColors.textPrimary
                : Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _VoiceParticipantRow extends StatelessWidget {
  const _VoiceParticipantRow({required this.participant, required this.isSelf});

  final VoiceParticipant participant;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color, icon) = _statusInfo(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelf ? AppColors.surfaceHigh : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelf
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.surfaceHigh,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.purpleDeep,
            child: Text(
              participant.name.isEmpty
                  ? '?'
                  : participant.name.characters.first.toUpperCase(),
              style: AppTypography.caption(context).copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              participant.name,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyBold(context).copyWith(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.caption(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData?) _statusInfo(AppLocalizations l10n) {
    return switch (participant.state) {
      VoiceParticipantState.speaking => (
          l10n.voiceSpeaking,
          AppColors.success,
          Icons.graphic_eq,
        ),
      VoiceParticipantState.muted => (l10n.voiceMuted, AppColors.textMuted, null),
      VoiceParticipantState.connecting => (
          l10n.voiceConnecting,
          AppColors.secondary,
          null,
        ),
      VoiceParticipantState.reconnecting => (
          l10n.voiceReconnecting,
          AppColors.warning,
          Icons.refresh,
        ),
      VoiceParticipantState.disconnected => (
          l10n.voiceNotConnected,
          AppColors.textMuted,
          Icons.mic_off,
        ),
    };
  }
}

class _HoldToTalkButton extends StatefulWidget {
  const _HoldToTalkButton({
    required this.enabled,
    required this.active,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final bool enabled;
  final bool active;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  State<_HoldToTalkButton> createState() => _HoldToTalkButtonState();
}

class _HoldToTalkButtonState extends State<_HoldToTalkButton> {
  bool _spaceHeld = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event.logicalKey != LogicalKeyboardKey.space) return false;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (_spaceHeld) return false;
      if (!widget.enabled) return false;
      if (_isTextInputFocused()) return false;
      _spaceHeld = true;
      _start();
      return true;
    }

    if (event is KeyUpEvent) {
      if (!_spaceHeld) return false;
      _spaceHeld = false;
      _stop();
      return true;
    }

    return false;
  }

  /// Returns true when a text field currently owns primary focus, so the
  /// SPACE key must not activate push-to-talk.
  static bool _isTextInputFocused() {
    final focused = FocusManager.instance.primaryFocus;
    if (focused?.context == null) return false;
    var found = false;
    focused!.context!.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  void _start() {
    Haptics.lightImpact();
    widget.onHoldStart();
  }

  void _stop() => widget.onHoldEnd();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = widget.active;
    final enabled = widget.enabled;
    final color = !enabled
        ? AppColors.textMuted
        : active
            ? Colors.white
            : AppColors.primary;

    return Semantics(
      button: true,
      label: l10n.voiceHoldToTalk,
      toggled: active,
      hint: active ? l10n.voiceReleaseToStop : null,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled ? (_) => _start() : null,
        onPointerUp: enabled ? (_) => _stop() : null,
        onPointerCancel: enabled ? (_) => _stop() : null,
        child: AnimatedContainer(
          key: const ValueKey('hold-to-talk'),
          duration: const Duration(milliseconds: 120),
          height: 64,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: AppColors.primaryGradient)
                : null,
            color: active ? null : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: enabled
                  ? active
                      ? Colors.transparent
                      : AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.surfaceHigh,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (active)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    )
                  else ...[
                    Icon(
                      Icons.mic_none,
                      color: color,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        active ? l10n.voiceTalking : l10n.voiceHoldToTalk,
                        style: AppTypography.title(context).copyWith(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
