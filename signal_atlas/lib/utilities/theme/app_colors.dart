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

  // Dark theme
  static const Color darkPrimary = Color(0xFF9BB7F0);
  static const Color darkSecondary = Color(0xFFAAA7E8);

  static const Color darkBackground = Color(0xFF1E1F24);
  static const Color darkSurface = Color(0xFF2A2B31);

  static const Color darkPrimaryContainer = Color(0xFF353A4A);
  static const Color darkSecondaryContainer = Color(0xFF3A3B4D);

  static const Color darkText = Colors.white;

  static const Color darkTertiary = Color(0xFFB6B4F2);
  static const Color darkTertiaryContainer = Color(0xFF2E2F45);

  // Common
  static const Color outline = Color(0xFFB0B3C6);
  static const Color shadow = Colors.black54;
  static const Color error = Colors.redAccent;
}