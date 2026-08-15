import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/game_button.dart';
import '../../widgets/language_selector.dart';
import '../offline/offline_setup_screen.dart';
import '../online/online_menu_screen.dart';

/// Landing screen: brand logo, tagline, and the main entry actions.
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
    final width = MediaQuery.sizeOf(context).width;
    final logoSize = width < 420 ? width * 0.5 : width < 800 ? 210.0 : 260.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: LanguageSelector()),
              const SizedBox(height: 16),
              Center(child: BrandLogo(size: logoSize)),
              const SizedBox(height: 20),
              Text(
                l10n.homeTagline,
                style: AppTypography.title(context).copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              GameButton(
                label: l10n.homeOffline,
                icon: Icons.person_pin_circle_outlined,
                onPressed: () {
                  Navigator.of(context)
                      .push(appRoute(const OfflineSetupScreen()));
                },
              ),
              const SizedBox(height: 14),
              GameButton(
                label: l10n.homeOnline,
                icon: Icons.public,
                colors: const [AppColors.secondary, AppColors.accent],
                onPressed: () {
                  Navigator.of(context)
                      .push(appRoute(const OnlineMenuScreen()));
                },
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                icon: const Icon(Icons.menu_book_outlined,
                    size: 20, color: AppColors.textSecondary),
                label: Text(
                  l10n.homeHowToPlay,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () => _showHowToPlay(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: AppColors.primaryGradient),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: AppTypography.body(context)),
            ),
          ),
        ],
      ),
    );
  }
}
