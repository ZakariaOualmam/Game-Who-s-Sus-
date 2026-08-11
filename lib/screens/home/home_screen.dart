import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/game_button.dart';
import '../../widgets/game_scaffold.dart';
import '../../widgets/language_selector.dart';
import '../offline/offline_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showHowToPlay(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
              l10n.howToPlayTitle,
              textAlign: TextAlign.center,
              style: AppTypography.headline(context),
            ),
            const SizedBox(height: 20),
            _Rule(number: '1', text: l10n.rule1),
            _Rule(number: '2', text: l10n.rule2),
            _Rule(number: '3', text: l10n.rule3),
            _Rule(number: '4', text: l10n.rule4),
            const SizedBox(height: 24),
            GameButton(
              label: l10n.gotIt,
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
    final l10n = AppLocalizations.of(context);
    return GameScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child: LanguageSelector(),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.appNameWord,
            textAlign: TextAlign.center,
            style: AppTypography.display(context)
                .copyWith(color: AppColors.primary, fontSize: 60),
          ),
          Text(
            l10n.appNameImposter,
            textAlign: TextAlign.center,
            style: AppTypography.display(context).copyWith(fontSize: 60),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.homeTagline,
            textAlign: TextAlign.center,
            style: AppTypography.caption(context),
          ),
          const SizedBox(height: 48),
          GameButton(
            label: l10n.homeOffline,
            icon: Icons.sports_esports,
            colors: AppColors.primaryGradient,
            onPressed: () => Navigator.of(context).push(
              appRoute(const OfflineSetupScreen()),
            ),
          ),
          const SizedBox(height: 16),
          GameButton(
            label: l10n.homeOnlineComingSoon,
            icon: Icons.language,
            colors: const [AppColors.surfaceHigh, AppColors.surfaceHigh],
            onPressed: null,
          ),
          const SizedBox(height: 16),
          GameButton(
            label: l10n.homeHowToPlay,
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
