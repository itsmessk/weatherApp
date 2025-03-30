import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

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
        // Already on home screen, just update the index
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
      case 3:
        // Navigate to profile screen
        Navigator.pushNamed(context, '/profile')
            .then((_) => setState(() => _currentIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Weather App',
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
                              // Dashboard header
                              _buildDashboardHeader(authProvider),
                              
                              const SizedBox(height: 16),
                              
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
                              
                              // Weather insights
                              _buildWeatherInsights(weatherProvider.currentWeather!),
                              
                              const SizedBox(height: 24),
                              
                              // Quick actions
                              _buildQuickActions(context),
                              
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
                                    itemCount: weatherProvider.forecast.length > 8
                                        ? 8
                                        : weatherProvider.forecast.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: ForecastCard(
                                          forecast: weatherProvider.forecast[index],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Weather map preview
                              _buildWeatherMapPreview(context),
                              
                              const SizedBox(height: 24),
                              
                              // Weather news and alerts
                              _buildWeatherNews(context),
                              
                              const SizedBox(height: 16),
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

  // Dashboard header with greeting and date
  Widget _buildDashboardHeader(AuthProvider authProvider) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final dateFormat = DateFormat('EEEE, MMMM d');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (authProvider.isAuthenticated)
                  Text(
                    '${authProvider.user?.email?.split('@').first ?? 'User'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(now),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
  
  // Weather insights section
  Widget _buildWeatherInsights(Weather weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Insights',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                icon: Icons.wb_sunny,
                title: 'UV Index',
                value: '${(weather.temperature / 8).toStringAsFixed(1)}',
                color: Colors.orange,
                subtitle: _getUVIndexDescription(weather.temperature / 8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                icon: Icons.water_drop,
                title: 'Precipitation',
                value: '${weather.humidity / 5}%',
                color: Colors.blue,
                subtitle: 'Chance of rain',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                icon: Icons.air,
                title: 'Air Quality',
                value: 'Good',
                color: Colors.green,
                subtitle: 'Low pollution',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                icon: Icons.thermostat,
                title: 'Feels Like',
                value: '${weather.feelsLike.round()}°C',
                color: Colors.red,
                subtitle: _getFeelsLikeDescription(weather.feelsLike, weather.temperature),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Quick action buttons
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              icon: Icons.search,
              label: 'Search',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.favorite,
              label: 'Favorites',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.refresh,
              label: 'Refresh',
              onTap: () {
                Provider.of<WeatherProvider>(context, listen: false)
                    .getCurrentLocationWeather();
              },
            ),
            _buildActionButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ],
    );
  }
  
  // Weather map preview
  Widget _buildWeatherMapPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather Map',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage('https://i.imgur.com/JGQFVBk.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // TODO: Navigate to weather map screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Weather Map coming soon!')),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'View Full Weather Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Weather news and alerts
  Widget _buildWeatherNews(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weather News & Alerts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Weather Advisory',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Stay hydrated and use sun protection if going outdoors today.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Show more weather alerts
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('More alerts coming soon!')),
                      );
                    },
                    child: const Text('View All Alerts'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Helper methods
  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
  
  String _getUVIndexDescription(double uvIndex) {
    if (uvIndex < 3) {
      return 'Low';
    } else if (uvIndex < 6) {
      return 'Moderate';
    } else if (uvIndex < 8) {
      return 'High';
    } else {
      return 'Very High';
    }
  }
  
  String _getFeelsLikeDescription(double feelsLike, double actualTemp) {
    final diff = feelsLike - actualTemp;
    if (diff > 3) {
      return 'Warmer';
    } else if (diff < -3) {
      return 'Colder';
    } else {
      return 'Similar';
    }
  }
  
  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
