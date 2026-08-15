import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The official WHO'S SUS logo.
///
/// Renders the full logo as a square image sized to [size]. Falls back to a
/// styled text wordmark if the asset cannot be loaded (e.g. in tests that
/// don't bundle the asset).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 160, this.showWatermark = false});

  /// Square edge length in logical pixels.
  final double size;

  /// When true, renders in a low-opacity style meant to sit behind content
  /// as a subtle background watermark.
  final bool showWatermark;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: showWatermark ? 0.05 : 1.0,
      child: Image.asset(
        'assets/branding/logo/logo_full.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Text(
          "WHO'S SUS",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size / 5,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: showWatermark ? AppColors.textPrimary : AppColors.lavender,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
