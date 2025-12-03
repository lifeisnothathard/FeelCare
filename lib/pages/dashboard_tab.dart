// lib/widgets/dashboard_tab.dart
import 'package:feelcare/services/streak.dart';
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart';
import 'package:feelcare/widgets/large_card.dart';
import 'package:feelcare/widgets/progress.dart';
import 'package:provider/provider.dart';
import 'package:feelcare/services/habit_mood_service.dart';
import 'package:feelcare/models/mood_entry.dart';
import 'package:feelcare/models/habit.dart'; // Import your Habit model

// Represents the content for the 'Dashboard' tab.
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _positiveDays = 0;
  int _entriesThisMonth = 0;
  int _habitsCompletedToday =
      0; // NEW: State variable for habits completed today
  bool _isLoadingDashboard = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoadingDashboard = true;
    });

    try {
      final habitMoodService =
          Provider.of<HabitMoodService>(context, listen: false);

      // --- 1. Fetch Streak Data ---
      final Map<String, int> streakData = await StreakService.updateStreak();
      _currentStreak = streakData['currentStreak'] ?? 0;
      _longestStreak = streakData['longestStreak'] ?? 0;

      // --- 2. Fetch Mood Entries and calculate related metrics ---
      List<MoodEntry> moodEntries =
          await habitMoodService.getAllMoodEntriesForUser().first;

      int positiveCount = 0;
      int entriesCountThisMonth = 0;
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      for (var entry in moodEntries) {
        if (entry.moodRating != null && entry.moodRating! >= 3) {
          positiveCount++;
        }

        if (entry.date.month == currentMonth &&
            entry.date.year == currentYear) {
          entriesCountThisMonth++;
        }
      }

      // --- 3. Fetch Habits and calculate habits completed today ---
      List<Habit> habits = await habitMoodService.getHabitsForUser().first;
      int completedHabitsCount = 0;
      final today =
          DateTime(now.year, now.month, now.day); // Get start of today

      for (var habit in habits) {
        // Check if the habit is marked as completed AND if its lastCompleted date is indeed today
        if (habit.isCompletedToday &&
            habit.lastCompleted != null &&
            habit.lastCompleted!.year == today.year &&
            habit.lastCompleted!.month == today.month &&
            habit.lastCompleted!.day == today.day) {
          completedHabitsCount++;
        }
      }

      // --- Update State with all calculated data ---
      setState(() {
        _positiveDays = positiveCount;
        _entriesThisMonth = entriesCountThisMonth;
        _habitsCompletedToday =
            completedHabitsCount; // Update the new state variable
        _isLoadingDashboard = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoadingDashboard = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getAdaptiveTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          _isLoadingDashboard
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
                    ProgressCard(
                      // NOW DYNAMIC
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      title: 'Habits Completed',
                      value:
                          '$_habitsCompletedToday', // Display the dynamic count
                    ),
                    ProgressCard(
                      icon: Icons.mood,
                      iconColor: Colors.blueAccent,
                      title: 'Positive Days',
                      value: '$_positiveDays',
                    ),
                    ProgressCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.orange,
                      title: 'Current Streak',
                      value: '$_currentStreak days',
                    ),
                    ProgressCard(
                      icon: Icons.calendar_today,
                      iconColor: Colors.purple,
                      title: 'Entries This Month',
                      value: '$_entriesThisMonth',
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          _isLoadingDashboard
              ? const SizedBox.shrink()
              : LargeProgressCard(
                  icon: Icons.star,
                  iconColor: Colors.yellow.shade700,
                  title: 'Longest Streak',
                  value: '$_longestStreak days',
                ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
