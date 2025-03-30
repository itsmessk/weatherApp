import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_preferences_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  User? _user;
  bool _isLoading = false;
  String _error = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    try {
      _authService.authStateChanges.listen((User? user) {
        _user = user;
        notifyListeners();
        
        // Initialize user preferences when user logs in
        if (user != null) {
          _preferencesService.initializeUserPreferences();
        }
      });
    } catch (e) {
      _handleError("Error initializing auth state: $e");
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = '';
    
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      
      // Initialize user preferences
      if (_user != null) {
        await _preferencesService.initializeUserPreferences();
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      _handleError(_authService.getMessageFromErrorCode(e));
      return false;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _error = '';
    
    try {
      await _authService.registerWithEmailAndPassword(email, password);
      _setLoading(false);
      
      // Initialize user preferences for new user
      if (_user != null) {
        await _preferencesService.initializeUserPreferences();
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      _handleError(_authService.getMessageFromErrorCode(e));
      return false;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _error = '';
    
    try {
      await _authService.signOut();
      _setLoading(false);
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = '';
    
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleError(_authService.getMessageFromErrorCode(e));
      return false;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
