import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color.fromARGB(255, 29, 14, 138);
  static const Color primaryLight = Color(0xFF3D2CC4);
  static const Color primaryDark = Color(0xFF180A8A);
  static const Color primarySurface = Color(0xFFEEECFD);

  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF000000);

  // Shared UI palette
  static const Color bgColor = Color.fromARGB(255, 243, 241, 249);
  static const Color cardColor = Colors.white;
  static const Color labelColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color inputBg = Color(0xFFF0F2F8);
  static const Color inputBgLight = Color(0xFFF8FAFC);
  static const Color darkText = Color(0xFF1E293B);
  static const Color hintColor = Color(0xFFCBD5E1);
  static const Color mutedText = Color(0xFF94A3B8);
  static const Color softMuted = Color(0xFFB0BAC9);

  // Accent colors
  static const Color accentTeal = Color(0xFF0EA5C9);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentSky = Color(0xFF0EA5E9);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFDC2626);

  // Gradient presets
  static const List<Color> primaryGradient = [primaryColor, primaryDark];
  static const List<Color> purpleGradient = [
    Color(0xFF6C47FF),
    Color(0xFF4A2FCC),
  ];
  static const List<Color> blueGradient = [
    Color(0xFF0B6EFD),
    Color(0xFF0047CC),
  ];
  static const List<Color> wellnessBannerGradient = [
    Color(0xFFD4C5F9),
    Color(0xFFB8D8F8),
  ];
}
