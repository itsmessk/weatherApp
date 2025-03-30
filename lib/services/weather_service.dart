import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // API key from WeatherAPI.com
  final String apiKey = '3333e945a3dc4f3198f190338252303';
  final String baseUrl = 'https://api.weatherapi.com/v1';
  
  // Create a client with timeout
  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 10);

  Future<WeatherModel> getWeatherByCity(String city) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/current.json?key=$apiKey&q=$city&aqi=no'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data for $city: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to load weather data for $city: $e');
    }
  }

  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/current.json?key=$apiKey&q=$lat,$lon&aqi=no'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data for location: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to load weather data for location: $e');
    }
  }

  Future<List<WeatherModel>> getForecast(String city, {int days = 3}) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$city&days=$days&aqi=no'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastDays = data['forecast']['forecastday'];
        
        return forecastDays.map((day) {
          // Create a combined data structure that matches our model
          final combinedData = {
            'location': data['location'],
            'current': {
              'avgtemp_c': day['day']['avgtemp_c'],
              'avghumidity': day['day']['avghumidity'],
              'maxwind_kph': day['day']['maxwind_kph'],
            },
            'condition': day['day']['condition'],
            'date': day['date'],
          };
          
          return WeatherModel.fromForecastJson(combinedData);
        }).toList();
      } else {
        throw Exception('Failed to load forecast data for $city: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to load forecast data for $city: $e');
    }
  }

  String getWeatherIconUrl(String iconCode) {
    // WeatherAPI.com provides full URLs for icons
    return 'https:$iconCode';
  }
  
  // Dispose of the client when no longer needed
  void dispose() {
    _client.close();
  }
}
