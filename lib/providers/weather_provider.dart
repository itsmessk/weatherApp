import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final StorageService _storageService = StorageService();
  
  WeatherModel? _currentWeather;
  List<WeatherModel> _forecast = [];
  List<String> _favoriteCities = [];
  String _currentCity = '';
  bool _isLoading = false;
  String _error = '';
  
  WeatherModel? get currentWeather => _currentWeather;
  List<WeatherModel> get forecast => _forecast;
  List<String> get favoriteCities => _favoriteCities;
  String get currentCity => _currentCity;
  bool get isLoading => _isLoading;
  String get error => _error;

  WeatherProvider() {
    _loadFavoriteCities();
  }

  Future<void> _loadFavoriteCities() async {
    _favoriteCities = await _storageService.getFavoriteCities();
    notifyListeners();
  }

  Future<void> searchCity(String city) async {
    if (city.isEmpty) return;
    
    _setLoading(true);
    _error = '';
    
    try {
      final weather = await _weatherService.getWeatherByCity(city);
      _currentWeather = weather;
      _currentCity = city;
      
      // Get forecast data
      _forecast = await _weatherService.getForecast(city);
      
      // Cache the weather data
      await _storageService.saveWeatherData(city, weather);
      
      _setLoading(false);
    } catch (e) {
      _handleError('Error fetching weather for $city: $e');
    }
  }

  Future<void> getCurrentLocationWeather() async {
    _setLoading(true);
    _error = '';
    
    try {
      // Check location permission in a non-blocking way
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleError('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _handleError('Location permissions are permanently denied');
        return;
      }
      
      // Get current position with a timeout to prevent hanging
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Lower accuracy for faster response
        timeLimit: const Duration(seconds: 5), // Add timeout
      ).catchError((e) {
        throw Exception('Failed to get location: $e');
      });
      
      // Get address from coordinates
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude,
          localeIdentifier: 'en_US', // Add locale for consistent results
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _currentCity = place.locality ?? place.subAdministrativeArea ?? 'Unknown';
        }
      } catch (e) {
        // If geocoding fails, use coordinates as fallback
        _currentCity = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      }
      
      // Get weather for location
      final weather = await _weatherService.getWeatherByLocation(
        position.latitude, 
        position.longitude
      );
      
      _currentWeather = weather;
      
      // Get forecast data - do this in a separate try-catch to avoid failing the whole method
      try {
        _forecast = await _weatherService.getForecast(_currentCity);
      } catch (e) {
        // If forecast fails, just leave it empty
        _forecast = [];
      }
      
      // Cache the weather data
      await _storageService.saveWeatherData(_currentCity, weather);
      
      _setLoading(false);
    } catch (e) {
      _handleError('Error fetching weather for current location: $e');
    }
  }

  Future<void> addToFavorites(String city) async {
    await _storageService.addFavoriteCity(city);
    _favoriteCities = await _storageService.getFavoriteCities();
    notifyListeners();
  }

  Future<void> removeFromFavorites(String city) async {
    await _storageService.removeFavoriteCity(city);
    _favoriteCities = await _storageService.getFavoriteCities();
    notifyListeners();
  }

  Future<bool> isCityFavorite(String city) async {
    return await _storageService.isCityFavorite(city);
  }

  Future<void> loadCachedWeather(String city) async {
    final cachedWeather = await _storageService.getCachedWeatherData(city);
    if (cachedWeather != null) {
      _currentWeather = cachedWeather;
      _currentCity = city;
      notifyListeners();
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
}
