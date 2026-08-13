import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/room.dart';
import '../../models/room_player.dart';
import '../../services/online_game_service.dart';
import '../../services/room_service.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import '../../models/player.dart' as game_models;
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
  bool _loading = true;
  RoomSubscription? _subscription;
  String _roomStatus = 'lobby';

  @override
  void initState() {
    super.initState();
    _roomStatus = widget.room.status;
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
      final players = await RoomService.instance.getPlayersInRoom(widget.room.id);
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
        _showError('Failed to load players');
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
            _showError('You have been disconnected from the room');
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
      onRoomClosed: () {
        if (!mounted) return;
        _showError('Room was closed by host');
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
    _showError('Room code copied to clipboard!');
  }

  Future<void> _leaveRoom() async {
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
      _showError('Failed to leave room: $error');
    }
  }

  Future<void> _startGame() async {
    if (!widget.currentPlayer.isHost) return;

    if (_roomStatus != 'lobby') {
      _showError('Room is no longer in lobby state');
      return;
    }

    if (_players.length < 3) {
      _showError('Need at least 3 players to start');
      return;
    }

    try {
      await OnlineGameService.instance.beginCategoryPhase(widget.room.id);
      if (!mounted) return;
      setState(() => _roomStatus = 'playing');
    } catch (error) {
      debugPrint('Failed to start game: $error');
      if (!mounted) return;
      _showError('Failed to start game: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHost = widget.currentPlayer.isHost;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _leaveRoom();
        }
      },
      child: GameScaffold(
        title: 'LOBBY',
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
                            'ROOM CODE',
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
                              const Icon(Icons.copy, color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Tap to copy',
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
                  const SizedBox(height: 24),
                  // Players title
                  Row(
                    children: [
                      Text(
                        'Players',
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
                          '${_players.length}/${widget.room.maxPlayers}',
                          style: AppTypography.caption(context).copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Players grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
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
                                    child: const Text(
                                      'HOST',
                                      style: TextStyle(
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
                  ),
                ],
              ),
        bottomBar: isHost
            ? GameButton(
                label: 'START GAME',
                onPressed: _players.length >= 3 ? _startGame : null,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  'Waiting for host to start the game...',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(context),
                ),
              ),
      ),
    );
  }
}
