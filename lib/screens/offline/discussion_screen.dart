import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../game/game_engine.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import 'voting_screen.dart';

/// Verbal discussion phase before voting begins.
class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({super.key, required this.engine});

  final GameEngine engine;

  @override
  Widget build(BuildContext context) {
    final category = engine.category!;
    return GameScaffold(
      title: 'DISCUSS',
      canPop: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Text('🗣️', textAlign: TextAlign.center, style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            'DISCUSS!',
            textAlign: TextAlign.center,
            style: AppTypography.display(context).copyWith(fontSize: 58),
          ),
          const SizedBox(height: 16),
          Text(
            'Figure out who doesn\u2019t know the word',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '${category.emoji}  ${category.name}',
                style: AppTypography.bodyBold(context),
              ),
            ),
          ),
          const SizedBox(height: 56),
          GameButton(
            label: 'START VOTING',
            icon: Icons.how_to_vote,
            onPressed: () => Navigator.of(context).pushReplacement(
              appRoute(VotingScreen(engine: engine)),
            ),
          ),
        ],
      ),
    );
  }
}
