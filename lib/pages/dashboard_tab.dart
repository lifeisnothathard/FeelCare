// lib/widgets/dashboard_tab.dart
import 'package:feelcare/services/streak.dart';
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Correct import
import 'package:feelcare/widgets/large_card.dart';
import 'package:feelcare/widgets/progress.dart';
import 'package:provider/provider.dart'; // Import Provider for HabitMoodService
import 'package:feelcare/services/habit_mood_service.dart'; // Import your service
import 'package:feelcare/models/mood_entry.dart'; // Import your MoodEntry model


// Represents the content for the 'Dashboard' tab.
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _positiveDays = 0; // New state variable for positive days
  int _entriesThisMonth = 0; // New state variable for entries this month
  bool _isLoadingDashboard = true; // Renamed to reflect loading all dashboard data

  @override
  void initState() {
    super.initState();
    // Ensure context is available before calling Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoadingDashboard = true; // Show loading indicator for all data
    });

    try {
      // Fetch streak data
      final Map<String, int> streakData = await StreakService.updateStreak();
      _currentStreak = streakData['currentStreak'] ?? 0;
      _longestStreak = streakData['longestStreak'] ?? 0;

      // Access HabitMoodService to fetch mood entries
      final habitMoodService = Provider.of<HabitMoodService>(context, listen: false);
      List<MoodEntry> moodEntries = await habitMoodService.getAllMoodEntriesForUser().first;

      int positiveCount = 0;
      int entriesCountThisMonth = 0;
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      for (var entry in moodEntries) {
        // Assuming a moodRating of 3 or higher (out of 5) is considered positive
        if (entry.moodRating != null && entry.moodRating! >= 3) {
          positiveCount++;
        }

        // Check if the entry date is within the current month and year
        if (entry.date.month == currentMonth && entry.date.year == currentYear) {
          entriesCountThisMonth++;
        }
      }

      setState(() {
        _positiveDays = positiveCount;
        _entriesThisMonth = entriesCountThisMonth;
        _isLoadingDashboard = false; // Hide loading indicator after all data is loaded
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoadingDashboard = false; // Hide loading indicator even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // habitMoodService is now accessed within _loadDashboardData,
    // so this line is no longer strictly necessary here unless other UI elements
    // within build() directly consume it. For now, it's commented out.
    // final habitMoodService = Provider.of<HabitMoodService>(context);

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
          _isLoadingDashboard // Use the new loading variable
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
                    ProgressCard(
                      icon: Icons.mood,
                      iconColor: Colors.blueAccent,
                      title: 'Positive Days',
                      value: '$_positiveDays', // Dynamic positive days
                    ),
                    ProgressCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.orange,
                      title: 'Current Streak',
                      value: '$_currentStreak days', // Dynamic current streak
                    ),
                    ProgressCard(
                      icon: Icons.calendar_today,
                      iconColor: Colors.purple,
                      title: 'Entries This Month',
                      value: '$_entriesThisMonth', // Dynamic entries this month
                    ),
                  ],
                ),
          const SizedBox(height: 32),

          // Large Card Placeholder for Longest Streak
          _isLoadingDashboard // Use the new loading variable
              ? const SizedBox.shrink() // Hide if loading
              : LargeProgressCard(
                  icon: Icons.star,
                  iconColor: Colors.yellow.shade700,
                  title: 'Longest Streak',
                  value: '$_longestStreak days', // Dynamic longest streak
                ),
          const SizedBox(height: 32), // Add spacing before new section

          // If you still need space at the bottom for other elements or general padding,
          // you can add a SizedBox here, otherwise, it's removed with the journal entries.
          // const SizedBox(height: 32), // Example: Add general bottom spacing if needed
        ],
      ),
    );
  }
}
