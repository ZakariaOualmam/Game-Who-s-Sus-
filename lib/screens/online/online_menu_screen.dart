import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../models/online_game_phase.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/room_service.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'create_join_screen.dart';
import 'online_game_screen.dart';
import 'online_lobby_screen.dart';

/// Online multiplayer menu: CREATE GAME or JOIN GAME.
class OnlineMenuScreen extends StatefulWidget {
  const OnlineMenuScreen({super.key});

  @override
  State<OnlineMenuScreen> createState() => _OnlineMenuScreenState();
}

class _OnlineMenuScreenState extends State<OnlineMenuScreen> {
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    _ensureAuthenticated();
  }

  Future<void> _ensureAuthenticated() async {
    final auth = FirebaseAuthService.instance;
    if (auth.isAuthenticated) {
      debugPrint('Already authenticated: ${auth.currentUid}');
      await _resumeActiveSession();
      return;
    }

    setState(() => _authenticating = true);
    try {
      await auth.ensureAnonymousSignIn();
      if (mounted) setState(() => _authenticating = false);
    } catch (error) {
      debugPrint('Authentication failed: $error');
      if (mounted) {
        setState(() => _authenticating = false);
        _showError('Failed to connect. Please try again.');
      }
    }

    await _resumeActiveSession();
  }

  Future<void> _resumeActiveSession() async {
    try {
      final active = await RoomService.instance.findMyActiveRoom();
      if (active == null || !mounted) return;

      final phase = OnlineGamePhase.fromDb(active.room.gamePhase);
      if (phase == OnlineGamePhase.lobby) {
        Navigator.of(context).push(
          appRoute(OnlineLobbyScreen(
            room: active.room,
            currentPlayer: active.player,
          )),
        );
      } else {
        Navigator.of(context).push(
          appRoute(OnlineGameScreen(
            roomId: active.room.id,
            currentPlayer: active.player,
          )),
        );
      }
    } catch (error) {
      debugPrint('No resumable online session: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToCreateJoin(bool isCreate) {
    if (!FirebaseAuthService.instance.isAuthenticated) {
      _showError('Please wait, connecting...');
      return;
    }
    Navigator.of(context).push(
      appRoute(CreateJoinScreen(isCreateMode: isCreate)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GameScaffold(
      title: l10n.homeOnline.toUpperCase(),
      onBack: () => Navigator.of(context).pop(),
      body: _authenticating
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting...'),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Play with friends anywhere!',
                  textAlign: TextAlign.center,
                  style: AppTypography.title(context),
                ),
                const SizedBox(height: 48),
                GameButton(
                  label: 'CREATE GAME',
                  icon: Icons.add_circle_outline,
                  colors: AppColors.primaryGradient,
                  onPressed: () => _navigateToCreateJoin(true),
                ),
                const SizedBox(height: 16),
                GameButton(
                  label: 'JOIN GAME',
                  icon: Icons.login,
                  colors: const [AppColors.surfaceHigh, AppColors.surfaceHigh],
                  onPressed: () => _navigateToCreateJoin(false),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Create a room and share the code, or join an existing room with a 6-character code.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(context),
                  ),
                ),
              ],
            ),
    );
  }
}
