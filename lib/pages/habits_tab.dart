// lib/tabs/habits_tab.dart
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Import our consolidated AppColors

// Represents the content for the 'Habits' tab.
class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use icon from theme, or a specific "cute" icon if added as an asset
            Icon(
              Icons.checklist,
              size: 80,
              color: colorScheme.primary, // Use primary color from theme
            ),
            const SizedBox(height: 20),
            Text(
              'Your Habits List Will Appear Here!',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)), // Use theme text style
            ),
            const SizedBox(height: 10),
            Text(
              'Start adding new habits using the "+" button.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)), // Use theme text style
            ),
          ],
        ),
      ),
    );
  }
}