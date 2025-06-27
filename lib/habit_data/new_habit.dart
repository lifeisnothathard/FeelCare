// lib/habit_data/new_habit.dart
import 'package:provider/provider.dart'; // Import Provider
import 'package:flutter/material.dart';
import 'package:feelcare/themes/colors.dart'; // Correct import
import 'package:feelcare/services/habit_mood_service.dart'; // Import your service
import 'package:feelcare/models/habit.dart'; // Import your Habit model

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the HabitMoodService using Provider
    final habitMoodService = Provider.of<HabitMoodService>(context);

    // Use StreamBuilder to listen for changes in habits
    return StreamBuilder<List<Habit>>(
      stream: habitMoodService.getHabitsForUser(), // This method should fetch habits
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700])),
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
              color: AppColors.getAdaptiveTextColor(context), // <--- CHANGE THIS LINE
            ),
            const SizedBox(height: 20),
            Text(
              'Your Habits List Will Appear Here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.getAdaptiveTextColor(context), // Also update this
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Start adding new habits using the "+" button.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getAdaptiveTextColor(context).withOpacity(0.7), // And this
              ),
            ),
          ],
        ),
      ),
    );
    } else {
          // If there are habits, display them in a ListView
          final habits = snapshot.data!;
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(habit.name),
                  subtitle: Text('Goal: ${habit.goal} | Frequency: ${habit.frequency}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[400]),
                    onPressed: () async {
                      // Add logic to delete habit
                      await habitMoodService.deleteHabit(habit.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${habit.name} deleted')),
                      );
                    },
                  ),
                  // You can add more details or actions here
                ),
              );
            },
          );
        }
      },
    );
  }
}

  
