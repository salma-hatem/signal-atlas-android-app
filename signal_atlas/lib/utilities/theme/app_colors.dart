import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // logo colours
  static const Color brandBlue = Color(0xFF6D9EEB);
  static const Color brandPurple = Color(0xFFC5C2EF);

  // Light theme
  static const Color primary = brandBlue;
  static const Color secondary = brandPurple;

  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Colors.white;

  static const Color lightPrimaryContainer = Color(0xFFDCE8FA); // blue tint
  static const Color lightSecondaryContainer = Color(0xFFE8E6FB); // purple tint

  static const Color lightText = Color(0xFF1E1E1E);

  static const Color lightTertiary = Color(0xFFA9B7F4);
  static const Color lightTertiaryContainer = Color(0xFFF0EFFF);
  static const Color lightError = Color(0xFFEB6E6A);

  // Dark theme
  static const Color darkPrimary = Color(0xFF8FB4FF);
  static const Color darkSecondary = Color(0xFFC1B8FF);

  static const Color darkBackground = Color(0xFF1E1F24);
  static const Color darkSurface = Color(0xFF373B45);

  static const Color darkPrimaryContainer = Color(0xFF3A4360);
  static const Color darkSecondaryContainer = Color(0xFF4A457A);

  static const Color darkText = Colors.white;

  static const Color darkTertiary = Color(0xFFA7C4FF);
  static const Color darkTertiaryContainer = Color(0xFF2E2F45);
  static const Color darkError = Color(0xFFEB6E6A);

  // Common
  static const Color outline = Color(0xFFB0B3C6);
  static const Color shadow = Colors.black54;


  // Maps
  static const Map<int, Color> signalStrengthLight = {
    0: Color(0xFFD9534F),
    1: Color(0xFFEB6E6A),
    2: Color(0xFFEB7F5C),
    3: Color(0xFF6CC070),
    4: Color(0xFF6D9EEB),
  };

  static const Map<int, Color> signalStrengthDark = {
    0: Color(0xFFC15B5B),
    1: Color(0xFFCD6B6B),
    2: Color(0xFFFFA85C),
    3: Color(0xFF6CC070),
    4: Color(0xFF8FB4FF),
  };

  static const Map<int, Color> chartColorsLight = {
    0 : primary,
    1: Color(0xFF6CC070),
  };

  static const Map<int, Color> chartColorsDark = {
    0: darkPrimary,
    1: Color(0xFF6CC070),
  };

  static Color chartColor(int index, ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final map = isDark ? chartColorsDark : chartColorsLight;
    return map[index] ?? scheme.primary;
  }


  static Color strengthColor(int strength, ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final map = isDark ? signalStrengthDark : signalStrengthLight;
    return map[strength] ?? scheme.primary;
  }

  static Color normalizedProgress(double value, ColorScheme scheme) {
    if (value <= 0.25) return strengthColor(1, scheme);
    if (value <= 0.5) return strengthColor(2, scheme);
    if (value <= 0.75) return strengthColor(3, scheme);
    return scheme.primary;
  }
}