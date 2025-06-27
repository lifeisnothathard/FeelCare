// lib/themes/dark_mode.dart
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Import our consolidated colors

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: AppColors.backgroundDark, // Main background
    primary: AppColors.primaryDark, // Primary brand color
    secondary: AppColors.secondaryDark, // Secondary brand color
    tertiary: AppColors.cardBackgroundDark, // Card backgrounds, softer elements
    inversePrimary: AppColors.textLight, // Text color that contrasts well with primary
    onSurface: AppColors.textLight, // Text on surface background
    onPrimary: Colors.white, // Text on primary color
    onSecondary: AppColors.textLight, // Text on secondary color
    onTertiary: AppColors.textLight, // Text on tertiary color
    error: AppColors.errorRed, // Error messages
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primaryDark, // Deeper green app bar
    foregroundColor: Colors.white, // White icons/text on app bar
    elevation: 0, // Flat design
  ),
  cardTheme: CardThemeData(
    color: AppColors.cardBackgroundDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Softer corners
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: AppColors.textLight, fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: AppColors.textLight, fontSize: 45),
    displaySmall: TextStyle(color: AppColors.textLight, fontSize: 36),
    headlineLarge: TextStyle(color: AppColors.textLight, fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: AppColors.textLight, fontSize: 28),
    headlineSmall: TextStyle(color: AppColors.textLight, fontSize: 24),
    titleLarge: TextStyle(color: AppColors.textLight, fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: AppColors.textLight, fontSize: 16),
    titleSmall: TextStyle(color: AppColors.textLight, fontSize: 14),
    bodyLarge: TextStyle(color: AppColors.textLight, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textLight, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.textLight, fontSize: 12),
    labelLarge: TextStyle(color: AppColors.textLight, fontSize: 14),
    labelMedium: TextStyle(color: AppColors.textLight, fontSize: 12),
    labelSmall: TextStyle(color: AppColors.textLight, fontSize: 11),
  ),
  iconTheme: const IconThemeData(
    color: AppColors.iconColorDark, // Default icon color
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark, // FAB color
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryDark,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardBackgroundDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    // ignore: deprecated_member_use
    labelStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7)),
    // ignore: deprecated_member_use
    hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.5)),
  ),
);