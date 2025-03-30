import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class StorageService {
  static const String _favoriteCitiesKey = 'favorite_cities';
  static const String _themeKey = 'dark_theme';

  // Save a city to favorites
  Future<void> addFavoriteCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_favoriteCitiesKey) ?? [];
    
    if (!favorites.contains(cityName)) {
      favorites.add(cityName);
      await prefs.setStringList(_favoriteCitiesKey, favorites);
    }
  }

  // Remove a city from favorites
  Future<void> removeFavoriteCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_favoriteCitiesKey) ?? [];
    
    if (favorites.contains(cityName)) {
      favorites.remove(cityName);
      await prefs.setStringList(_favoriteCitiesKey, favorites);
    }
  }

  // Get all favorite cities
  Future<List<String>> getFavoriteCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteCitiesKey) ?? [];
  }

  // Check if a city is in favorites
  Future<bool> isCityFavorite(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList(_favoriteCitiesKey) ?? [];
    return favorites.contains(cityName);
  }

  // Save weather data for offline access
  Future<void> saveWeatherData(String cityName, WeatherModel weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weather_$cityName', jsonEncode(weather.toJson()));
  }

  // Get cached weather data
  Future<WeatherModel?> getCachedWeatherData(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final String? weatherData = prefs.getString('weather_$cityName');
    
    if (weatherData != null) {
      return WeatherModel.fromStorage(jsonDecode(weatherData));
    }
    return null;
  }

  // Save theme preference
  Future<void> setDarkTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // Get theme preference
  Future<bool> isDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
