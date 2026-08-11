import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../models/player.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'imposter_reveal_screen.dart';

/// Shows the vote tally and the player who received the most accusations.
class VoteResultsScreen extends StatelessWidget {
  const VoteResultsScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    final counts = engine.voteCounts;
    final maxCount = counts.values.fold(0, max);
    final accused = engine.accusedPlayer;

    return GameScaffold(
      title: 'VOTES',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Most suspected',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            accused?.name ?? '…',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(context).copyWith(fontSize: 52),
          ),
          const SizedBox(height: 28),
          for (final player in engine.players) ...[
            _VoteBar(
              player: player,
              count: counts[player.id] ?? 0,
              maxCount: maxCount,
              isAccused: player.id == accused?.id,
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 32),
          GameButton(
            label: 'REVEAL THE IMPOSTER',
            icon: Icons.visibility,
            colors: AppColors.imposterGradient,
            onPressed: () => Navigator.of(context).pushReplacement(
              appRoute(ImposterRevealScreen(engine: engine)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteBar extends StatelessWidget {
  const _VoteBar({
    required this.player,
    required this.count,
    required this.maxCount,
    required this.isAccused,
  });

  final Player player;
  final int count;
  final int maxCount;
  final bool isAccused;

  @override
  Widget build(BuildContext context) {
    final factor = maxCount == 0 ? 0.0 : count / maxCount;
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isAccused
                ? AppTypography.bodyBold(context)
                : AppTypography.body(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: factor,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAccused
                        ? AppColors.imposterGradient
                        : AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}
