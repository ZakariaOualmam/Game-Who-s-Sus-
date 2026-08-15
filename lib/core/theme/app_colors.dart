import 'package:flutter/material.dart';

/// Central color palette for the WHO'S SUS design system.
abstract final class AppColors {
  // Brand identity (official WHO'S SUS palette)
  static const Color midnight = Color(0xFF0B0B18);
  static const Color navy = Color(0xFF0A0A16);
  static const Color purpleDeep = Color(0xFF241B4D);
  static const Color violet = Color(0xFF7C4DFF);
  static const Color cyan = Color(0xFF00C2FF);
  static const Color blueSoft = Color(0xFF3D7CFF);
  static const Color lavender = Color(0xFFF1EFFF);

  // Surfaces
  static const Color background = midnight;
  static const Color surface = Color(0xFF16162B);
  static const Color surfaceHigh = Color(0xFF20203D);

  // Brand accents
  static const Color primary = violet;
  static const Color secondary = cyan;
  static const Color accent = blueSoft;

  // Feedback
  static const Color success = Color(0xFF37E39E);
  static const Color danger = Color(0xFFFF4D6D);
  static const Color warning = Color(0xFFFFC94D);

  // Text
  static const Color textPrimary = lavender;
  static const Color textSecondary = Color(0xFFA6A6C2);
  static const Color textMuted = Color(0xFF6E6E8C);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF7C4DFF),
    Color(0xFF00C2FF),
  ];
  static const List<Color> imposterGradient = [
    Color(0xFFFF4D6D),
    Color(0xFFFF7A45),
  ];
  static const List<Color> crewGradient = [
    Color(0xFF37E39E),
    Color(0xFF00C2FF),
  ];
}
