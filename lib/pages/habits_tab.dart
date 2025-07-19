// lib/pages/habits_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider if you're using it for HabitMoodService
import 'package:feelcare/themes/colors.dart'; // Import our consolidated AppColors
import 'package:feelcare/services/habit_mood_service.dart'; // Ensure this service exists and can fetch habits

// Define a simple Habit model for demonstration purposes if you don't have one
// You might have a more complex model in your actual project.
class Habit {
  final String id;
  final String name;
  final String goal;
  final String frequency;

  Habit({required this.id, required this.name, required this.goal, required this.frequency});
}


class HabitsTab extends StatefulWidget {
  const HabitsTab({super.key});

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  List<Habit> _habits = []; // List to store fetched habits
  bool _isLoading = true; // To show loading indicator

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true; // Set loading to true when starting to fetch
    });

    try {
      // Assuming HabitMoodService has a method to get habits.
      // Replace this with your actual data fetching logic.
      // For demonstration, I'll simulate a delay and add a mock habit.
      final habitMoodService = Provider.of<HabitMoodService>(context, listen: false);
      // Example: Fetch habits from your service
      // List<Habit> fetchedHabits = await habitMoodService.getHabitsForUser(); // Assuming such a method exists

      // --- DEMO DATA / PLACEHOLDER LOGIC ---
      // If your service doesn't return anything yet, or for testing:
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      List<Habit> fetchedHabits = [];
      // Add the "Tak ingat" habit if it's supposed to be a default or test entry
      fetchedHabits.add(Habit(id: '1', name: 'Tak ingat', goal: '1 time a day', frequency: 'daily'));
      // Add more dummy habits if you want to see a list
      // fetchedHabits.add(Habit(id: '2', name: 'Drink Water', goal: '8 glasses', frequency: 'daily'));
      // fetchedHabits.add(Habit(id: '3', name: 'Exercise', goal: '30 mins', frequency: '3 times a week'));
      // --- END DEMO DATA ---

      if (mounted) {
        setState(() {
          _habits = fetchedHabits;
          _isLoading = false; // Set loading to false after data is fetched
        });
      }
    } catch (e) {
      print('Error loading habits: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading even if there's an error
          // Optionally, show an error message to the user
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary, // Use theme's primary color for indicator
        ),
      );
    }

    if (_habits.isEmpty) {
      // Display the empty state message if no habits are loaded
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.checklist,
                size: 80,
                color: colorScheme.primary, // Use primary color from theme
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
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          return Card(
            color: Theme.of(context).cardColor, // Use theme's card color for consistency
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2, // Add a subtle shadow
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon for the habit (you might want dynamic icons based on habit type)
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
                      // Handle habit completion
                      print('Mark habit "${habit.name}" as done');
                      // You might want to update the state or call a service method here
                    },
                    tooltip: 'Mark as Done',
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: colorScheme.primary),
                    onPressed: () {
                      // Handle habit editing
                      print('Edit habit: ${habit.name}');
                    },
                    tooltip: 'Edit Habit',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red.shade400),
                    onPressed: () {
                      // Handle habit deletion
                      print('Delete habit: ${habit.name}');
                      // You might want to show a confirmation dialog here
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
  }
}
