// lib/models/habit.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  String? id; // Nullable for when a new habit is created before being saved to Firestore
  String userId;
  String name;
  DateTime creationDate;
  String frequency; // e.g., 'daily', 'weekly', 'specific_days'
  List<String>? specificDays; // e.g., ['Monday', 'Wednesday'] if frequency is 'specific_days'
  String goal; // e.g., '1 time a day', '3 times a week'
  bool isActive;
  bool isCompletedToday; // Added for tracking daily completion
  DateTime? lastCompleted; // Added to store the last completion date

  Habit({
    this.id,
    required this.userId,
    required this.name,
    required this.creationDate,
    required this.frequency,
    this.specificDays,
    required this.goal,
    this.isActive = true, // Default to active
    this.isCompletedToday = false, // Default to false
    this.lastCompleted, // Nullable
  });

  // Convert a Habit object into a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'creationDate': Timestamp.fromDate(creationDate),
      'frequency': frequency,
      'specificDays': specificDays,
      'goal': goal,
      'isActive': isActive,
      'isCompletedToday': isCompletedToday, // Include in Firestore map
      'lastCompleted': lastCompleted != null ? Timestamp.fromDate(lastCompleted!) : null, // Include in Firestore map
    };
  }

  // Create a Habit object from a Firestore document
  factory Habit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Unknown Habit',
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      frequency: data['frequency'] ?? 'daily',
      specificDays: List<String>.from(data['specificDays'] ?? []),
      goal: data['goal'] ?? '',
      isActive: data['isActive'] ?? true,
      isCompletedToday: data['isCompletedToday'] ?? false, // Read from Firestore
      lastCompleted: (data['lastCompleted'] as Timestamp?)?.toDate(), // Read from Firestore
    );
  }

  // Method to create a copy with updated properties (useful for immutability)
  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? creationDate,
    String? frequency,
    List<String>? specificDays,
    String? goal,
    bool? isActive,
    bool? isCompletedToday,
    DateTime? lastCompleted,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      creationDate: creationDate ?? this.creationDate,
      frequency: frequency ?? this.frequency,
      specificDays: specificDays ?? this.specificDays,
      goal: goal ?? this.goal,
      isActive: isActive ?? this.isActive,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCompleted: lastCompleted ?? this.lastCompleted,
    );
  }
}
