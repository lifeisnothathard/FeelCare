// lib/widgets/dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Correct import
import 'package:feelcare/widgets/large_card.dart';
import 'package:feelcare/widgets/progress.dart';

// Represents the content for the 'Dashboard' tab.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.getAdaptiveTextColor(context), // Text color adapts to theme
            ),
          ),
          const SizedBox(height: 16), // Spacing below title

          // Grid for "Overall Progress" cards (2x2 layout)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: const <Widget>[
              ProgressCard(
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
                title: 'Habits Completed',
                value: '0', // This will be dynamic later
              ),
              ProgressCard(
                icon: Icons.mood,
                iconColor: Colors.blueAccent,
                title: 'Positive Days',
                value: '0', // This will be dynamic later
              ),
              ProgressCard(
                icon: Icons.trending_up,
                iconColor: Colors.orange,
                title: 'Current Streak',
                value: '0 days', // This will be dynamic later
              ),
              ProgressCard(
                icon: Icons.calendar_today,
                iconColor: Colors.purple,
                title: 'Entries This Month',
                value: '0', // This will be dynamic later
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Large Card Placeholder
          LargeProgressCard(
            icon: Icons.star,
            iconColor: Colors.yellow.shade700,
            title: 'Longest Streak',
            value: '0 days (example)',
          ),
          const SizedBox(height: 32),

          Text(
            'Success Rate by Habit',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getAdaptiveTextColor(context),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.getAdaptiveCardBackground(context), // Background color adapts
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.getAdaptiveTextColor(context).withOpacity(0.2)), // Border changes with theme
            ),
            child: Center(
              child: Text(
                'Chart Placeholder\n(Integration with a charting library like `fl_chart` would go here)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.getAdaptiveTextColor(context)),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}