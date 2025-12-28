import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class HabitMoodService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // READ: Get live data
  Stream<List<Habit>> get habitsStream {
    String uid = _auth.currentUser?.uid ?? '';
    return _db
        .collection('users')
        .doc(uid)
        .collection('habits')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList());
  }

  // CREATE: Add new habit
  Future<void> addHabit(String name, String mood) async {
    String uid = _auth.currentUser?.uid ?? '';
    await _db.collection('users').doc(uid).collection('habits').add({
      'name': name,
      'mood': mood,
      'streak': 0,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE: Toggle completion and increase streak
  Future<void> toggleHabit(Habit habit) async {
    String uid = _auth.currentUser?.uid ?? '';
    int newStreak = habit.isCompleted ? habit.streak : habit.streak + 1;
    
    await _db.collection('users').doc(uid).collection('habits').doc(habit.id).update({
      'isCompleted': !habit.isCompleted,
      'streak': newStreak,
    });
  }

  // DELETE
  Future<void> deleteHabit(String habitId) async {
    String uid = _auth.currentUser?.uid ?? '';
    await _db.collection('users').doc(uid).collection('habits').doc(habitId).delete();
  }
}