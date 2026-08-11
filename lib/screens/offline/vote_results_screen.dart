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

/// Shows the vote tally and the accused player — or explains a tie.
class VoteResultsScreen extends StatelessWidget {
  const VoteResultsScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    final counts = engine.voteCounts;
    final maxCount = counts.values.fold(0, max);
    final accused = engine.accusedPlayer;
    final isTie = accused == null;

    return GameScaffold(
      title: 'VOTES',
      canPop: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          if (isTie) ...[
            const Text(
              '⚖️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 10),
            Text(
              'IT\u2019S A TIE!',
              textAlign: TextAlign.center,
              style: AppTypography.display(context).copyWith(
                fontSize: 48,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No one gets voted out',
              textAlign: TextAlign.center,
              style: AppTypography.caption(context).copyWith(fontSize: 15),
            ),
          ] else ...[
            Text(
              'Most suspected',
              textAlign: TextAlign.center,
              style: AppTypography.caption(context).copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                accused.name,
                textAlign: TextAlign.center,
                style: AppTypography.display(context)
                    .copyWith(fontSize: 52, color: AppColors.danger),
              ),
            ),
          ],
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
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: factor),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Container(
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
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
