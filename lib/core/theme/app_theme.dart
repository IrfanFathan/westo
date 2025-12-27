import 'package:flutter/material.dart';
import 'package:westo/core/constants/app_colors.dart';
import 'package:westo/core/theme/app_text_styles.dart';

import '../constants/app_fonts.dart';

class AppTheme {

  // This ThemeData defines how the entire application looks
  // It is applied in main.dart using:
  // theme: AppTheme.lightTheme
  static ThemeData lightTheme = ThemeData(

    // Enables Material Design 3 (modern Flutter UI system)
    useMaterial3: true,

    // Sets the default font for the entire app (Inter)
    fontFamily: AppFonts.primaryFont,

    // Sets the background color for all Scaffold widgets (screens)
    scaffoldBackgroundColor: AppColors.background,

    // Defines the core color system used by Flutter widgets
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,     // Main brand color (buttons, app bar)
      secondary: AppColors.secondary, // Accent color
      error: AppColors.error,         // Error messages and alerts
      surface: AppColors.surface,     // Cards, text fields background
    ),

    // Defines the default text styles used across the app
    textTheme: TextTheme(
      titleLarge: AppTextStyles.appTitle, // App titles and main headings
      titleMedium: AppTextStyles.heading, // Section headings
      bodyLarge: AppTextStyles.body,      // Main body text
      bodyMedium: AppTextStyles.body,     // Secondary body text
    ),

    // Controls the appearance of all AppBar widgets
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary, // AppBar background color
      foregroundColor: Colors.white,      // AppBar text and icon color
      elevation: 0,                       // Removes shadow under AppBar
      titleTextStyle: AppTextStyles.appTitle, // AppBar title text style
    ),

    // Controls the appearance of all ElevatedButton widgets
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // Button background color
        foregroundColor: Colors.white,      // Button text color
        textStyle: AppTextStyles.button,    // Button text style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded button corners
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20, // Horizontal padding inside button
          vertical: 14,   // Vertical padding inside button
        ),
      ),
    ),

    // Controls the appearance of all TextField and Input widgets
    inputDecorationTheme: InputDecorationTheme(
      filled: true,                       // Enables filled background
      fillColor: AppColors.surface,       // Input background color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,        // Default border color
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,        // Border when input is enabled
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,       // Border when input is focused
          width: 1.5,
        ),
      ),
      hintStyle: AppTextStyles.caption,   // Hint text style
    ),

    // Controls the appearance of all Card widgets in the app
    cardTheme: CardThemeData(
      color: AppColors.surface,           // Card background color
      elevation: 2,                       // Shadow depth (small and clean)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded card corners
      ),
    ),
  );
}

