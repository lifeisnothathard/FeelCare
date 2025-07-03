import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import for kIsWeb

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // GoogleSignIn di sini telah DIBUANG sepenuhnya
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // Baris ini kini tidak wujud


  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _authErrorHandler(e);
    }
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _authErrorHandler(e);
    }
  }

  // Google Sign In (Method ini telah DIBUANG sepenuhnya)
  // Future<UserCredential?> signInWithGoogle() async {
  //   // Kod Google Sign-In telah dibuang dari sini
  //   return null; // Mengembalikan null kerana fungsi telah dibuang
  // }

  // Facebook Sign In
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FlutterFacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        return await FirebaseAuth.instance.signInWithCredential(credential);
      } else if (result.status == LoginStatus.cancelled) {
        return null;
      } else {
        throw 'Facebook login failed: ${result.message}';
      }
    } on FirebaseAuthException catch (e) {
      throw _authErrorHandler(e);
    } catch (e) {
      throw 'Facebook Sign-In failed: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // await _googleSignIn.signOut(); // Baris ini telah DIBUANG
      await FlutterFacebookAuth.instance.logOut();
    } on FirebaseAuthException catch (e) {
      throw _authErrorHandler(e);
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _authErrorHandler(e);
    }
  }

  // Error handler
  String _authErrorHandler(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}

class FlutterFacebookAuth {
  static var instance;
}

// Extensi GoogleSignIn ini telah DIBUANG sepenuhnya
// extension on GoogleSignIn {
//   Future<GoogleSignInAccount?> signIn() {
//     throw UnimplementedError('signIn() extension is not implemented.');
//   }
// }