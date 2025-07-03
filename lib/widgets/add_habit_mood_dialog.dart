// lib/widgets/add_habit_mood_dialog.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/mood_entry.dart';
import '../services/habit_mood_service.dart';
import '../themes/colors.dart'; // Ensure this is correctly imported for AppColors

class AddHabitMoodDialog extends StatefulWidget {
  const AddHabitMoodDialog({super.key});

  @override
  State<AddHabitMoodDialog> createState() => _AddHabitMoodDialogState();
}

class _AddHabitMoodDialogState extends State<AddHabitMoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _newHabitNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedEmotions = [];
  int? _moodRating;
  String? _selectedHabitId;
  String? _selectedHabitName; // To display selected habit name
  bool _isNewHabit = false; // To toggle between adding new habit vs logging existing

  final List<String> _emotionOptions = [
    'Happy', 'Sad', 'Anxious', 'Energetic', 'Calm',
    'Stressed', 'Productive', 'Relaxed', 'Frustrated', 'Excited',
    'Bored', 'Angry', 'Grateful', 'Tired', 'Motivated',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _newHabitNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow future entries for planning? Or just up to today.
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEntry() async {
    // Validate all form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Manual validation for emotion selection
    if (_selectedEmotions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one emotion.')),
      );
      return; // Stop if no emotion is selected
    }


    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.')),
      );
      return;
    }

    final habitMoodService = Provider.of<HabitMoodService>(context, listen: false);

    try {
      String? finalHabitId = _selectedHabitId;
      String? finalHabitName = _selectedHabitName;
      bool? finalHabitCompleted = _selectedHabitId != null ? true : null; // Default: if habit selected, mark as complete

      // Handle adding a new habit if selected
      if (_isNewHabit && _newHabitNameController.text.isNotEmpty) {
        final newHabit = Habit(
          userId: userId,
          name: _newHabitNameController.text.trim(),
          creationDate: DateTime.now(),
          frequency: 'daily', // Default, can be expanded later
          goal: '1 time a day', // Default, can be expanded later
        );
        // Add the new habit and get its ID from Firestore
        // Note: The addHabit method currently doesn't return the ID.
        // If you need to link this mood entry to the newly created habit as its *first* completion,
        // you'd need to modify addHabit to return the doc ID.
        // For now, it just creates the habit separately.
        await habitMoodService.addHabit(newHabit);

        // If a new habit is added, this mood entry is NOT marking it complete
        // unless you explicitly want it to. Based on your previous comments,
        // we'll keep it as separate for now.
        finalHabitId = null;
        finalHabitName = null;
        finalHabitCompleted = null;
      }


      final moodEntry = MoodEntry(
        userId: userId,
        date: _selectedDate,
        moodRating: _moodRating, // This is currently unused, consider adding UI for it.
        selectedEmotions: _selectedEmotions,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        habitId: finalHabitId,
        habitName: finalHabitName,
        habitCompleted: finalHabitCompleted,
      );

      await habitMoodService.addMoodEntry(moodEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
        Navigator.of(context).pop(); // Close the dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the service to get habits
    final habitMoodService = Provider.of<HabitMoodService>(context);

    // Get primary color from theme for ChoiceChip's selectedColor
    final Color selectedChipColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: const Text('Add Daily Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              ListTile(
                title: Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Mood Rating / Emotions
              Text('How are you feeling today?', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0, // horizontal spacing
                runSpacing: 4.0, // vertical spacing
                children: _emotionOptions.map((emotion) {
                  final isSelected = _selectedEmotions.contains(emotion);
                  return ChoiceChip(
                    label: Text(emotion),
                    selected: isSelected,
                    selectedColor: selectedChipColor, // Use the primary color from theme
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEmotions.add(emotion);
                        } else {
                          _selectedEmotions.remove(emotion);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              // No need for explicit error text here, as validation is in _saveEntry
              // if (_selectedEmotions.isEmpty)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8.0),
              //     child: Text(
              //       'Please select at least one emotion.',
              //       style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              //     ),
              //   ),

              const SizedBox(height: 24),

              // Habit Section
              Text('Habit Entry', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              // Toggle for New Habit vs. Existing Habit
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Log Existing Habit'),
                      selected: !_isNewHabit,
                      selectedColor: selectedChipColor, // Use primary color from theme
                      onSelected: (selected) {
                        setState(() {
                          _isNewHabit = !selected;
                          _newHabitNameController.clear(); // Clear new habit field
                          _selectedHabitId = null; // Deselect existing habit
                          _selectedHabitName = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Add New Habit'),
                      selected: _isNewHabit,
                      selectedColor: selectedChipColor, // Use primary color from theme
                      onSelected: (selected) {
                        setState(() {
                          _isNewHabit = selected;
                          _selectedHabitId = null; // Deselect existing habit
                          _selectedHabitName = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isNewHabit)
                TextFormField(
                  controller: _newHabitNameController,
                  decoration: const InputDecoration(
                    labelText: 'New Habit Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isNewHabit && (value == null || value.trim().isEmpty)) {
                      return 'Please enter a habit name.';
                    }
                    return null;
                  },
                )
              else // Logging existing habit
                StreamBuilder<List<Habit>>(
                  stream: habitMoodService.getHabitsForUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading habits: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No habits found. Add a new habit first!');
                    }

                    List<Habit> habits = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Habit to Log',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedHabitId,
                      hint: const Text('Choose a habit'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedHabitId = newValue;
                          _selectedHabitName = habits.firstWhere((h) => h.id == newValue).name;
                        });
                      },
                      items: habits.map<DropdownMenuItem<String>>((Habit habit) {
                        return DropdownMenuItem<String>(
                          value: habit.id,
                          child: Text(habit.name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (!_isNewHabit && value == null) {
                          return 'Please select a habit to log.';
                        }
                        return null;
                      },
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Notes/Journal Entry
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Journal Entry (Optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveEntry,
          child: const Text('Save Entry'),
        ),
      ],
    );
  }
}