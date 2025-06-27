import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart';
import 'package:feelcare/widgets/large_card.dart';
import 'package:feelcare/widgets/progress.dart';

// Represents the content for the 'Dashboard' tab.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme's brightness to apply theme-aware colors and styles.

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title for the "Overall Progress" section
          Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor, // Text color adapts to theme
            ),
          ),
          const SizedBox(height: 16), // Spacing below title

          // Grid for "Overall Progress" cards (2x2 layout)
          GridView.count(
            shrinkWrap: true, // Allows GridView to take only necessary space
            physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
            crossAxisCount: 2, // Two columns per row
            crossAxisSpacing: 16.0, // Horizontal spacing between cards
            mainAxisSpacing: 16.0, // Vertical spacing between cards
            childAspectRatio: 1.2, // Adjust aspect ratio of cards for better fit
            children: const <Widget>[
              // Reusable ProgressCard widgets, passing specific icon, color, title, and value.
              ProgressCard(
                icon: Icons.check_circle_outline,
                iconColor: Colors.green, // Specific icon color (does not change with theme)
                title: 'Success Rate',
                value: '61.9%',
              ),
              ProgressCard(
                icon: Icons.calendar_today,
                iconColor: Colors.blue, // Specific icon color
                title: 'Total Entries',
                value: '21',
              ),
              ProgressCard(
                icon: Icons.thumb_up_alt,
                iconColor: Colors.amber, // Specific icon color
                title: 'Positive Days',
                value: '13',
              ),
              ProgressCard(
                icon: Icons.thumb_down_alt,
                iconColor: Colors.red, // Specific icon color
                title: 'Negative Days',
                value: '8',
              ),
            ],
          ),
          const SizedBox(height: 24), // Spacing after progress cards

          // "Best Current Streak" card (large format)
          // Using the reusable LargeProgressCard widget
          const LargeProgressCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange, // Specific icon color
            title: 'Best Current Streak',
            value: '3 days - Smoking (example)',
          ),
          const SizedBox(height: 32), // Spacing after large card

          // Title for the "Success Rate by Habit" section
          Text(
            'Success Rate by Habit',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor, // Text color adapts to theme
            ),
          ),
          const SizedBox(height: 16), // Spacing below title

          // Placeholder for the "Success Rate by Habit" chart
          Container(
            height: 200, // Fixed height for the chart area
            width: double.infinity, // Take full width
            decoration: BoxDecoration(
              color: AppColors.cardBackground, // Background color adapts to theme
              borderRadius: BorderRadius.circular(16), // Rounded corners
              border: Border.all(color: AppColors.textColor.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                'Chart Placeholder\n(Integration with a charting library like `fl_chart` would go here)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textColor.withOpacity(0.7))),
              ),
            ),
          const SizedBox(height: 80), // Extra space at the bottom, useful for Floating Action Button
        ],
      ),
    );
  }
}

// (Assuming your AppColors class looks like this)
class AppColors {
  static const Color primary = Color(0xFF123456);
  static const Color cardBackground = Color(0xFFFFFFFF);
  // ... other color definitions

  static const Color textColor = Color(0xFF222222); // Add this line or adjust as needed
}
