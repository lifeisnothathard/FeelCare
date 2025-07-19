// lib/services/habit_mood_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for ChangeNotifier

import '../models/habit.dart';
import '../models/mood_entry.dart';

class HabitMoodService extends ChangeNotifier {
  // Extend ChangeNotifier
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Helper to get the current user's UID
  String? get currentUserId => currentUser?.uid;

  // --- Habit Operations ---

  Future<void> addHabit(Habit habit) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .add(habit.toFirestore());
    notifyListeners(); // Notify listeners after adding a habit
  }

  Future<void> updateHabit(Habit habit) async {
    if (currentUserId == null || habit.id == null) {
      throw Exception("User not logged in or habit ID is missing.");
    }
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .doc(habit.id)
        .update(habit.toFirestore());
    notifyListeners(); // Notify listeners after updating a habit
  }

  Future<void> deleteHabit(String habitId) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .doc(habitId)
        .delete();
    notifyListeners(); // Notify listeners after deleting a habit
  }

  // getHabitsForUser() remains a Stream, so it will automatically push updates
  // when the Firestore collection changes. No explicit notifyListeners() needed here
  // because the Stream already handles reactivity.
  Stream<List<Habit>> getHabitsForUser() {
    if (currentUserId == null) {
      return Stream.value([]); // Return an empty stream if no user
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .orderBy('creationDate', descending: true) // <--- CHANGE THIS LINE
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    });
  }

  // --- Mood Entry Operations ---

  Future<void> addMoodEntry(MoodEntry entry) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('mood_entries')
        .add(entry.toFirestore());
    notifyListeners(); // Notify listeners after adding a mood entry
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    if (currentUserId == null || entry.id == null) {
      throw Exception("User not logged in or mood entry ID is missing.");
    }
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('mood_entries')
        .doc(entry.id)
        .update(entry.toFirestore());
    notifyListeners(); // Notify listeners after updating a mood entry
  }

  Future<void> deleteMoodEntry(String entryId) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('mood_entries')
        .doc(entryId)
        .delete();
    notifyListeners(); // Notify listeners after deleting a mood entry
  }

  // getMoodEntriesForDay() and getAllMoodEntriesForUser() remain Streams,
  // so they will automatically push updates.
  Stream<List<MoodEntry>> getMoodEntriesForDay(DateTime date) {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('mood_entries')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
    });
  }

  Stream<List<MoodEntry>> getAllMoodEntriesForUser() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('mood_entries')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
    });
  }
}
