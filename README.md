# Weather App

A beautiful and functional weather application built with Flutter that allows users to check current weather conditions and forecasts for different cities around the world.

## Features

- **Current Weather**: View current weather conditions including temperature, condition, humidity, wind speed, and more
- **Weather Forecast**: See the weather forecast for the next few days
- **Location-based Weather**: Get weather data for your current location
- **Search Functionality**: Search for weather in any city worldwide
- **Favorites**: Save your favorite cities for quick access
- **Dark/Light Theme**: Toggle between dark and light themes based on your preference
- **Offline Support**: Access previously fetched weather data when offline

## Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- An API key from [WeatherAPI.com](https://www.weatherapi.com/)

### Setup

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Get your API key from [WeatherAPI.com](https://www.weatherapi.com/)
4. Open `lib/services/weather_service.dart` and replace `YOUR_API_KEY` with your actual API key:

```dart
final String apiKey = 'YOUR_API_KEY';
```

5. Run the app with `flutter run`

## Usage

- When the app starts, it will attempt to get weather data for your current location
- Use the search icon in the app bar to search for a specific city
- Tap the heart icon to add a city to your favorites
- Access your favorite cities by tapping the favorites icon in the app bar
- Toggle between dark and light themes using the theme icon in the app bar
- Pull down on the main screen to refresh the weather data

## Dependencies

- http: For making API requests
- provider: For state management
- shared_preferences: For storing favorite cities and theme preference
- geolocator & geocoding: For getting the user's current location
- flutter_spinkit: For loading animations
- intl: For date formatting

## License

This project is open source and available under the [MIT License](LICENSE).
