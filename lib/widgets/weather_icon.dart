import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String condition;
  final double size;
  final Color? color;

  const WeatherIcon({
    Key? key,
    required this.condition,
    this.size = 50,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(),
      size: size,
      color: color,
    );
  }

  IconData _getIconData() {
    final lowercaseCondition = condition.toLowerCase();
    
    if (lowercaseCondition.contains('clear') || lowercaseCondition.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (lowercaseCondition.contains('cloud')) {
      if (lowercaseCondition.contains('scattered') || lowercaseCondition.contains('few')) {
        return Icons.cloud_outlined;
      }
      return Icons.cloud;
    } else if (lowercaseCondition.contains('rain')) {
      if (lowercaseCondition.contains('light')) {
        return Icons.grain;
      } else if (lowercaseCondition.contains('heavy')) {
        return Icons.thunderstorm;
      }
      return Icons.water_drop;
    } else if (lowercaseCondition.contains('drizzle')) {
      return Icons.grain;
    } else if (lowercaseCondition.contains('thunderstorm')) {
      return Icons.flash_on;
    } else if (lowercaseCondition.contains('snow')) {
      return Icons.ac_unit;
    } else if (lowercaseCondition.contains('mist') || 
               lowercaseCondition.contains('fog') || 
               lowercaseCondition.contains('haze')) {
      return Icons.cloud_queue;
    } else {
      // Default icon
      return Icons.wb_sunny_outlined;
    }
  }
}
