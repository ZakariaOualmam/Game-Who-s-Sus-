import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../game/game_engine.dart';
import '../../models/player.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/player_card.dart';
import 'category_screen.dart';

/// Running scores across rounds, with play-again / home actions.
class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key, required this.engine});

  final GameEngine engine;

  void _playAgain(BuildContext context) {
    engine.resetForNewRound();
    Navigator.of(context).pushReplacement(
      appRoute(CategoryScreen(engine: engine)),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      appRoute(const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...engine.players]
      ..sort((a, b) => b.score.compareTo(a.score));

    return GameScaffold(
      title: 'SCORES',
      onBack: () => _goHome(context),
      canPop: false,
      onPopBlocked: () => _goHome(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          for (var i = 0; i < sorted.length; i++) ...[
            _RankRow(index: i, player: sorted[i]),
            const SizedBox(height: 10),
          ],
        ],
      ),
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameButton(
            label: 'PLAY AGAIN',
            icon: Icons.replay,
            colors: AppColors.crewGradient,
            onPressed: () => _playAgain(context),
          ),
          const SizedBox(height: 12),
          GameButton(
            label: 'HOME',
            colors: const [AppColors.surfaceHigh, AppColors.surfaceHigh],
            onPressed: () => _goHome(context),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.index, required this.player});

  final int index;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            _rankLabel(index),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PlayerCard(player: player, showScore: true),
        ),
      ],
    );
  }

  String _rankLabel(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${index + 1}.';
    }
  }
}
