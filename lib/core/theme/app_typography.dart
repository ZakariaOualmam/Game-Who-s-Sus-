import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography helpers used across the app.
///
/// [context] is accepted so responsive sizes can be derived later if needed.
abstract final class AppTypography {
  static TextStyle display(BuildContext context) =>
      GoogleFonts.bebasNeue(fontSize: 54, height: 1.05, letterSpacing: 1.5);

  static TextStyle headline(BuildContext context) =>
      GoogleFonts.bebasNeue(fontSize: 36, letterSpacing: 1.0);

  static TextStyle word(BuildContext context) =>
      GoogleFonts.bebasNeue(fontSize: 44, letterSpacing: 0.5);

  static TextStyle title(BuildContext context) =>
      GoogleFonts.quicksand(fontSize: 20, fontWeight: FontWeight.w700);

  static TextStyle body(BuildContext context) =>
      GoogleFonts.quicksand(fontSize: 16);

  static TextStyle bodyBold(BuildContext context) =>
      GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w700);

  static TextStyle caption(BuildContext context) => GoogleFonts.quicksand(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      );
}
