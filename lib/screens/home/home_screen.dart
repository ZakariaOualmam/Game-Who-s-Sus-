import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../offline/offline_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 44),
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
          const SizedBox(height: 52),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
