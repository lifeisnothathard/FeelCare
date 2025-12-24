import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_mood_service.dart';

class AddHabitMoodDialog extends StatefulWidget {
  const AddHabitMoodDialog({super.key});

  @override
  State<AddHabitMoodDialog> createState() => _AddHabitMoodDialogState();
}

class _AddHabitMoodDialogState extends State<AddHabitMoodDialog> {
  final TextEditingController _controller = TextEditingController();
  String selectedMood = "😊";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Habit"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _controller, decoration: const InputDecoration(hintText: "What's the habit?")),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["😊", "😐", "😔", "😡"].map((m) => GestureDetector(
              onTap: () => setState(() => selectedMood = m),
              child: Text(m, style: TextStyle(fontSize: 30, backgroundColor: selectedMood == m ? Colors.green.withOpacity(0.2) : null)),
            )).toList(),
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            context.read<HabitMoodService>().addHabit(_controller.text, selectedMood);
            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}