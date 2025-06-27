import 'package:flutter/material.dart';

class AddEntryDialog extends StatelessWidget {
  final String habitName;
  final String dayNumber;
  final IconData icon;
  final Color iconColor;

  const AddEntryDialog({
    super.key,
    required this.habitName,
    required this.dayNumber,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 40),
          SizedBox(height: 16),
          Text('Habit: $habitName'),
          Text('Day: $dayNumber'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}