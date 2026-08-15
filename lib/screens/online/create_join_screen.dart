import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../services/room_service.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'online_lobby_screen.dart';

/// Screen for creating a new room or joining an existing one.
class CreateJoinScreen extends StatefulWidget {
  const CreateJoinScreen({super.key, required this.isCreateMode});

  final bool isCreateMode;

  @override
  State<CreateJoinScreen> createState() => _CreateJoinScreenState();
}

class _CreateJoinScreenState extends State<CreateJoinScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createRoom() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError(l10n.onlineEnterName);
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await RoomService.instance.createRoom(playerName: name);
      if (!mounted) return;
      
      setState(() => _loading = false);
      Navigator.of(context).pushReplacement(
        appRoute(OnlineLobbyScreen(
          room: result.room,
          currentPlayer: result.hostPlayer,
        )),
      );
    } catch (error) {
      debugPrint('Failed to create room: $error');
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(l10n.onlineCreateFailed(error.toString()));
    }
  }

  Future<void> _joinRoom() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    if (name.isEmpty) {
      _showError(l10n.onlineEnterName);
      return;
    }

    if (code.length != 6) {
      _showError(l10n.onlineRoomCodeLength);
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await RoomService.instance.joinRoom(
        roomCode: code,
        playerName: name,
      );
      if (!mounted) return;

      setState(() => _loading = false);
      Navigator.of(context).pushReplacement(
        appRoute(OnlineLobbyScreen(
          room: result.room,
          currentPlayer: result.player,
        )),
      );
    } catch (error) {
      debugPrint('Failed to join room: $error');
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(l10n.onlineJoinFailed(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.isCreateMode;
    final l10n = AppLocalizations.of(context);

    return GameScaffold(
      title: isCreate ? l10n.onlineCreateGame : l10n.onlineJoinGame,
      onBack: _loading ? null : () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            isCreate ? l10n.onlineStartNewGame : l10n.onlineJoinExistingGame,
            style: AppTypography.title(context),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            enabled: !_loading,
            textCapitalization: TextCapitalization.words,
            maxLength: 18,
            decoration: InputDecoration(
              counterText: '',
              hintText: l10n.onlineYourNameHint,
              prefixIcon: const Icon(Icons.person, color: AppColors.textMuted),
            ),
          ),
          if (!isCreate) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              enabled: !_loading,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: l10n.onlineRoomCodeHint,
                prefixIcon: const Icon(Icons.tag, color: AppColors.textMuted),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            GameButton(
              label: isCreate ? l10n.onlineCreateRoom : l10n.onlineJoinRoom,
              icon: isCreate ? Icons.add_circle : Icons.login,
              colors: AppColors.primaryGradient,
              onPressed: isCreate ? _createRoom : _joinRoom,
            ),
          const SizedBox(height: 24),
          if (isCreate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.onlineCreateRoomHelp,
                textAlign: TextAlign.center,
                style: AppTypography.caption(context),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.onlineJoinRoomHelp,
                textAlign: TextAlign.center,
                style: AppTypography.caption(context),
              ),
            ),
        ],
      ),
    );
  }
}
