import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback onFavoriteToggle;

  const WeatherCard({
    Key? key,
    required this.weather,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

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
                // City name and country
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      weather.country,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                // Favorite button
                FutureBuilder<bool>(
                  future: weatherProvider.isCityFavorite(weather.cityName),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: onFavoriteToggle,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Temperature and condition
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      weather.condition,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                // Weather icon
                Image.network(
                  'https:${weather.conditionIcon}',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  cacheWidth: 160,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.cloud,
                      size: 80,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
