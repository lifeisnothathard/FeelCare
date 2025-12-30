import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 1. Pastikan baris bawah ini TIDAK kena comment (buang //)
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  User? get currentUser => _auth.currentUser;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // 2. Letak tanda // untuk tajuk ni supaya tak error
  // Biometric Authentication
  Future<bool> authenticate() async {
    try {
      // Pastikan package local_auth dah ada dalam pubspec.yaml
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to open FeelCare',
        options: const AuthenticationOptions(
          biometricOnly: true, 
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint("Biometric Error: $e");
      return false;
    }
  }

  Future<void> login(String email, String pass) async {
    await _auth.signInWithEmailAndPassword(email: email, password: pass);
    notifyListeners();
  }

  Future<void> signUp(String email, String pass, String name) async {
    UserCredential res = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    await res.user?.updateDisplayName(name);
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    await _auth.currentUser?.updateDisplayName(newName);
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}