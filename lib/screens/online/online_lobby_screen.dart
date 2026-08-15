import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/game_time_format.dart';
import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_settings.dart';
import '../../models/room.dart';
import '../../models/room_player.dart';
import '../../services/online_game_service.dart';
import '../../services/room_service.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import '../../models/player.dart' as game_models;
import '../settings/game_settings_screen.dart';
import 'online_game_screen.dart';

/// Online multiplayer lobby showing players and room code.
/// Host can start the game. Players see realtime updates.
class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({
    super.key,
    required this.room,
    required this.currentPlayer,
  });

  final Room room;
  final RoomPlayer currentPlayer;

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  List<RoomPlayer> _players = [];
  late GameSettings _settings = widget.room.settings;
  bool _loading = true;
  RoomSubscription? _subscription;
  String _roomStatus = 'lobby';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _roomStatus = widget.room.status;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _loadPlayers();
    _subscribeToRoomUpdates();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    try {
      final players =
          await RoomService.instance.getPlayersInRoom(widget.room.id);
      if (mounted) {
        setState(() {
          _players = players;
          _loading = false;
        });
      }
    } catch (error) {
      debugPrint('Failed to load players: $error');
      if (mounted) {
        setState(() => _loading = false);
        _showError(AppLocalizations.of(context).onlineFailedLoadPlayers);
      }
    }
  }

  void _subscribeToRoomUpdates() {
    _subscription = RoomService.instance.subscribeToRoom(
      roomId: widget.room.id,
      onPlayerJoined: (player) {
        if (mounted && !_players.any((p) => p.id == player.id)) {
          setState(() => _players.add(player));
        }
      },
      onPlayerLeft: (playerId) {
        if (mounted) {
          setState(() => _players.removeWhere((p) => p.playerId == playerId));

          // If current player was removed (kicked or connection lost)
          if (playerId == widget.currentPlayer.playerId) {
            _showError(AppLocalizations.of(context).onlineDisconnected);
            Navigator.of(context).pop();
          }
        }
      },
      onRoomStatusChanged: (status) {
        if (!mounted) return;

        setState(() => _roomStatus = status);
        if (status == 'playing') {
          Navigator.of(context).pushReplacement(
            appRoute(OnlineGameScreen(
              roomId: widget.room.id,
              currentPlayer: widget.currentPlayer,
            )),
          );
        }
      },
      onSettingsChanged: (settings) {
        if (!mounted) return;
        setState(() => _settings = settings);
      },
      onRoomClosed: () {
        if (!mounted) return;
        _showError(AppLocalizations.of(context).onlineRoomClosed);
        Navigator.of(context).pop();
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: widget.room.code));
    _showError(AppLocalizations.of(context).onlineCodeCopied);
  }

  Future<void> _leaveRoom() async {
    final l10n = AppLocalizations.of(context);
    try {
      await RoomService.instance.leaveRoom(
        roomId: widget.room.id,
        isHost: widget.currentPlayer.isHost,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      debugPrint('Failed to leave room: $error');
      if (!mounted) return;
      _showError(l10n.onlineLeaveFailed(error.toString()));
    }
  }

  Future<void> _startGame() async {
    if (!widget.currentPlayer.isHost) return;
    final l10n = AppLocalizations.of(context);

    if (_roomStatus != 'lobby') {
      _showError(l10n.onlineNotLobby);
      return;
    }

    if (_players.length < GameSettings.minPlayers) {
      _showError(l10n.onlineNeedPlayers);
      return;
    }

    final settings = _settings.forPlayerCount(_players.length);
    final issue = settings.validationIssue(actualPlayerCount: _players.length);
    if (issue == GameSettingsIssue.unsupportedImposterCount) {
      _showError(l10n.settingsImpostersUnsupported);
      return;
    }
    if (issue != null) {
      _showError(l10n.settingsInvalid);
      return;
    }
    if (_players.length != settings.playerCount) {
      _showError(l10n.onlineWaitingForPlayers(_players.length, settings.playerCount));
      return;
    }

    try {
      await OnlineGameService.instance.beginCategoryPhase(widget.room.id);
      if (!mounted) return;
      setState(() => _roomStatus = 'playing');
    } catch (error) {
      debugPrint('Failed to start game: $error');
      if (!mounted) return;
      _showError(l10n.onlineStartFailed(error.toString()));
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      appRoute(GameSettingsScreen.online(
        room: widget.room,
        isHost: widget.currentPlayer.isHost,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHost = widget.currentPlayer.isHost;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _leaveRoom();
        }
      },
      child: GameScaffold(
        title: l10n.lobbyTitle,
        onBack: _leaveRoom,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Room code display
                  GestureDetector(
                    onTap: _copyRoomCode,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.roomCodeLabel,
                            style: AppTypography.caption(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.room.code,
                            style: AppTypography.display(context).copyWith(
                              color: Colors.white,
                              fontSize: 48,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.copy,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                l10n.onlineTapToCopy,
                                style: AppTypography.caption(context).copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Settings summary
                  GestureDetector(
                    onTap: _openSettings,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceHigh,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: AppColors.secondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.settingsTitle,
                                  style: AppTypography.title(context),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_settings.playerCount} ${l10n.settingsPlayers} · '
                                  '${_settings.imposterCount} ${l10n.settingsImposters}',
                                  style: AppTypography.caption(context),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${formatGameDuration(l10n, _settings.discussionTime)} '
                                  '${l10n.settingsDiscussionTime} · '
                                  '${formatGameDuration(l10n, _settings.votingTime)} '
                                  '${l10n.settingsVotingTime}',
                                  style: AppTypography.caption(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Players title
                  Row(
                    children: [
                      Text(
                        l10n.playersLabel,
                        style: AppTypography.title(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_players.length}/${_settings.playerCount}',
                          style: AppTypography.caption(context).copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Players grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      for (final roomPlayer in _players)
                        PlayerCard(
                          player: game_models.Player(
                            id: roomPlayer.playerId,
                            name: roomPlayer.playerName,
                          ),
                          trailing: roomPlayer.isHost
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.hostLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                    ],
                  ),
                ],
              ),
        bottomBar: isHost
            ? GameButton(
                label: _players.length == _settings.playerCount
                    ? l10n.onlineStartGame
                    : l10n.onlineWaitingForPlayers(
                        _players.length,
                        _settings.playerCount,
                      ),
                onPressed: _players.length == _settings.playerCount &&
                        _settings.imposterCount <=
                            GameSettings.supportedImposters
                    ? _startGame
                    : null,
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  l10n.onlineWaitingHost,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(context),
                ),
              ),
      ),
    );
  }
}
