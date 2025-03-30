class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final String condition;
  final String conditionIcon;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final DateTime lastUpdated;
  final DateTime? date; // For forecast data

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.conditionIcon,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.lastUpdated,
    this.date,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['location']['name'],
      country: json['location']['country'],
      temperature: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      conditionIcon: json['current']['condition']['icon'],
      feelsLike: json['current']['feelslike_c'].toDouble(),
      humidity: json['current']['humidity'],
      windSpeed: json['current']['wind_kph'].toDouble(),
      lastUpdated: DateTime.parse(json['current']['last_updated']),
    );
  }

  factory WeatherModel.fromForecastJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['location']['name'],
      country: json['location']['country'],
      temperature: (json['current']['avgtemp_c'] ?? 0).toDouble(),
      condition: json['condition']['text'],
      conditionIcon: json['condition']['icon'],
      feelsLike: (json['current']['avgtemp_c'] ?? 0).toDouble(), // Approximation
      humidity: (json['current']['avghumidity'] ?? 0).toInt(),
      windSpeed: (json['current']['maxwind_kph'] ?? 0).toDouble(),
      lastUpdated: DateTime.now(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'condition': condition,
      'conditionIcon': conditionIcon,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'lastUpdated': lastUpdated.toIso8601String(),
      'date': date?.toIso8601String(),
    };
  }

  factory WeatherModel.fromStorage(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'],
      country: json['country'],
      temperature: json['temperature'],
      condition: json['condition'],
      conditionIcon: json['conditionIcon'],
      feelsLike: json['feelsLike'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }
}
