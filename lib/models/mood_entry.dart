// lib/models/mood_entry.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  String? id; // Nullable for when a new entry is created before being saved to Firestore
  String userId;
  DateTime date;
  int? moodRating; // e.g., 1-5 scale (optional)
  List<String> selectedEmotions; // e.g., ['Happy', 'Productive']
  String? notes; // Optional journal entry
  String? habitId; // Optional: Link to a specific habit completion
  String? habitName; // Optional: To easily display habit name without fetching full habit object
  bool? habitCompleted; // Optional: True if this entry represents a habit completion

  MoodEntry({
    this.id,
    required this.userId,
    required this.date,
    this.moodRating,
    required this.selectedEmotions,
    this.notes,
    this.habitId,
    this.habitName,
    this.habitCompleted,
  });

  // Convert a MoodEntry object into a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'moodRating': moodRating,
      'selectedEmotions': selectedEmotions,
      'notes': notes,
      'habitId': habitId,
      'habitName': habitName,
      'habitCompleted': habitCompleted,
    };
  }

  // Create a MoodEntry object from a Firestore document
  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      moodRating: data['moodRating'],
      selectedEmotions: List<String>.from(data['selectedEmotions'] ?? []),
      notes: data['notes'],
      habitId: data['habitId'],
      habitName: data['habitName'],
      habitCompleted: data['habitCompleted'],
    );
  }
}