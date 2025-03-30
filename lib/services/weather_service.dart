import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherService {
  final String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; // Replace with your API key
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final http.Client _client = http.Client();

  void dispose() {
    _client.close();
  }

  Future<Weather> getWeather(String city) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/weather?q=$city&units=metric&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load weather data');
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<List<Weather>> getForecast(String city) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/forecast?q=$city&units=metric&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        return forecastList.map((item) => Weather.fromForecastJson(item)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load forecast data');
      }
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
      throw Exception('Failed to load forecast data: $e');
    }
  }

  Future<Weather> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&units=metric&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load weather data');
      }
    } catch (e) {
      debugPrint('Error fetching weather by coordinates: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<List<Weather>> getForecastByCoordinates(double lat, double lon) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&units=metric&appid=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];
        
        return forecastList.map((item) => Weather.fromForecastJson(item)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load forecast data');
      }
    } catch (e) {
      debugPrint('Error fetching forecast by coordinates: $e');
      throw Exception('Failed to load forecast data: $e');
    }
  }
}
