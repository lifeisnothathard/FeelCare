// lib/services/habit_mood_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';
import '../models/mood_entry.dart';

class HabitMoodService {
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
  }

  Stream<List<Habit>> getHabitsForUser() {
    if (currentUserId == null) {
      return Stream.value([]); // Return an empty stream if no user
    }
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('habits')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Habit.fromFirestore(doc))
          .toList();
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
  }

  // Get mood entries for a specific day
  Stream<List<MoodEntry>> getMoodEntriesForDay(DateTime date) {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    // Firestore stores Timestamps, so we need to query based on date range
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('mood_entries')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date', descending: true) // Order by date, newest first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();
    });
  }

  // Get all mood entries for a user (could be large, use with caution or paginate)
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
      return snapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();
    });
  }
}