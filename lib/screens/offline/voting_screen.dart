import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../models/player.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import 'vote_results_screen.dart';

/// Pass-the-phone voting. Each player accuses someone (never themselves).
class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  int _voterIndex = 0;

  GameEngine get engine => widget.engine;
  Player get _voter => engine.players[_voterIndex];

  void _vote(String targetId) {
    engine.castVote(voterId: _voter.id, targetId: targetId);
    setState(() {
      if (engine.allPlayersVoted) {
        Navigator.of(context).pushReplacement(
          appRoute(VoteResultsScreen(engine: engine)),
        );
      } else {
        _voterIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final targets = engine.players.where((p) => p.id != _voter.id).toList();
    final progress = (_voterIndex + 1) / engine.players.length;

    return GameScaffold(
      title: 'VOTING',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Pass the phone to',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            _voter.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(context).copyWith(fontSize: 46),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Who is the imposter?',
            textAlign: TextAlign.center,
            style: AppTypography.title(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Vote in secret',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
          const SizedBox(height: 20),
          for (final player in targets) ...[
            PlayerCard(player: player, onTap: () => _vote(player.id)),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
