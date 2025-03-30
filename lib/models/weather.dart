class Weather {
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final int cloudiness;
  final int sunrise;
  final int sunset;
  final double uvIndex;
  final DateTime lastUpdated;

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    required this.lastUpdated,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      visibility: json['visibility'] as int,
      cloudiness: json['clouds']['all'] as int,
      sunrise: json['sys']['sunrise'] as int,
      sunset: json['sys']['sunset'] as int,
      uvIndex: json['uvi'] != null ? (json['uvi'] as num).toDouble() : 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  factory Weather.fromForecastJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      condition: json['weather'][0]['main'] as String,
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      visibility: json['visibility'] as int,
      cloudiness: json['clouds']['all'] as int,
      sunrise: 0, // Not available in forecast data
      sunset: 0, // Not available in forecast data
      uvIndex: 0.0, // Not available in forecast data
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }
}
