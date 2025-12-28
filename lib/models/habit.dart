import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name;
  final String mood;
  final int streak;
  final bool isCompleted;

  Habit({
    required this.id,
    required this.name,
    required this.mood,
    required this.streak,
    required this.isCompleted,
  });

  // This converts Firebase data into a Habit object
  factory Habit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id,
      name: data['name'] ?? 'Untitled',
      mood: data['mood'] ?? '😊',
      streak: data['streak'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}