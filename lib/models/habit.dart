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

  Habit({
    this.id,
    required this.userId,
    required this.name,
    required this.creationDate,
    required this.frequency,
    this.specificDays,
    required this.goal,
    this.isActive = true, // Default to active
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
    );
  }
}