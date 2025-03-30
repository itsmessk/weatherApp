import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../providers/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final VoidCallback onFavoriteToggle;

  const WeatherCard({
    Key? key,
    required this.weather,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final isFavorite = weatherProvider.isCityInFavorites(weatherProvider.currentCity);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherProvider.currentCity,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.condition,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTemperatureDisplay(context),
                _buildWeatherIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureDisplay(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.temperature.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '°C',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherIcon() {
    IconData iconData;
    
    // Determine icon based on weather condition
    final condition = weather.condition.toLowerCase();
    if (condition.contains('clear') || condition.contains('sunny')) {
      iconData = Icons.wb_sunny;
    } else if (condition.contains('cloud')) {
      iconData = Icons.cloud;
    } else if (condition.contains('rain')) {
      iconData = Icons.water_drop;
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      iconData = Icons.flash_on;
    } else if (condition.contains('snow')) {
      iconData = Icons.ac_unit;
    } else if (condition.contains('mist') || condition.contains('fog')) {
      iconData = Icons.cloud_queue;
    } else {
      iconData = Icons.wb_sunny_outlined;
    }
    
    return Icon(
      iconData,
      size: 80,
      color: _getIconColor(condition),
    );
  }

  Color _getIconColor(String condition) {
    if (condition.contains('clear') || condition.contains('sunny')) {
      return Colors.orange;
    } else if (condition.contains('cloud')) {
      return Colors.grey;
    } else if (condition.contains('rain')) {
      return Colors.blue;
    } else if (condition.contains('storm') || condition.contains('thunder')) {
      return Colors.deepPurple;
    } else if (condition.contains('snow')) {
      return Colors.lightBlue;
    } else {
      return Colors.orange;
    }
  }
}
