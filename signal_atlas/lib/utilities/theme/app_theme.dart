import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // Primary (Blue)
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightText,
      inversePrimary: AppColors.darkPrimary,

      // Secondary (Purple)
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightText,

      // Tertiary
      tertiary: AppColors.lightTertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.lightTertiaryContainer,
      onTertiaryContainer: AppColors.lightText,

      // Error
      error: AppColors.lightError,
      onError: Colors.white,
      errorContainer: Color(0xFFFCDCDC),
      onErrorContainer: Color(0xFFD9534F),

      // Surfaces
      background: AppColors.lightBackground,
      onBackground: AppColors.lightText,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      surfaceVariant: Color(0xFFE6E8F0),
      onSurfaceVariant: Color(0xFF45464F),

      // Light theme surfaces
      surfaceContainerLow: Color(0xFFFFFFFF),
      surfaceContainer: Color(0xFFF8F7FE),
      surfaceContainerHigh: Color(0xFFEEEFFD),
      surfaceContainerHighest: Color(0xFFE2E2FA),

      // Misc
      outline: AppColors.outline,
      shadow: AppColors.shadow,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
  );


  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      // Primary
      primary: AppColors.darkPrimary,
      onPrimary: Colors.black,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkText,
      inversePrimary: AppColors.primary,

      // Secondary
      secondary: AppColors.darkSecondary,
      onSecondary: Colors.black,
      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.darkText,

      // Tertiary
      tertiary: AppColors.darkTertiary,
      onTertiary: Colors.black,
      tertiaryContainer: AppColors.darkTertiaryContainer,
      onTertiaryContainer: AppColors.darkText,

      // Error
      error: AppColors.darkError,
      onError: Colors.black,
      errorContainer: Color(0xFFCD6B6B),
      onErrorContainer: Color(0xFFFFDAD6),

      // Surfaces
      background: AppColors.darkBackground,
      onBackground: AppColors.darkText,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceVariant: Color(0xFF444654),
      onSurfaceVariant: Color(0xFFC4C6D0),

      // Dark purple-tinted surfaces
      surfaceContainerLow: Color(0xFF2B2F38),
      surfaceContainer: Color(0xFF373B45),
      surfaceContainerHigh: Color(0xFF424651),
      surfaceContainerHighest: Color(0xFF4D515D),

      // Misc
      outline: Color(0xFF8E9099),
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
  );

}
