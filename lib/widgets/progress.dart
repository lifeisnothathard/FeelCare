// lib/widgets/progress.dart

import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Ensure this is correctly imported

//This widget will be used for the small progress cards (Success Rate, Total Entries, Positive Days, Negative Days).
// A reusable widget to display a small progress card with an icon, title, and value.

class ProgressCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const ProgressCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.getAdaptiveCardBackground(context), // Use adaptive card background color
      elevation: 0, // No shadow for a flat design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 36), // Display icon with specified color
            const SizedBox(height: 8), // Spacing
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getAdaptiveTextColor(context).withOpacity(0.7), // Use adaptive text color with opacity
              ),
            ),
            const SizedBox(height: 4), // Spacing
            Text(
              value,
              style: TextStyle( // Changed to TextStyle to apply adaptive color
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getAdaptiveTextColor(context), // Use adaptive text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}