import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitService extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _box = Hive.box('feelcare_box');

  // Returns a list of habits from Hive
  List get habits => _box.values.toList();

  Future<void> addHabit({
    required String name, 
    required String emoji, 
    required int score, 
    required String note, 
    required String sticker
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'emoji': emoji,
      'score': score,
      'note': note,
      'sticker': sticker,
      'date': DateTime.now().toIso8601String(),
    };

    await _box.add(entry);
    if (user != null) {
      await _db.collection('users').doc(user.uid).collection('habits').add(entry);
    }
    notifyListeners();
  }

  // FIXED DELETE: Search by ID instead of index
  Future<void> deleteHabit(String id) async {
    // 1. Delete from Hive
    final Map<dynamic, dynamic> habitsMap = _box.toMap();
    dynamic keyToDelete;

    habitsMap.forEach((key, value) {
      if (value['id'] == id) {
        keyToDelete = key;
      }
    });

    if (keyToDelete != null) {
      await _box.delete(keyToDelete);
    }

    // 2. Delete from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var snapshot = await _db
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('id', isEqualTo: id)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
    
    notifyListeners();
  }
}