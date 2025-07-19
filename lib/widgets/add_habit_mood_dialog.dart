// lib/widgets/add_habit_mood_dialog.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/mood_entry.dart';
import '../services/habit_mood_service.dart';
import '../themes/colors.dart'; // Ensure this is correctly imported for AppColors

class AddHabitMoodDialog extends StatefulWidget {
  final String initialEntryType; // Add this to receive initial tab context

  const AddHabitMoodDialog({
    super.key,
    this.initialEntryType = 'mood', // Default to 'mood' if not provided (or 'habit' if preferred)
  });

  @override
  State<AddHabitMoodDialog> createState() => _AddHabitMoodDialogState();
}

class _AddHabitMoodDialogState extends State<AddHabitMoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _newHabitNameController = TextEditingController();
  final TextEditingController _moodRatingController = TextEditingController(); // Controller for mood rating

  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedEmotions = [];
  int? _moodRating; // This will store the parsed integer from _moodRatingController
  String? _selectedHabitId;
  String? _selectedHabitName; // To display selected habit name
  bool _isNewHabit = false; // To toggle between adding new habit vs logging existing
  bool _habitCompleted = false; // New state for marking existing habit as completed

  final List<String> _emotionOptions = [
    'Happy', 'Sad', 'Anxious', 'Energetic', 'Calm',
    'Stressed', 'Productive', 'Relaxed', 'Frustrated', 'Excited',
    'Bored', 'Angry', 'Grateful', 'Tired', 'Motivated',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize _isNewHabit based on the initialEntryType passed from HomePage
    _isNewHabit = (widget.initialEntryType == 'habit');
  }

  @override
  void dispose() {
    _notesController.dispose();
    _newHabitNameController.dispose();
    _moodRatingController.dispose(); // Dispose mood rating controller
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Current time for Kuala Terengganu, Terengganu, Malaysia is Friday, July 18, 2025 at 2:32:04 PM +08.
    // Ensure date picker doesn't go beyond today for historical entries, or future for planning.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023), // Arbitrary start date
      lastDate: DateTime.now(), // Allow selection only up to today
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showWarningDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the warning dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _saveEntry() async {
    // Validate all form fields
    if (!_formKey.currentState!.validate()) {
      print('[_saveEntry] - Form validation failed.');
      return;
    }

    // Manual validation for emotion selection
    if (_selectedEmotions.isEmpty) {
      print('[_saveEntry] - No emotions selected. Showing warning dialog.');
      _showWarningDialog('Missing Selection', 'Please select at least one emotion.');
      return; // Stop if no emotion is selected
    }

    // Manual validation for mood rating
    final parsedMoodRating = int.tryParse(_moodRatingController.text);
    if (parsedMoodRating == null || parsedMoodRating < 1 || parsedMoodRating > 10) {
      _showWarningDialog('Invalid Mood Rating', 'Please enter a mood rating between 1 and 10.');
      return;
    }
    _moodRating = parsedMoodRating; // Update state variable with valid parsed value


    print('[_saveEntry] - Starting save process.');

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
      }
      print('[_saveEntry] - User not logged in. Aborting.');
      return;
    }

    final habitMoodService = Provider.of<HabitMoodService>(context, listen: false);

    try {
      String? finalHabitId = _selectedHabitId;
      String? finalHabitName = _selectedHabitName;
      bool? finalHabitCompleted = _habitCompleted ? true : null; // Use new _habitCompleted state

      if (_isNewHabit) {
        if (_newHabitNameController.text.trim().isEmpty) {
           _showWarningDialog('Missing Habit Name', 'Please enter a name for the new habit.');
           return;
        }
        final newHabit = Habit(
          userId: userId,
          name: _newHabitNameController.text.trim(),
          creationDate: DateTime.now(),
          frequency: 'daily', // Default frequency for new habit from dialog
          goal: '1 time a day', // Default goal for new habit from dialog
        );
        print('[_saveEntry] - Adding new habit: ${newHabit.name}');
        // Call addHabit, but don't set finalHabitId/Name/Completed
        // because the mood entry is about *this* new habit, not an existing one being logged.
        await habitMoodService.addHabit(newHabit);
        // If a new habit is added, the mood entry is typically NOT linked to it
        // as a 'completed' instance *at the same time* of creation, but rather
        // it signifies the creation of the habit itself.
        // If you want to log the newly created habit as completed *today*,
        // you would need another mechanism or a more complex MoodEntry model.
        // For now, if a new habit is added, we won't link it to the mood entry's habit fields.
        finalHabitId = null;
        finalHabitName = null;
        finalHabitCompleted = null;
        print('[_saveEntry] - New habit added. Not associating with mood entry habit fields.');
      } else { // Logging an existing habit
        if (_selectedHabitId == null) {
          _showWarningDialog('No Habit Selected', 'Please select an existing habit to log.');
          return;
        }
        // If an existing habit is selected, then finalHabitId and finalHabitName are already set
        // and finalHabitCompleted is determined by the _habitCompleted checkbox.
        print('[_saveEntry] - Logging existing habit: $finalHabitName (ID: $finalHabitId), Completed: $finalHabitCompleted');
      }

      final moodEntry = MoodEntry(
        userId: userId,
        date: _selectedDate,
        moodRating: _moodRating, // Use the parsed mood rating
        selectedEmotions: _selectedEmotions,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        habitId: finalHabitId,
        habitName: finalHabitName,
        habitCompleted: finalHabitCompleted,
      );

      print('[_saveEntry] - Attempting to add mood entry: $moodEntry');
      await habitMoodService.addMoodEntry(moodEntry);
      print('[_saveEntry] - Mood entry added successfully!');

      // --- CRITICAL CHANGE: Using rootNavigator: true ---
      if (mounted) {
        print('[_saveEntry] - Context is mounted. Attempting to pop dialog from rootNavigator.');
        Navigator.of(context, rootNavigator: true).pop(); // <--- THIS IS THE KEY CHANGE
        print('[_saveEntry] - Dialog pop initiated (rootNavigator).');

        // Show success message AFTER the dialog has been told to close
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully!')),
        );
        print('[_saveEntry] - Success SnackBar shown.');
      } else {
        print('[_saveEntry] - Context is NOT mounted after save. Cannot pop dialog or show SnackBar.');
      }
      // --- END CRITICAL CHANGE ---

    } catch (e) {
      print('[_saveEntry] - Error saving entry: $e');
      if (mounted) {
        // Ensure error message is still visible
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
    print('[_saveEntry] - Save process finished.');
  }

  @override
  Widget build(BuildContext context) {
    final habitMoodService = Provider.of<HabitMoodService>(context);
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
              // Mood Rating Input
              TextFormField(
                controller: _moodRatingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mood Rating (1-10)',
                  hintText: 'e.g., 7',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a mood rating.';
                  }
                  final int? rating = int.tryParse(value);
                  if (rating == null || rating < 1 || rating > 10) {
                    return 'Rating must be between 1 and 10.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Emotion Chips
              Text('Select Emotions (at least one):', style: Theme.of(context).textTheme.titleSmall),
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
                          _habitCompleted = false; // Reset habit completed state
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
                          _habitCompleted = false; // Reset habit completed state
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<List<Habit>>(
                      stream: habitMoodService.getHabitsForUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text('Error loading habits: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error));
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
                    const SizedBox(height: 16),
                    // Checkbox to mark existing habit as completed for today
                    if (_selectedHabitId != null) // Only show if an existing habit is selected
                      Row(
                        children: [
                          Checkbox(
                            value: _habitCompleted,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _habitCompleted = newValue ?? false;
                              });
                            },
                          ),
                          const Text('Mark as Completed Today'),
                        ],
                      ),
                  ],
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
          onPressed: () {
            print('[_AddHabitMoodDialogState] - Cancel button pressed. Popping dialog from rootNavigator.');
            Navigator.of(context, rootNavigator: true).pop(); // <--- Also add rootNavigator: true here
          },
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