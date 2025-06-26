import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart';

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
      color: AppColors.cardBackground, // Use defined card background color
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
                    color: Colors.grey[600], // Grey text for title
                  ),
                ),
                const SizedBox(height: 4), // Spacing
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor, // Use defined text color
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
