import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/navigation_bar.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Get current location weather when the app starts, but with a slight delay
    // to allow the UI to render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a small delay to ensure UI is fully rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Provider.of<WeatherProvider>(context, listen: false)
              .getCurrentLocationWeather();
        }
      });
    });
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;
    
    switch (index) {
      case 0:
        // Already on home screen, do nothing
        setState(() => _currentIndex = index);
        break;
      case 1:
        // Navigate to search screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case 2:
        // Navigate to favorites screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh weather data',
            onPressed: () {
              if (weatherProvider.currentCity.isNotEmpty) {
                weatherProvider.searchCity(weatherProvider.currentCity);
              } else {
                weatherProvider.getCurrentLocationWeather();
              }
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // Theme toggle button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: weatherProvider.isLoading
          ? Center(
              child: SpinKitPulse(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : weatherProvider.error.isNotEmpty
              ? Center(
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
                          weatherProvider.error,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          weatherProvider.getCurrentLocationWeather();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : weatherProvider.currentWeather == null
                  ? const Center(
                      child: Text('No weather data available'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (weatherProvider.currentCity.isNotEmpty) {
                          await weatherProvider
                              .searchCity(weatherProvider.currentCity);
                        } else {
                          await weatherProvider.getCurrentLocationWeather();
                        }
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Current weather card
                              WeatherCard(
                                weather: weatherProvider.currentWeather!,
                                onFavoriteToggle: () async {
                                  final city = weatherProvider.currentCity;
                                  final isFavorite = await weatherProvider
                                      .isCityFavorite(city);
                                  if (isFavorite) {
                                    await weatherProvider
                                        .removeFromFavorites(city);
                                  } else {
                                    await weatherProvider.addToFavorites(city);
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              // Forecast section
                              if (weatherProvider.forecast.isNotEmpty) ...[
                                Text(
                                  'Forecast',
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: weatherProvider.forecast.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 16.0),
                                        child: ForecastCard(
                                          weather:
                                              weatherProvider.forecast[index],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Additional weather details
                              if (weatherProvider.currentWeather != null) ...[
                                Text(
                                  'Details',
                                  style:
                                      Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 16),
                                _buildDetailsCard(
                                    weatherProvider.currentWeather!),
                              ],
                              
                              const SizedBox(height: 16),
                              
                              // Last updated info
                              if (weatherProvider.currentWeather != null)
                                Center(
                                  child: Text(
                                    'Last updated: ${DateFormat('MMM d, y • h:mm a').format(weatherProvider.currentWeather!.lastUpdated)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
      bottomNavigationBar: WeatherNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (weatherProvider.currentCity.isNotEmpty) {
            weatherProvider.searchCity(weatherProvider.currentCity);
          } else {
            weatherProvider.getCurrentLocationWeather();
          }
        },
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDetailsCard(dynamic weather) {
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
}
