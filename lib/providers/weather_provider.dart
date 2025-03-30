import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/weather_service.dart';
import '../services/user_preferences_service.dart';
import '../models/weather.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  Weather? _currentWeather;
  List<Weather> _forecast = [];
  String _currentCity = '';
  bool _isLoading = false;
  bool _isLoadingFavorites = false;
  String _error = '';
  List<String> _favorites = [];

  Weather? get currentWeather => _currentWeather;
  List<Weather> get forecast => _forecast;
  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  bool get isLoadingFavorites => _isLoadingFavorites;
  String get error => _error;
  List<String> get favorites => _favorites;

  WeatherProvider() {
    loadFavorites();
  }

  Future<void> getCurrentLocationWeather() async {
    _setLoading(true);
    _error = '';

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setError('Location permission permanently denied');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get city name from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final city = placemark.locality ?? 'Unknown';
        
        // Get weather for the city
        await searchCity(city);
      } else {
        _setError('Could not determine your location');
      }
    } catch (e) {
      _setError('Error getting current location: $e');
    }
  }

  Future<void> searchCity(String city) async {
    if (city.isEmpty) return;

    _setLoading(true);
    _error = '';

    try {
      // Get current weather
      final weather = await _weatherService.getWeather(city);
      
      // Get forecast
      final forecast = await _weatherService.getForecast(city);

      _currentWeather = weather;
      _forecast = forecast;
      _currentCity = city;
      _setLoading(false);
    } catch (e) {
      _setError('Error searching for city: $e');
    }
  }

  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    notifyListeners();

    try {
      if (_preferencesService.isUserLoggedIn) {
        // Load favorites from Firestore if user is logged in
        _favorites = await _preferencesService.getFavoriteCities();
      } else {
        // Fall back to shared preferences if user is not logged in
        final prefs = await SharedPreferences.getInstance();
        _favorites = prefs.getStringList('favorites') ?? [];
      }
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  Future<void> addToFavorites(String city) async {
    if (!_favorites.contains(city)) {
      _favorites.add(city);
      notifyListeners();

      try {
        if (_preferencesService.isUserLoggedIn) {
          // Save to Firestore if user is logged in
          await _preferencesService.addFavoriteCity(city);
        } else {
          // Fall back to shared preferences if user is not logged in
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('favorites', _favorites);
        }
      } catch (e) {
        print('Error adding to favorites: $e');
      }
    }
  }

  Future<void> removeFromFavorites(String city) async {
    if (_favorites.contains(city)) {
      _favorites.remove(city);
      notifyListeners();

      try {
        if (_preferencesService.isUserLoggedIn) {
          // Remove from Firestore if user is logged in
          await _preferencesService.removeFavoriteCity(city);
        } else {
          // Fall back to shared preferences if user is not logged in
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('favorites', _favorites);
        }
      } catch (e) {
        print('Error removing from favorites: $e');
      }
    }
  }

  Future<bool> isCityFavorite(String city) async {
    if (_preferencesService.isUserLoggedIn) {
      // Check in Firestore if user is logged in
      return await _preferencesService.isCityInFavorites(city);
    } else {
      // Check in local favorites if user is not logged in
      return _favorites.contains(city);
    }
  }

  bool isCityInFavorites(String city) {
    return _favorites.contains(city);
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favorites);
      notifyListeners();
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
