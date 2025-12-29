import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name;
  final String emoji;
  final int score;
  final DateTime createdAt;

  Habit({required this.id, required this.name, required this.emoji, required this.score, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'emoji': emoji, 'score': score, 
    'createdAt': createdAt.toIso8601String(),
  };

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Habit(
      id: doc.id, name: data['name'], emoji: data['emoji'],
      score: data['score'], createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}