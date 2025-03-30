import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final preferencesProvider = Provider.of<UserPreferencesProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: preferencesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (preferencesProvider.error.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.red.shade100,
                    child: Text(
                      preferencesProvider.error,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Units',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Temperature'),
                  subtitle: Text(preferencesProvider.temperatureUnit == 'celsius' 
                      ? 'Celsius (°C)' 
                      : 'Fahrenheit (°F)'),
                  leading: const Icon(Icons.thermostat),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTemperatureUnitDialog(context, preferencesProvider),
                ),
                ListTile(
                  title: const Text('Wind Speed'),
                  subtitle: Text(preferencesProvider.windSpeedUnit == 'kmh' 
                      ? 'Kilometers per hour (km/h)' 
                      : 'Miles per hour (mph)'),
                  leading: const Icon(Icons.air),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showWindSpeedUnitDialog(context, preferencesProvider),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Default Location'),
                  subtitle: Text(preferencesProvider.defaultLocation.isEmpty 
                      ? 'Use current location' 
                      : preferencesProvider.defaultLocation),
                  leading: const Icon(Icons.location_on),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDefaultLocationDialog(context, preferencesProvider),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Weather Alerts'),
                  subtitle: const Text('Receive notifications for severe weather'),
                  value: preferencesProvider.notificationsEnabled,
                  onChanged: (value) => preferencesProvider.setNotificationsEnabled(value),
                  secondary: const Icon(Icons.notifications),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                  leading: const Icon(Icons.info_outline),
                ),
              ],
            ),
    );
  }

  void _showTemperatureUnitDialog(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temperature Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Celsius (°C)'),
              value: 'celsius',
              groupValue: provider.temperatureUnit,
              onChanged: (value) {
                provider.setTemperatureUnit(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Fahrenheit (°F)'),
              value: 'fahrenheit',
              groupValue: provider.temperatureUnit,
              onChanged: (value) {
                provider.setTemperatureUnit(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _showWindSpeedUnitDialog(BuildContext context, UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wind Speed Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Kilometers per hour (km/h)'),
              value: 'kmh',
              groupValue: provider.windSpeedUnit,
              onChanged: (value) {
                provider.setWindSpeedUnit(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Miles per hour (mph)'),
              value: 'mph',
              groupValue: provider.windSpeedUnit,
              onChanged: (value) {
                provider.setWindSpeedUnit(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _showDefaultLocationDialog(BuildContext context, UserPreferencesProvider provider) {
    final TextEditingController controller = TextEditingController(text: provider.defaultLocation);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'City Name',
                hintText: 'Leave empty to use current location',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.setDefaultLocation(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
