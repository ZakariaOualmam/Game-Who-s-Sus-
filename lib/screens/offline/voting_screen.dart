import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../models/player.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import 'vote_results_screen.dart';

/// Pass-the-phone voting. Each player picks a suspect, then confirms their
/// vote with one tap.
class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  int _voterIndex = 0;
  String? _selectedId;

  GameEngine get engine => widget.engine;
  Player get _voter => engine.players[_voterIndex];

  void _select(String id) {
    HapticFeedback.selectionClick();
    setState(() => _selectedId = id);
  }

  void _cancelSelection() => setState(() => _selectedId = null);

  void _confirm() {
    final targetId = _selectedId!;
    engine.castVote(voterId: _voter.id, targetId: targetId);
    HapticFeedback.lightImpact();

    if (engine.allPlayersVoted) {
      Navigator.of(context).pushReplacement(
        appRoute(VoteResultsScreen(engine: engine)),
      );
      return;
    }
    setState(() {
      _voterIndex++;
      _selectedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final targets = engine.players.where((p) => p.id != _voter.id).toList();
    final selected = _selectedId == null ? null : engine.playerById(_selectedId!);

    return GameScaffold(
      title: 'VOTING',
      canPop: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'Pass the phone to',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _voter.name,
              textAlign: TextAlign.center,
              style: AppTypography.display(context).copyWith(fontSize: 46),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < engine.players.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= _voterIndex
                        ? AppColors.secondary
                        : AppColors.surfaceHigh,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Who is the imposter?',
            textAlign: TextAlign.center,
            style: AppTypography.title(context),
          ),
          const SizedBox(height: 6),
          Text(
            'Vote in secret',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
          const SizedBox(height: 18),
          for (final player in targets) ...[
            PlayerCard(
              player: player,
              selected: player.id == _selectedId,
              onTap: () => _select(player.id),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
      bottomBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: selected == null
            ? Text(
                'Tap a player to vote',
                key: const ValueKey('hint'),
                textAlign: TextAlign.center,
                style: AppTypography.caption(context),
              )
            : Row(
                key: const ValueKey('confirm'),
                children: [
                  TextButton(
                    onPressed: _cancelSelection,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('CHANGE'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GameButton(
                      label: 'VOTE FOR ${selected.name.toUpperCase()}',
                      height: 56,
                      fontSize: 16,
                      onPressed: _confirm,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
