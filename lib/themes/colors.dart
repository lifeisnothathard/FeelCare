// lib/themes/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Calming Light Palette
  static const Color primaryLight = Color(0xFF81C784); // A soft green
  static const Color secondaryLight = Color(0xFFC8E6C9); // Lighter green for accents
  static const Color backgroundLight = Color(0xFFF9FBE7); // Very light yellow-green for background
  static const Color cardBackgroundLight = Color(0xFFE8F5E9); // Light green for cards
  static const Color textDark = Color(0xFF424242); // Dark grey for text
  static const Color accentLight = Color(0xFFFFCC80); // Soft orange for emphasis
  static const Color iconColorLight = Color(0xFF66BB6A); // Green for icons

  // Calming Dark Palette
  static const Color primaryDark = Color(0xFF388E3C); // A deeper green
  static const Color secondaryDark = Color(0xFFA5D6A7); // Slightly muted green for accents
  static const Color backgroundDark = Color(0xFF212121); // Dark grey for background
  static const Color cardBackgroundDark = Color(0xFF424242); // Darker grey for cards
  static const Color textLight = Color(0xFFE0E0E0); // Light grey for text
  static const Color accentDark = Color(0xFFFB8C00); // Muted orange for emphasis
  static const Color iconColorDark = Color(0xFF81C784); // Lighter green for icons

  // Neutral colors (can be used across themes if desired)
  static const Color greyText = Colors.grey; // For less prominent text
  static const Color errorRed = Colors.redAccent;
  static const Color successGreen = Colors.lightGreen;

  // Placeholder for `darkGreen` which was `static var darkGreen`
  // We'll use specific light/dark values now.
  // For `new_habit.dart`, `AppColors.darkGreen.withValues()` will need to be replaced.
  // Let's create a getter that returns the appropriate dark green based on context/theme mode,
  // or simply use `Theme.of(context).colorScheme.primary` or `iconColorLight/Dark`.
  // For now, I'll remove `static var darkGreen;` from this file as it's not a static constant.
}