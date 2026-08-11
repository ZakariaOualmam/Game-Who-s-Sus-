import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../offline/offline_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'HOW TO PLAY',
              textAlign: TextAlign.center,
              style: AppTypography.headline(context),
            ),
            const SizedBox(height: 20),
            const _Rule(number: '1', text: 'Everyone gets the same secret word — except the imposter.'),
            const _Rule(number: '2', text: 'Describe the word without ever saying it.'),
            const _Rule(number: '3', text: 'Spot who doesn\u2019t know the word, then vote them out.'),
            const _Rule(number: '4', text: 'The imposter gets one final guess.'),
            const SizedBox(height: 24),
            GameButton(
              label: 'GOT IT',
              height: 52,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text(
            'WORD',
            textAlign: TextAlign.center,
            style: AppTypography.display(context)
                .copyWith(color: AppColors.primary, fontSize: 60),
          ),
          Text(
            'IMPOSTER',
            textAlign: TextAlign.center,
            style: AppTypography.display(context).copyWith(fontSize: 60),
          ),
          const SizedBox(height: 10),
          Text(
            'Find the imposter among your friends',
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
          const SizedBox(height: 48),
          GameButton(
            label: 'OFFLINE',
            icon: Icons.sports_esports,
            colors: AppColors.primaryGradient,
            onPressed: () => Navigator.of(context).push(
              appRoute(const OfflineSetupScreen()),
            ),
          ),
          const SizedBox(height: 16),
          const GameButton(
            label: 'ONLINE  ·  COMING SOON',
            icon: Icons.language,
            colors: [AppColors.surfaceHigh, AppColors.surfaceHigh],
            onPressed: null,
          ),
          const SizedBox(height: 16),
          GameButton(
            label: 'HOW TO PLAY',
            icon: Icons.help_outline,
            colors: const [AppColors.surfaceHigh, AppColors.surfaceHigh],
            onPressed: () => _showHowToPlay(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: AppTypography.body(context)),
          ),
        ],
      ),
    );
  }
}
