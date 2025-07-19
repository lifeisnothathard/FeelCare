// lib/pages/habits_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feelcare/themes/colors.dart';
import 'package:feelcare/services/habit_mood_service.dart';
import 'package:feelcare/models/habit.dart';

class HabitsTab extends StatefulWidget {
  const HabitsTab({super.key});

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  // Define TextEditingControllers for the dialog form
  late TextEditingController _nameController;
  late TextEditingController _goalController;
  late TextEditingController _frequencyController;
  late TextEditingController _specificDaysController; // For specific days input
  bool _isActive = true; // For the isActive toggle

  // Initialize controllers when the state is created
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _goalController = TextEditingController();
    _frequencyController = TextEditingController();
    _specificDaysController = TextEditingController();
  }

  // Dispose controllers when the state is removed to prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _frequencyController.dispose();
    _specificDaysController.dispose();
    super.dispose();
  }

  // Helper function to show the edit habit dialog
  Future<Habit?> _showEditHabitDialog(
      BuildContext context, Habit habitToEdit) async {
    // Pre-populate controllers with existing habit data
    _nameController.text = habitToEdit.name;
    _goalController.text = habitToEdit.goal;
    _frequencyController.text = habitToEdit.frequency;
    _specificDaysController.text =
        habitToEdit.specificDays?.join(', ') ?? ''; // Convert list to string
    _isActive = habitToEdit.isActive; // Set initial state for toggle

    return showDialog<Habit>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a StatefulBuilder to manage the internal state of the dialog (like _isActive toggle)
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Habit'),
              content: SingleChildScrollView(
                // Allow scrolling for longer forms
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Habit Name'),
                    ),
                    TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                          labelText: 'Goal (e.g., 1 time a day)'),
                    ),
                    TextField(
                      controller: _frequencyController,
                      decoration: const InputDecoration(
                          labelText:
                              'Frequency (e.g., daily, weekly, specific_days)'),
                    ),
                    TextField(
                      controller: _specificDaysController,
                      decoration: const InputDecoration(
                          labelText:
                              'Specific Days (comma-separated, e.g., Monday, Wednesday)'),
                      // Only show if frequency implies specific days, or allow always to simplify initial input
                      // This can be made conditional based on _frequencyController.text if needed
                    ),
                    Row(
                      children: [
                        const Text('Is Active?'),
                        Switch(
                          value: _isActive,
                          onChanged: (bool value) {
                            setDialogState(() {
                              // Use setDialogState to update state within the dialog
                              _isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext)
                        .pop(); // Dismiss dialog without returning data
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Basic validation
                    if (_nameController.text.isEmpty ||
                        _goalController.text.isEmpty ||
                        _frequencyController.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please fill in all required fields.')),
                      );
                      return;
                    }

                    // Create a new Habit object with updated data
                    final updatedHabit = habitToEdit.copyWith(
                      name: _nameController.text,
                      goal: _goalController.text,
                      frequency: _frequencyController.text,
                      specificDays: _specificDaysController.text.isNotEmpty
                          ? _specificDaysController.text
                              .split(',')
                              .map((s) => s.trim())
                              .toList()
                          : null,
                      isActive: _isActive,
                      // creationDate, isCompletedToday, lastCompleted remain unchanged by edit dialog
                    );
                    Navigator.of(dialogContext)
                        .pop(updatedHabit); // Return the updated habit
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<HabitMoodService>(
      builder: (context, habitMoodService, child) {
        return StreamBuilder<List<Habit>>(
          stream: habitMoodService.getHabitsForUser(),
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
                  textAlign: TextAlign.center,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        style: textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Start adding new habits using the "+" button.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              final habits = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  Color doneIconColor = habit.isCompletedToday
                      ? Colors.green.shade800
                      : Colors.green.shade400;

                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            habit.isCompletedToday
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: doneIconColor,
                            size: 30,
                          ),
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
                                    decoration: habit.isCompletedToday
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: doneIconColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Goal: ${habit.goal} | Frequency: ${habit.frequency}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                if (habit.specificDays != null &&
                                    habit.specificDays!.isNotEmpty)
                                  Text(
                                    'Days: ${habit.specificDays!.join(', ')}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                if (habit.lastCompleted != null)
                                  Text(
                                    'Last Completed: ${habit.lastCompleted!.toLocal().toString().split(' ')[0]}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                if (!habit.isActive)
                                  Text(
                                    'Inactive',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.done_all, color: doneIconColor),
                            onPressed: habit.isCompletedToday
                                ? null
                                : () async {
                                    print(
                                        'Attempting to mark habit "${habit.name}" as done');
                                    try {
                                      await habitMoodService
                                          .markHabitAsDone(habit.id!);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Habit "${habit.name}" marked as done!')),
                                      );
                                    } catch (e) {
                                      print('Error marking habit as done: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to mark habit as done: $e')),
                                      );
                                    }
                                  },
                            tooltip: habit.isCompletedToday
                                ? 'Already Completed Today'
                                : 'Mark as Done',
                          ),
                          // EDITED: Edit Button Logic
                          IconButton(
                            icon: Icon(Icons.edit, color: colorScheme.primary),
                            onPressed: () async {
                              print('Edit habit: ${habit.name}');
                              final updatedHabit =
                                  await _showEditHabitDialog(context, habit);

                              if (updatedHabit != null) {
                                try {
                                  await habitMoodService
                                      .updateHabit(updatedHabit);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Habit "${updatedHabit.name}" updated successfully!')),
                                  );
                                } catch (e) {
                                  print('Error updating habit: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Failed to update habit: $e')),
                                  );
                                }
                              } else {
                                print('Edit cancelled or no changes.');
                              }
                            },
                            tooltip: 'Edit Habit',
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.delete, color: Colors.red.shade400),
                            onPressed: () async {
                              print('Delete habit: ${habit.name}');
                              try {
                                final bool confirmDelete = await showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: const Text('Confirm Deletion'),
                                          content: Text(
                                              'Are you sure you want to delete "${habit.name}"?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(dialogContext)
                                                      .pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(dialogContext)
                                                      .pop(true),
                                              child: const Text('Delete'),
                                              style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red),
                                            ),
                                          ],
                                        );
                                      },
                                    ) ??
                                    false;

                                if (confirmDelete) {
                                  await habitMoodService.deleteHabit(habit.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Habit "${habit.name}" deleted.')),
                                  );
                                }
                              } catch (e) {
                                print('Error deleting habit: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to delete habit: $e')),
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
