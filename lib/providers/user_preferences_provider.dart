import 'package:flutter/material.dart';
import '../services/user_preferences_service.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  
  // Default preferences
  String _temperatureUnit = 'celsius';
  String _windSpeedUnit = 'kmh';
  String _theme = 'system';
  String _defaultLocation = '';
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  String get temperatureUnit => _temperatureUnit;
  String get windSpeedUnit => _windSpeedUnit;
  String get theme => _theme;
  String get defaultLocation => _defaultLocation;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isUserLoggedIn => _preferencesService.isUserLoggedIn;
  
  // Constructor
  UserPreferencesProvider() {
    loadUserPreferences();
  }
  
  // Load user preferences from Firestore
  Future<void> loadUserPreferences() async {
    if (!_preferencesService.isUserLoggedIn) return;
    
    _setLoading(true);
    
    try {
      final preferences = await _preferencesService.getUserPreferences();
      
      if (preferences != null) {
        _temperatureUnit = preferences['temperatureUnit'] ?? 'celsius';
        _windSpeedUnit = preferences['windSpeedUnit'] ?? 'kmh';
        _theme = preferences['theme'] ?? 'system';
        _defaultLocation = preferences['defaultLocation'] ?? '';
        _notificationsEnabled = preferences['notificationsEnabled'] ?? true;
      }
      
      _setError('');
    } catch (e) {
      _setError('Failed to load preferences: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Initialize user preferences when user signs up or logs in
  Future<void> initializeUserPreferences() async {
    if (!_preferencesService.isUserLoggedIn) return;
    
    _setLoading(true);
    
    try {
      await _preferencesService.initializeUserPreferences();
      await loadUserPreferences();
      _setError('');
    } catch (e) {
      _setError('Failed to initialize preferences: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Update temperature unit
  Future<void> setTemperatureUnit(String unit) async {
    if (unit != _temperatureUnit) {
      _temperatureUnit = unit;
      notifyListeners();
      
      if (_preferencesService.isUserLoggedIn) {
        try {
          await _preferencesService.updateUserPreferences({
            'temperatureUnit': unit,
          });
        } catch (e) {
          _setError('Failed to update temperature unit: $e');
        }
      }
    }
  }
  
  // Update wind speed unit
  Future<void> setWindSpeedUnit(String unit) async {
    if (unit != _windSpeedUnit) {
      _windSpeedUnit = unit;
      notifyListeners();
      
      if (_preferencesService.isUserLoggedIn) {
        try {
          await _preferencesService.updateUserPreferences({
            'windSpeedUnit': unit,
          });
        } catch (e) {
          _setError('Failed to update wind speed unit: $e');
        }
      }
    }
  }
  
  // Update theme preference
  Future<void> setTheme(String theme) async {
    if (theme != _theme) {
      _theme = theme;
      notifyListeners();
      
      if (_preferencesService.isUserLoggedIn) {
        try {
          await _preferencesService.updateUserPreferences({
            'theme': theme,
          });
        } catch (e) {
          _setError('Failed to update theme: $e');
        }
      }
    }
  }
  
  // Update default location
  Future<void> setDefaultLocation(String location) async {
    if (location != _defaultLocation) {
      _defaultLocation = location;
      notifyListeners();
      
      if (_preferencesService.isUserLoggedIn) {
        try {
          await _preferencesService.updateUserPreferences({
            'defaultLocation': location,
          });
        } catch (e) {
          _setError('Failed to update default location: $e');
        }
      }
    }
  }
  
  // Update notifications setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled != _notificationsEnabled) {
      _notificationsEnabled = enabled;
      notifyListeners();
      
      if (_preferencesService.isUserLoggedIn) {
        try {
          await _preferencesService.updateUserPreferences({
            'notificationsEnabled': enabled,
          });
        } catch (e) {
          _setError('Failed to update notifications setting: $e');
        }
      }
    }
  }
  
  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Helper method to set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
