import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';
import 'weather_icon.dart';

class ForecastCard extends StatelessWidget {
  final Weather forecast;

  const ForecastCard({
    Key? key,
    required this.forecast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E, MMM d').format(forecast.lastUpdated),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            WeatherIcon(
              condition: forecast.condition,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              '${forecast.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              forecast.condition,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
