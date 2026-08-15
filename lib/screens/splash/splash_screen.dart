import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand_logo.dart';
import '../home/home_screen.dart';

/// Branded splash screen: the WHO'S SUS logo fades and scales in over a
/// midnight-navy backdrop with a soft violet glow before handing off home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _entrance;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _timer = Timer(const Duration(milliseconds: 1600), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(appRoute(const HomeScreen()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entrance.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final logoSize = width < 420 ? width * 0.62 : width < 800 ? 260.0 : 320.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.1,
            colors: [
              AppColors.purpleDeep,
              AppColors.background,
              AppColors.navy,
            ],
            stops: [0, 0.6, 1],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glow disc behind the logo, pulsing gently.
                    SizedBox(
                      width: logoSize * 1.25,
                      height: logoSize * 1.25,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FadeTransition(
                            opacity: Tween<double>(begin: 0.55, end: 1)
                                .animate(
                                  CurvedAnimation(
                                    parent: _glow,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.violet.withValues(alpha: 0.35),
                                    AppColors.violet.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // The logo itself, sitting on top of the glow.
                          FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _entrance,
                              curve: const Interval(0, 0.6, curve: Curves.easeOut),
                            ),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.92, end: 1)
                                  .animate(
                                    CurvedAnimation(
                                      parent: _entrance,
                                      curve: Curves.easeOutBack,
                                    ),
                                  ),
                              child: BrandLogo(size: logoSize),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entrance,
                        curve: const Interval(0.4, 1, curve: Curves.easeOut),
                      ),
                      child: Text(
                        l10n.splashTagline,
                        style: AppTypography.caption(context).copyWith(
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
