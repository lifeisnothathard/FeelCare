import 'package:flutter/material.dart';

class EnterNewHabitBox extends StatelessWidget {
  final controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EnterNewHabitBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
        decoration: const InputDecoration(
          enabledBorder: 
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: 
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: onSave,
          child: Text(
            "Save",
            style: TextStyle(color: Colors.white),
          ),
          color:Colors.black,
          ),
          MaterialButton(
          onPressed: onCancel,
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white),
          ),
          color:Colors.black,
          ),
      ],
    );
  }
}