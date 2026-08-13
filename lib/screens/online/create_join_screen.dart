import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your name');
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
      _showError('Failed to create room: $error');
    }
  }

  Future<void> _joinRoom() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (code.length != 6) {
      _showError('Room code must be 6 characters');
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
      _showError('Failed to join room: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.isCreateMode;

    return GameScaffold(
      title: isCreate ? 'CREATE GAME' : 'JOIN GAME',
      onBack: _loading ? null : () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            isCreate ? 'Start a new game' : 'Join an existing game',
            style: AppTypography.title(context),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            enabled: !_loading,
            textCapitalization: TextCapitalization.words,
            maxLength: 18,
            decoration: const InputDecoration(
              counterText: '',
              hintText: 'Your name',
              prefixIcon: Icon(Icons.person, color: AppColors.textMuted),
            ),
          ),
          if (!isCreate) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              enabled: !_loading,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              decoration: const InputDecoration(
                counterText: '',
                hintText: 'Room code (e.g., A3X9K2)',
                prefixIcon: Icon(Icons.tag, color: AppColors.textMuted),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            GameButton(
              label: isCreate ? 'CREATE ROOM' : 'JOIN ROOM',
              icon: isCreate ? Icons.add_circle : Icons.login,
              colors: AppColors.primaryGradient,
              onPressed: isCreate ? _createRoom : _joinRoom,
            ),
          const SizedBox(height: 24),
          if (isCreate)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'You will be the host and get a room code to share with others.',
                textAlign: TextAlign.center,
                style: AppTypography.caption(context),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Enter the 6-character room code from the host.',
                textAlign: TextAlign.center,
                style: AppTypography.caption(context),
              ),
            ),
        ],
      ),
    );
  }
}
