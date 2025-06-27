// lib/themes/light_mode.dart
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Import our consolidated colors

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: AppColors.backgroundLight, // Main background
    primary: AppColors.primaryLight, // Primary brand color
    secondary: AppColors.secondaryLight, // Secondary brand color
    tertiary: AppColors.cardBackgroundLight, // Card backgrounds, softer elements
    inversePrimary: AppColors.textDark, // Text color that contrasts well with primary
    onSurface: AppColors.textDark, // Text on surface background
    onPrimary: Colors.white, // Text on primary color
    onSecondary: AppColors.textDark, // Text on secondary color
    onTertiary: AppColors.textDark, // Text on tertiary color
    error: AppColors.errorRed, // Error messages
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryLight, // Soft green app bar
    foregroundColor: Colors.white, // White icons/text on app bar
    elevation: 0, // Flat design
  ),
  cardTheme: CardThemeData(
    color: AppColors.cardBackgroundLight,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Softer corners
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: AppColors.textDark, fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: AppColors.textDark, fontSize: 45),
    displaySmall: TextStyle(color: AppColors.textDark, fontSize: 36),
    headlineLarge: TextStyle(color: AppColors.textDark, fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: AppColors.textDark, fontSize: 28),
    headlineSmall: TextStyle(color: AppColors.textDark, fontSize: 24),
    titleLarge: TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: AppColors.textDark, fontSize: 16),
    titleSmall: TextStyle(color: AppColors.textDark, fontSize: 14),
    bodyLarge: TextStyle(color: AppColors.textDark, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textDark, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.textDark, fontSize: 12),
    labelLarge: TextStyle(color: AppColors.textDark, fontSize: 14),
    labelMedium: TextStyle(color: AppColors.textDark, fontSize: 12),
    labelSmall: TextStyle(color: AppColors.textDark, fontSize: 11),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.iconColorLight, // Default icon color
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight, // FAB color
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardBackgroundLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    // ignore: deprecated_member_use
    labelStyle: TextStyle(color: AppColors.textDark.withOpacity(0.7)),
    // ignore: deprecated_member_use
    hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.5)),
  ),
);