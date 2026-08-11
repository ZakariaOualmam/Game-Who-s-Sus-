import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(appRoute(const HomeScreen()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎭', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              'WORD',
              style: AppTypography.display(context)
                  .copyWith(color: AppColors.primary, fontSize: 64),
            ),
            Text(
              'IMPOSTER',
              style: AppTypography.display(context).copyWith(fontSize: 64),
            ),
            const SizedBox(height: 10),
            Text('party word game', style: AppTypography.caption(context)),
            const SizedBox(height: 44),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
