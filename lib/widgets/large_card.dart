// lib/widgets/large_card.dart

import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Ensure this is correctly imported

// A reusable widget to display a large progress card, typically for streaks or key metrics.
class LargeProgressCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const LargeProgressCard({
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
      elevation: 0, // No shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 48), // Display large icon
            const SizedBox(width: 16), // Spacing
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getAdaptiveTextColor(context).withOpacity(0.7), // Use adaptive text color with opacity
                  ),
                ),
                const SizedBox(height: 4), // Spacing
                Text(
                  value,
                  style: TextStyle( // Changed to TextStyle to apply adaptive color
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getAdaptiveTextColor(context), // Use adaptive text color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}