// lib/pages/habits_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feelcare/themes/colors.dart';
import 'package:feelcare/services/habit_mood_service.dart';
import 'package:feelcare/models/habit.dart'; // Make sure your Habit model is imported

// The Habit model class can be removed from here if it's already in lib/models/habit.dart
// class Habit {
//   final String id;
//   final String name;
//   final String goal;
//   final String frequency;
//
//   Habit({required this.id, required this.name, required this.goal, required this.frequency});
// }


class HabitsTab extends StatefulWidget {
  const HabitsTab({super.key});

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  @override
  void initState() {
    super.initState();
    // No need to call _loadHabits() explicitly if listening to a stream
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Use Consumer to listen to changes in HabitMoodService
    // This ensures that if HabitMoodService uses notifyListeners()
    // for other state changes (not just stream updates), this widget can react.
    return Consumer<HabitMoodService>(
      builder: (context, habitMoodService, child) {
        // Use a StreamBuilder to react to changes in the habits stream
        // The `!` operator asserts that habitMoodService.getHabitsForUser() is not null.
        // This is safe because your HabitMoodService's getHabitsForUser()
        // explicitly returns Stream.value([]) if currentUserId is null,
        // so it never truly returns a null Stream.
        return StreamBuilder<List<Habit>>(
          stream: habitMoodService.getHabitsForUser(), // This should be fine now.
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              );
            } else if (snapshot.hasError) {
              print('Error in HabitsTab Stream: ${snapshot.error}');
              return Center(
                child: Text(
                  'Error loading habits: ${snapshot.error}',
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center, // Center text for readability
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Display empty state
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your Habits List Will Appear Here!',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Start adding new habits using the "+" button.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Display the list of habits
              final habits = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: colorScheme.secondary, size: 30),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Goal: ${habit.goal} | Frequency: ${habit.frequency}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Example action buttons (e.g., mark complete, edit, delete)
                          IconButton(
                            icon: Icon(Icons.done, color: Colors.green.shade600),
                            onPressed: () {
                              print('Mark habit "${habit.name}" as done');
                              // You'd typically call a method in habitMoodService to mark as done
                              // e.g., habitMoodService.markHabitAsDone(habit.id, DateTime.now());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Habit marked as done (functionality to be implemented)!')),
                              );
                            },
                            tooltip: 'Mark as Done',
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.primary),
                            onPressed: () {
                              print('Edit habit: ${habit.name}');
                              // Open a dialog to edit habit
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Edit habit (functionality to be implemented)!')),
                              );
                            },
                            tooltip: 'Edit Habit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red.shade400),
                            onPressed: () async {
                              print('Delete habit: ${habit.name}');
                              try {
                                // Add confirmation dialog before deleting for better UX
                                final bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: Text('Are you sure you want to delete "${habit.name}"?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                ) ?? false; // Default to false if dialog is dismissed

                                if (confirmDelete) {
                                  await habitMoodService.deleteHabit(habit.id!); // habit.id is nullable, use ! if you're certain
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Habit "${habit.name}" deleted.')),
                                  );
                                }
                              } catch (e) {
                                print('Error deleting habit: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete habit: $e')),
                                );
                              }
                            },
                            tooltip: 'Delete Habit',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}