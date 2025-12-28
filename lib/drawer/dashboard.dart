import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_mood_service.dart';
import '../models/habit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<HabitMoodService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Progress")),
      body: StreamBuilder<List<Habit>>(
        stream: service.habitsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final habits = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("Consistency Score", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: habits.isEmpty ? 0 : habits.where((h) => h.isCompleted).length / habits.length,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  color: Colors.green,
                ),
                const SizedBox(height: 30),
                const Text("Longest Streaks 🔥", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final h = habits[index];
                      return Card(
                        child: ListTile(
                          title: Text(h.name),
                          trailing: Text("${h.streak} Days", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}