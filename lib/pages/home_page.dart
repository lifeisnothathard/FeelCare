import 'package:feelcare/pages/habits_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_mood_service.dart';
import '../models/habit.dart';
import 'add_habit_mood_dialog.dart';
import '../drawer/dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<HabitMoodService>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("FeelCare", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: "Habits"),
              Tab(icon: Icon(Icons.bar_chart), text: "Progress"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHabitTab(service),
            const DashboardPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => showDialog(context: context, builder: (c) => const AddHabitMoodDialog()),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHabitTab(HabitMoodService service) {
    return Column(
      children: [
        // --- SIMPLE HORIZONTAL CALENDAR ---
        Container(
          height: 100,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              return Container(
                width: 60,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: index == 0 ? Colors.green : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Day", style: TextStyle(color: index == 0 ? Colors.white : Colors.black)),
                    Text("${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: index == 0 ? Colors.white : Colors.black)),
                  ],
                ),
              );
            },
          ),
        ),
        
        // --- HABIT LIST ---
        Expanded(
          child: StreamBuilder<List<Habit>>(
            stream: service.habitsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final habits = snapshot.data!;
              if (habits.isEmpty) return const Center(child: Text("No habits for today. Add one!"));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final h = habits[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Checkbox(
                        activeColor: Colors.green,
                        value: h.isCompleted,
                        onChanged: (_) => service.toggleHabit(h),
                      ),
                      title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${h.mood} • Streak: ${h.streak} Days 🔥"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => service.deleteHabit(h.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}