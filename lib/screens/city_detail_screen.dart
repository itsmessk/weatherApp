import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../models/weather.dart';
import '../widgets/weather_icon.dart';

class CityDetailScreen extends StatefulWidget {
  final String cityName;

  const CityDetailScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCityWeather();
  }

  Future<void> _loadCityWeather() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      await weatherProvider.searchCity(widget.cityName);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_error.isNotEmpty || weatherProvider.error.isNotEmpty) {
            return _buildErrorView(weatherProvider.error.isNotEmpty ? weatherProvider.error : _error);
          }

          if (weatherProvider.currentWeather == null) {
            return const Center(
              child: Text('No weather data available'),
            );
          }

          return _buildWeatherDetailView(context, weatherProvider);
        },
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCityWeather,
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailView(BuildContext context, WeatherProvider weatherProvider) {
    final weather = weatherProvider.currentWeather!;
    final isFavorite = weatherProvider.isCityInFavorites(weatherProvider.currentCity);
    
    return CustomScrollView(
      slivers: [
        // App bar with weather info
        SliverAppBar(
          expandedHeight: 300.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              widget.cityName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade300,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Weather background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        'assets/images/weather_pattern.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Weather info
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WeatherIcon(
                          condition: weather.condition,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          weather.condition,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: () async {
                final city = weatherProvider.currentCity;
                if (isFavorite) {
                  await weatherProvider.removeFromFavorites(city);
                } else {
                  await weatherProvider.addToFavorites(city);
                }
                setState(() {});
              },
            ),
          ],
        ),
        
        // Weather details
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's details
                  _buildSectionHeader('Today\'s Details'),
                  const SizedBox(height: 16),
                  _buildDetailCard(weather),
                  const SizedBox(height: 24),
                  
                  // Hourly forecast
                  _buildSectionHeader('Hourly Forecast'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: _buildHourlyForecast(weatherProvider),
                  ),
                  const SizedBox(height: 24),
                  
                  // Daily forecast
                  _buildSectionHeader('5-Day Forecast'),
                  const SizedBox(height: 16),
                  _buildDailyForecast(weatherProvider),
                  const SizedBox(height: 24),
                  
                  // Additional info
                  _buildSectionHeader('Additional Information'),
                  const SizedBox(height: 16),
                  _buildAdditionalInfo(weather),
                  const SizedBox(height: 24),
                  
                  // Last updated
                  Center(
                    child: Text(
                      'Last updated: ${DateFormat('MMM d, y • h:mm a').format(weather.lastUpdated)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailCard(dynamic weather) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              Icons.thermostat,
              'Feels Like',
              '${weather.feelsLike.toStringAsFixed(1)}°C',
            ),
            const Divider(),
            _buildDetailRow(
              Icons.water_drop,
              'Humidity',
              '${weather.humidity}%',
            ),
            const Divider(),
            _buildDetailRow(
              Icons.air,
              'Wind Speed',
              '${weather.windSpeed} km/h',
            ),
            const Divider(),
            _buildDetailRow(
              Icons.visibility,
              'Visibility',
              '${(weather.visibility / 1000).toStringAsFixed(1)} km',
            ),
            const Divider(),
            _buildDetailRow(
              Icons.compress,
              'Pressure',
              '${weather.pressure} hPa',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(WeatherProvider weatherProvider) {
    if (weatherProvider.forecast.isEmpty) {
      return const Center(
        child: Text('No hourly forecast available'),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: weatherProvider.forecast.length > 24 
          ? 24 
          : weatherProvider.forecast.length,
      itemBuilder: (context, index) {
        final hourlyWeather = weatherProvider.forecast[index];
        return _buildHourlyForecastItem(hourlyWeather);
      },
    );
  }

  Widget _buildHourlyForecastItem(dynamic hourlyWeather) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('h a').format(hourlyWeather.lastUpdated),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              WeatherIcon(
                condition: hourlyWeather.condition,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                '${hourlyWeather.temperature.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyForecast(WeatherProvider weatherProvider) {
    if (weatherProvider.forecast.isEmpty) {
      return const Center(
        child: Text('No daily forecast available'),
      );
    }

    // Group forecast by day
    final Map<String, dynamic> dailyForecasts = {};
    for (var i = 0; i < weatherProvider.forecast.length; i += 8) {
      if (i + 8 <= weatherProvider.forecast.length) {
        final date = DateFormat('E, MMM d').format(weatherProvider.forecast[i].lastUpdated);
        dailyForecasts[date] = weatherProvider.forecast[i];
      }
    }

    return Column(
      children: dailyForecasts.entries.map((entry) {
        return _buildDailyForecastItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDailyForecastItem(String date, dynamic dailyWeather) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: WeatherIcon(
                condition: dailyWeather.condition,
                size: 28,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${dailyWeather.temperature.toStringAsFixed(0)}°C',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(dynamic weather) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow(
              Icons.wb_sunny,
              'Sunrise',
              DateFormat('h:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  weather.sunrise * 1000,
                  isUtc: false,
                ),
              ),
            ),
            const Divider(),
            _buildDetailRow(
              Icons.nightlight,
              'Sunset',
              DateFormat('h:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  weather.sunset * 1000,
                  isUtc: false,
                ),
              ),
            ),
            const Divider(),
            _buildDetailRow(
              Icons.cloud,
              'Cloudiness',
              '${weather.cloudiness}%',
            ),
            const Divider(),
            _buildDetailRow(
              Icons.waves,
              'UV Index',
              '${weather.uvIndex.toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }
}
