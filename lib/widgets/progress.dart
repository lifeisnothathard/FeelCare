import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart';

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
      color: AppColors.cardBackground, // Use defined card background color
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
                color: Colors.grey[600], // Grey text for title
              ),
            ),
            const SizedBox(height: 4), // Spacing
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor, // Use defined text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
