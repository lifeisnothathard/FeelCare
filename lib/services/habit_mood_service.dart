// lib/services/habit_mood_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/habit.dart';
import '../models/mood_entry.dart';

class HabitMoodService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

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
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> markHabitAsDone(String habitId) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }

    final habitRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .doc(habitId);

    // No need to fetch the whole document if we are just updating these fields
    await habitRef.update({
      'isCompletedToday': true,
      'lastCompleted': Timestamp.fromDate(DateTime.now()),
    });

    notifyListeners(); // Notify consumers that data might have changed
  }

  // NEW METHOD: Unmark a habit as done for today
  Future<void> unmarkHabitAsDone(String habitId) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }

    final habitRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .doc(habitId);

    // Update the relevant fields to revert completion
    await habitRef.update({
      'isCompletedToday': false,
      'lastCompleted': null, // Clear the last completion date when unmarking
    });

    notifyListeners(); // Notify consumers that data might have changed
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
    notifyListeners();
  }

  Stream<List<Habit>> getHabitsForUser() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .orderBy('creationDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    });
  }

  // --- Mood Entry Operations ---
  // ... (rest of your Mood Entry methods remain unchanged) ...

  Future<void> addMoodEntry(MoodEntry entry) async {
    if (currentUserId == null) {
      throw Exception("User not logged in.");
    }
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('mood_entries')
        .add(entry.toFirestore());
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }

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
