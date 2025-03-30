import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/weather.dart';
import '../providers/weather_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/forecast_card.dart';

class CityDetailsScreen extends StatefulWidget {
  final String cityName;

  const CityDetailsScreen({
    Key? key,
    required this.cityName,
  }) : super(key: key);

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCityData();
  }

  Future<void> _loadCityData() async {
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
          _error = 'Failed to load weather data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: widget.cityName,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCityData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: SpinKitPulse(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : _error.isNotEmpty
              ? _buildErrorView()
              : _buildCityDetailsView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadCityData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCityDetailsView() {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.currentWeather;
    
    if (weather == null) {
      return const Center(
        child: Text('No weather data available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero weather section with gradient background
          _buildHeroWeatherSection(weather),
          
          // Weather details cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather details
                _buildWeatherDetailsSection(weather),
                
                const SizedBox(height: 24),
                
                // Hourly forecast
                _buildHourlyForecastSection(weatherProvider),
                
                const SizedBox(height: 24),
                
                // Daily forecast
                _buildDailyForecastSection(weatherProvider),
                
                const SizedBox(height: 24),
                
                // Additional information
                _buildAdditionalInfoSection(weather),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroWeatherSection(Weather weather) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1565C0),
            Color(0xFF0D47A1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cubes.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          
          // Weather content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '°C',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  weather.description,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Feels like ${weather.feelsLike.round()}°C',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('EEEE, d MMMM').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsSection(Weather weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.water_drop,
                title: 'Humidity',
                value: '${weather.humidity}%',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.air,
                title: 'Wind',
                value: '${weather.windSpeed} km/h',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailCard(
                icon: Icons.compress,
                title: 'Pressure',
                value: '${weather.pressure} hPa',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailCard(
                icon: Icons.visibility,
                title: 'Visibility',
                value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecastSection(WeatherProvider weatherProvider) {
    final hourlyForecast = weatherProvider.forecast.take(24).toList();
    
    if (hourlyForecast.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final forecast = hourlyForecast[index];
              final time = DateFormat('HH:mm').format(forecast.date);
              
              return Card(
                margin: const EdgeInsets.only(right: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        _getWeatherIcon(forecast.description),
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${forecast.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastSection(WeatherProvider weatherProvider) {
    // Group forecast by day and get the min/max temperature for each day
    final Map<String, List<Weather>> dailyForecasts = {};
    
    for (var forecast in weatherProvider.forecast) {
      final day = DateFormat('yyyy-MM-dd').format(forecast.date);
      if (!dailyForecasts.containsKey(day)) {
        dailyForecasts[day] = [];
      }
      dailyForecasts[day]!.add(forecast);
    }
    
    if (dailyForecasts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Create a list of daily forecasts with min/max temperatures
    final List<MapEntry<String, Map<String, dynamic>>> dailyForecastList = [];
    
    dailyForecasts.forEach((day, forecasts) {
      final minTemp = forecasts.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
      final maxTemp = forecasts.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
      final description = forecasts[forecasts.length ~/ 2].description;
      
      dailyForecastList.add(
        MapEntry(
          day,
          {
            'minTemp': minTemp,
            'maxTemp': maxTemp,
            'description': description,
          },
        ),
      );
    });
    
    // Sort by date
    dailyForecastList.sort((a, b) => a.key.compareTo(b.key));
    
    // Take only the next 5 days
    final nextDays = dailyForecastList.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5-Day Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...nextDays.map((entry) {
          final date = DateTime.parse(entry.key);
          final dayName = DateFormat('EEEE').format(date);
          final forecast = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    _getWeatherIcon(forecast['description']),
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${forecast['minTemp'].round()}°',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.red],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${forecast['maxTemp'].round()}°',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(Weather weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.wb_sunny,
                  title: 'Sunrise',
                  value: DateFormat('HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(weather.sunrise * 1000),
                  ),
                ),
                const Divider(),
                _buildInfoRow(
                  icon: Icons.wb_twilight,
                  title: 'Sunset',
                  value: DateFormat('HH:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(weather.sunset * 1000),
                  ),
                ),
                const Divider(),
                _buildInfoRow(
                  icon: Icons.cloud,
                  title: 'Cloudiness',
                  value: '${weather.clouds}%',
                ),
                if (weather.rain != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.umbrella,
                    title: 'Rain (last 3h)',
                    value: '${weather.rain} mm',
                  ),
                ],
                if (weather.snow != null) ...[
                  const Divider(),
                  _buildInfoRow(
                    icon: Icons.ac_unit,
                    title: 'Snow (last 3h)',
                    value: '${weather.snow} mm',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    
    if (desc.contains('clear') || desc.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (desc.contains('cloud')) {
      return Icons.cloud;
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return Icons.umbrella;
    } else if (desc.contains('thunderstorm')) {
      return Icons.flash_on;
    } else if (desc.contains('snow')) {
      return Icons.ac_unit;
    } else if (desc.contains('mist') || desc.contains('fog')) {
      return Icons.cloud_queue;
    } else {
      return Icons.wb_cloudy;
    }
  }
}
