import 'package:flutter/material.dart';

import '../../core/game_time_format.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_settings.dart';
import '../../models/room.dart';
import '../../services/room_service.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';

/// Game settings editor.
///
/// - Online host: edits are saved to the room so every player sees them.
/// - Online non-host: read-only snapshot; the host owns the settings.
/// - Offline: the edited [GameSettings] is returned to the caller on close.
class GameSettingsScreen extends StatefulWidget {
  const GameSettingsScreen.offline({
    super.key,
    required this.initialSettings,
    required this.playerCount,
  })  : room = null,
        isHost = true;

  const GameSettingsScreen.online({
    super.key,
    required this.room,
    required this.isHost,
  })  : initialSettings = null,
        playerCount = 0;

  /// Set for online mode.
  final Room? room;

  /// Whether the current player is the room host (online mode).
  final bool isHost;

  /// Initial settings (offline mode).
  final GameSettings? initialSettings;

  /// Number of players currently added (offline mode).
  final int playerCount;

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  late GameSettings _settings;
  bool _saving = false;

  bool get _isOnline => widget.room != null;

  bool get _editable => _isOnline ? widget.isHost : true;

  /// Number of players shown in the players/imposter sections.
  int get _displayPlayerCount => _isOnline ? _settings.playerCount : widget.playerCount;

  @override
  void initState() {
    super.initState();
    _settings = _isOnline
        ? widget.room!.settings
        : widget.initialSettings!.forPlayerCount(widget.playerCount);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await RoomService.instance.updateGameSettings(
        roomId: widget.room!.id,
        settings: _settings,
      );
      if (!mounted) return;
      _showMessage(l10n.settingsSaved);
      Navigator.of(context).pop();
    } catch (error) {
      debugPrint('Failed to save settings: $error');
      if (!mounted) return;
      _showMessage(l10n.settingsSaveFailed(error.toString()));
      setState(() => _saving = false);
    }
  }

  void _close() {
    Navigator.of(context).pop(_isOnline ? null : _settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GameScaffold(
      title: l10n.settingsTitle,
      onBack: _close,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_editable) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settingsHostControls,
                          style: AppTypography.bodyBold(context),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.settingsHostControlsHelp,
                          style: AppTypography.caption(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _Section(
            title: l10n.settingsPlayers,
            hint: _isOnline ? l10n.settingsPlayersHint : null,
            child: _isOnline
                ? _PlayerCountSelector(
                    current: _settings.playerCount,
                    enabled: _editable,
                    onChanged: (value) =>
                        setState(() => _settings = _settings.copyWith(playerCount: value)),
                  )
                : _OfflinePlayerCount(playerCount: _displayPlayerCount),
          ),
          const SizedBox(height: 16),
          _Section(
            title: l10n.settingsImposters,
            hint: l10n.settingsImpostersHint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ImposterSelector(
                  current: _settings.imposterCount,
                  playerCount: _displayPlayerCount,
                  enabled: _editable,
                  onChanged: (value) =>
                      setState(() => _settings = _settings.copyWith(imposterCount: value)),
                ),
                if (_settings.imposterCount > GameSettings.supportedImposters) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.settingsImpostersUnsupported,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(context)
                        .copyWith(color: AppColors.warning),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: l10n.settingsDiscussionTime,
            child: _DurationSelector(
              options: GameSettings.discussionTimeOptions,
              current: _settings.discussionTime,
              enabled: _editable,
              onChanged: (value) =>
                  setState(() => _settings = _settings.copyWith(discussionTime: value)),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: l10n.settingsVotingTime,
            child: _DurationSelector(
              options: GameSettings.votingTimeOptions,
              current: _settings.votingTime,
              enabled: _editable,
              onChanged: (value) =>
                  setState(() => _settings = _settings.copyWith(votingTime: value)),
            ),
          ),
        ],
      ),
      bottomBar: _isOnline && _editable
          ? GameButton(
              label: l10n.settingsSave,
              loading: _saving,
              onPressed: _saving ? null : _save,
            )
          : GameButton(
              label: l10n.settingsClose,
              colors: const [AppColors.surfaceHigh, AppColors.surfaceHigh],
              onPressed: _close,
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.hint, required this.child});

  final String title;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.title(context)),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint!, style: AppTypography.caption(context)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PlayerCountSelector extends StatelessWidget {
  const _PlayerCountSelector({
    required this.current,
    required this.enabled,
    required this.onChanged,
  });

  final int current;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var count = GameSettings.minPlayers;
            count <= GameSettings.maxPlayers;
            count++)
          _OptionChip(
            label: '$count',
            selected: count == current,
            enabled: enabled,
            onTap: () => onChanged(count),
          ),
      ],
    );
  }
}

class _OfflinePlayerCount extends StatelessWidget {
  const _OfflinePlayerCount({required this.playerCount});

  final int playerCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        const Icon(Icons.people, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.settingsPlayersAdded,
            style: AppTypography.body(context),
          ),
        ),
        Text(
          '$playerCount',
          style: AppTypography.title(context).copyWith(color: AppColors.secondary),
        ),
      ],
    );
  }
}

class _ImposterSelector extends StatelessWidget {
  const _ImposterSelector({
    required this.current,
    required this.playerCount,
    required this.enabled,
    required this.onChanged,
  });

  final int current;
  final int playerCount;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final choices = [
      for (var count = 1; count <= GameSettings.maxImposters; count++) count,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final count in choices)
          _OptionChip(
            label: '$count',
            selected: count == current,
            enabled: enabled && count <= GameSettings.supportedImposters,
            onTap: () => onChanged(count),
          ),
      ],
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.options,
    required this.current,
    required this.enabled,
    required this.onChanged,
  });

  final List<Duration> options;
  final Duration current;
  final bool enabled;
  final ValueChanged<Duration> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          _OptionChip(
            label: formatGameDuration(l10n, option),
            selected: option == current,
            enabled: enabled,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Text(
            label,
            style: AppTypography.bodyBold(context).copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
