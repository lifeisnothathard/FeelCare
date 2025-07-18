// lib/widgets/dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:feelcare/themes/colors.dart'; // Correct import
import 'package:feelcare/widgets/large_card.dart';
import 'package:feelcare/widgets/progress.dart';
import 'package:feelcare/services/habit_mood_service.dart'; // Import your service
import 'package:feelcare/models/mood_entry.dart'; // Import your MoodEntry model

// Represents the content for the 'Dashboard' tab.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the HabitMoodService using Provider
    final habitMoodService = Provider.of<HabitMoodService>(context);

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
          const SizedBox(height: 32), // Add spacing before new section

          // --- NEW SECTION: JOURNAL ENTRIES ---
          Text(
            'Recent Journal Entries',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.getAdaptiveTextColor(context),
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<List<MoodEntry>>(
            stream: habitMoodService.getAllMoodEntriesForUser(), // Fetch all mood entries
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print('Error loading journal entries: ${snapshot.error}'); // For debugging
                return Center(
                  child: Text('Error loading journal entries: ${snapshot.error}',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No journal entries yet. Your daily mood and notes will appear here!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              } else {
                final moodEntries = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // Important for nested lists
                  physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                  itemCount: moodEntries.length,
                  itemBuilder: (context, index) {
                    final entry = moodEntries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${entry.date.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text('Emotions: ${entry.selectedEmotions.join(', ')}',
                                style: Theme.of(context).textTheme.bodyLarge),
                            if (entry.moodRating != null)
                              Text('Mood Rating: ${entry.moodRating}',
                                  style: Theme.of(context).textTheme.bodyLarge),
                            if (entry.habitName != null) // Only show if a habit was linked
                              Text('Habit: ${entry.habitName} (${entry.habitCompleted == true ? "Completed" : "Not Completed"})',
                                  style: Theme.of(context).textTheme.bodyLarge),
                            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Notes: ${entry.notes}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            // Add a delete button for mood entries
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[400]),
                                onPressed: () async {
                                  if (entry.id != null) {
                                    await habitMoodService.deleteMoodEntry(entry.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Journal entry deleted')),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(height: 80), // Extra space at the bottom for floating button
        ],
      ),
    );
  }
}