// lib/widgets/dashboard_tab.dart
import 'package:feelcare/services/streak.dart';
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Correct import
import 'package:feelcare/widgets/large_card.dart';
import 'package:feelcare/widgets/progress.dart';

// Represents the content for the 'Dashboard' tab.
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _currentStreak = 0;
  int _longestStreak = 0;
  bool _isLoadingStreak = true; // To show loading state for streak data

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    setState(() {
      _isLoadingStreak = true; // Show loading indicator
    });

    // Call updateStreak to ensure today's activity is counted
    // This will also return the latest current and longest streaks
    final Map<String, int> streakData = await StreakService.updateStreak();

    setState(() {
      _currentStreak = streakData['currentStreak'] ?? 0;
      _longestStreak = streakData['longestStreak'] ?? 0;
      _isLoadingStreak = false; // Hide loading indicator
    });
  }

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
              color: AppColors.getAdaptiveTextColor(
                  context), // Text color adapts to theme
            ),
          ),
          const SizedBox(height: 16), // Spacing below title

          // Grid for "Overall Progress" cards (2x2 layout)
          _isLoadingStreak
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                )
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: <Widget>[
                    const ProgressCard(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      title: 'Habits Completed',
                      value: '0', // This will be dynamic later
                    ),
                    const ProgressCard(
                      icon: Icons.mood,
                      iconColor: Colors.blueAccent,
                      title: 'Positive Days',
                      value: '0', // This will be dynamic later
                    ),
                    ProgressCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.orange,
                      title: 'Current Streak',
                      value: '$_currentStreak days', // Dynamic current streak
                    ),
                    const ProgressCard(
                      icon: Icons.calendar_today,
                      iconColor: Colors.purple,
                      title: 'Entries This Month',
                      value: '0', // This will be dynamic later
                    ),
                  ],
                ),
          const SizedBox(height: 32),

          // Large Card Placeholder for Longest Streak
          _isLoadingStreak
              ? const SizedBox.shrink() // Hide if loading
              : LargeProgressCard(
                  icon: Icons.star,
                  iconColor: Colors.yellow.shade700,
                  title: 'Longest Streak',
                  value: '$_longestStreak days', // Dynamic longest streak
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
              color: AppColors.getAdaptiveCardBackground(
                  context), // Background color adapts
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.getAdaptiveTextColor(context)
                      .withOpacity(0.2)), // Border changes with theme
            ),
            child: Center(
              child: Text(
                'Chart Placeholder\n(Integration with a charting library like `fl_chart` would go here)',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.getAdaptiveTextColor(context)),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
