// lib/services/streak_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StreakService {
  static const String _streakKey = 'current_streak';
  static const String _lastActivityDateKey = 'last_activity_date';
  static const String _longestStreakKey =
      'longest_streak'; // New key for longest streak

  // Helper function to format dates for comparison (YYYY-MM-DD)
  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Retrieves the current streak count from SharedPreferences.
  static Future<int> getCurrentStreak() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  /// Retrieves the longest streak count from SharedPreferences.
  static Future<int> getLongestStreak() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_longestStreakKey) ?? 0;
  }

  /// Records an activity and updates the streak based on the current date.
  ///
  /// Returns a Map containing the updated 'currentStreak' and 'longestStreak'.
  static Future<Map<String, int>> updateStreak() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DateTime now = DateTime.now();
    final String todayFormatted = _formatDate(now);

    // Retrieve the last recorded activity date string
    final String? lastActivityDateString =
        prefs.getString(_lastActivityDateKey);

    // Retrieve the current streak count
    int currentStreak = prefs.getInt(_streakKey) ?? 0;
    // Retrieve the longest streak count
    int longestStreak = prefs.getInt(_longestStreakKey) ?? 0;

    // Check if there was previous activity
    if (lastActivityDateString != null) {
      // 1. Check if the activity was already recorded today
      if (lastActivityDateString == todayFormatted) {
        // Streak remains the same, do nothing
        print(
            'Activity already recorded today. Current Streak: $currentStreak, Longest Streak: $longestStreak');
        return {'currentStreak': currentStreak, 'longestStreak': longestStreak};
      }

      // 2. Check if the last activity was exactly yesterday (consecutive day)
      //final DateTime lastActivityDate = DateTime.parse(lastActivityDateString);
      final DateTime yesterday = now.subtract(const Duration(days: 1));
      final String yesterdayFormatted = _formatDate(yesterday);

      if (lastActivityDateString == yesterdayFormatted) {
        // Consecutive day! Increment current streak
        currentStreak++;
        print('Streak continued! New current streak: $currentStreak');
      } else {
        // Streak is broken (activity was > 1 day ago)
        // Reset current streak to 1 (since activity is recorded today)
        currentStreak = 1;
        print('Streak broken. Resetting current streak to 1.');
      }
    } else {
      // 3. First time recording activity (no previous date)
      currentStreak = 1;
      print('First activity recorded. Current Streak: 1');
    }

    // Update longest streak if current streak is greater
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
      print('New longest streak: $longestStreak');
    }

    // Update SharedPreferences with the new streak values and today's date
    await prefs.setInt(_streakKey, currentStreak);
    await prefs.setInt(_longestStreakKey, longestStreak); // Save longest streak
    await prefs.setString(_lastActivityDateKey, todayFormatted);

    return {'currentStreak': currentStreak, 'longestStreak': longestStreak};
  }
}
