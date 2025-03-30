import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cities'),
      ),
      body: weatherProvider.favoriteCities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite cities yet',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add cities to your favorites to see them here',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: weatherProvider.favoriteCities.length,
              itemBuilder: (context, index) {
                final city = weatherProvider.favoriteCities[index];
                return Dismissible(
                  key: Key(city),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    weatherProvider.removeFromFavorites(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$city removed from favorites'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            weatherProvider.addToFavorites(city);
                          },
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(city),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      weatherProvider.searchCity(city).then((_) {
                        Navigator.pop(context);
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
