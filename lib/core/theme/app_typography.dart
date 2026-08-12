import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../locale_controller.dart';
import 'app_colors.dart';

/// Typography helpers used across the app.
///
/// [context] is accepted so responsive sizes can be derived later if needed.
/// For Arabic and Darija, uses Cairo font for better Arabic typography.
abstract final class AppTypography {
  /// Returns true if the current locale uses Arabic script.
  static bool _isArabicScript(BuildContext context) {
    final locale = LocaleController.instance.locale;
    return locale.languageCode == 'ar' || locale.languageCode == 'ary';
  }

  static TextStyle display(BuildContext context) {
    return _isArabicScript(context)
        ? GoogleFonts.cairo(
            fontSize: 54,
            height: 1.05,
            fontWeight: FontWeight.w700,
          )
        : GoogleFonts.bebasNeue(
            fontSize: 54,
            height: 1.05,
            letterSpacing: 1.5,
          );
  }

  static TextStyle headline(BuildContext context) {
    return _isArabicScript(context)
        ? GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.w700)
        : GoogleFonts.bebasNeue(fontSize: 36, letterSpacing: 1.0);
  }

  static TextStyle word(BuildContext context) {
    return _isArabicScript(context)
        ? GoogleFonts.cairo(fontSize: 44, fontWeight: FontWeight.w800)
        : GoogleFonts.bebasNeue(fontSize: 44, letterSpacing: 0.5);
  }

  static TextStyle title(BuildContext context) {
    return _isArabicScript(context)
        ? GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700)
        : GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w700);
  }

  static TextStyle body(BuildContext context) {
    return _isArabicScript(context)
        ? GoogleFonts.cairo(fontSize: 16)
        : GoogleFonts.quicksand(fontSize: 16);
  }

  static TextStyle bodyBold(BuildContext context) {
    return _isArabicScript(context)
        ? GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700)
        : GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w700);
  }

  static TextStyle caption(BuildContext context) {
    return _isArabicScript(context)
        ? GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          )
        : GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          );
  }
}
