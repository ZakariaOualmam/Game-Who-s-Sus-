import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'brand_logo.dart';

/// Reusable screen shell: dark gradient background, optional header, scrollable
/// body, and pop protection for in-game screens.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.body,
    this.title,
    this.onBack,
    this.bottomBar,
    this.padding = const EdgeInsets.all(24),
    this.canPop = true,
    this.onPopBlocked,
  });

  final Widget body;
  final String? title;
  final VoidCallback? onBack;
  final Widget? bottomBar;
  final EdgeInsets padding;

  /// When false, system back gestures are intercepted.
  final bool canPop;

  /// Invoked when a back attempt is blocked (see [canPop]).
  final VoidCallback? onPopBlocked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) onPopBlocked?.call();
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF181833),
                AppColors.background,
                Color(0xFF0A0A16),
              ],
              stops: [0, 0.5, 1],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (title != null || onBack != null)
                  _Header(title: title, onBack: onBack),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        top: 60,
                        child: BrandLogo(size: 220, showWatermark: true),
                      ),
                      SingleChildScrollView(
                        padding: padding,
                        child: body,
                      ),
                    ],
                  ),
                ),
                if (bottomBar != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: bottomBar,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.title, this.onBack});

  final String? title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: onBack != null
                ? GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: AppTypography.headline(context).copyWith(fontSize: 28),
            ),
          ),
          SizedBox(
            width: 44,
            child: Opacity(
              opacity: 0.85,
              child: Image.asset(
                'assets/branding/logo/logo_icon.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
