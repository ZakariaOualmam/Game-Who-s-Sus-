import 'package:flutter/material.dart';

import '../core/locale_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../l10n/app_localizations.dart';

/// Compact globe button that opens the language picker bottom sheet.
///
/// Uses the shared [LocaleController] so picking a language updates the whole
/// app immediately (RTL included) without restarting or losing game state.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguageSheet(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.language,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
    );
  }
}

void _showLanguageSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = LocaleController.instance.locale;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.language,
              textAlign: TextAlign.center,
              style: AppTypography.headline(context),
            ),
            const SizedBox(height: 16),
            for (final language in LocaleController.languages) ...[
              _LanguageTile(
                language: language,
                selected:
                    language.locale.languageCode == current.languageCode,
                onTap: () {
                  LocaleController.instance.setLocale(language.locale);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                language.nativeName,
                style: AppTypography.bodyBold(context),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
