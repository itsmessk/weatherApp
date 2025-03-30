import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth change user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email & password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase sign in error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected sign in error: $e');
      rethrow;
    }
  }

  // Register with email & password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase registration error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected registration error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase reset password error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected reset password error: $e');
      rethrow;
    }
  }

  // Get error message from Firebase error code
  String getMessageFromErrorCode(FirebaseAuthException error) {
    debugPrint('Handling Firebase error code: ${error.code}');
    
    switch (error.code) {
      case "invalid-email":
        return "Your email address appears to be malformed.";
      case "wrong-password":
        return "Your password is incorrect.";
      case "user-not-found":
        return "User with this email doesn't exist.";
      case "user-disabled":
        return "User with this email has been disabled.";
      case "too-many-requests":
        return "Too many requests. Try again later.";
      case "operation-not-allowed":
        return "Signing in with Email and Password is not enabled.";
      case "email-already-in-use":
        return "An account already exists for this email.";
      case "weak-password":
        return "Password should be at least 6 characters.";
      case "network-request-failed":
        return "Network error. Check your internet connection.";
      case "invalid-credential":
        return "The credential is malformed or has expired.";
      case "account-exists-with-different-credential":
        return "An account already exists with the same email address but different sign-in credentials.";
      default:
        return error.message ?? "An undefined error occurred.";
    }
  }
}
