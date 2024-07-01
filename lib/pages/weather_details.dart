// ignore_for_file: avoid_print, use_super_parameters

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/backend/consts.dart';
import 'package:weather_app/backend/shared_prefs.dart';

class WeatherDetails extends StatefulWidget {
  const WeatherDetails({Key? key, required this.cityName}) : super(key: key);

  final String cityName;

  @override
  State<WeatherDetails> createState() => _WeatherDetailsState();
}

class _WeatherDetailsState extends State<WeatherDetails>
    with SingleTickerProviderStateMixin {
  final WeatherFactory _weatherFactory = WeatherFactory(OPENWEATHER_API_KEY);
  final SharedPrefs _sharedPrefs = SharedPrefs();
  Weather? _weather; // Declare _weather as late

  // Animation controller and animation for fading in content
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isLoading = true; // Initialize _isLoading to true

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _fetchWeather();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      final weather =
          await _weatherFactory.currentWeatherByCityName(widget.cityName);
      setState(() {
        _weather = weather;
        _controller.forward();
        _isLoading = false; // Set _isLoading to false after weather is fetched
      });
      _sharedPrefs.saveRecentSearch(widget.cityName);
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        _isLoading = false; // Handle error by setting _isLoading to false
      });
    }
  }

  Future<void> _refreshWeather() async {
    await _controller.reverse();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getBackgroundGradient(),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_weather != null) // Check if _weather is not null
                ? FadeTransition(
                    opacity: _animation,
                    child: _buildWeatherDetails(),
                  )
                : const Center(
                    child: Text('No weather data available'),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshWeather,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(_getWeatherIcon()),
          ),
          const SizedBox(height: 10),
          Text(
            widget.cityName.toUpperCase(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "${_weather?.temperature?.celsius?.toStringAsFixed(1)}°C",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _weather?.weatherDescription ?? "No description",
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWeatherInfo(Icons.water_drop, "${_weather?.humidity}%"),
              const SizedBox(width: 20),
              _buildWeatherInfo(Icons.air, "${_weather?.windSpeed} m/s"),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeatherCard("Pressure: ${_weather?.pressure} hPa"),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(String text) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  List<Color> _getBackgroundGradient() {
    switch (_weather?.weatherMain) {
      case 'Clear':
        return [Colors.blue.shade400, Colors.blue.shade900];
      case 'Rain':
        return [Colors.grey.shade600, Colors.grey.shade800];
      case 'Snow':
        return [Colors.white, Colors.blue.shade200];
      default:
        return [Colors.blue.shade200, Colors.blue.shade600];
    }
  }

  String _getWeatherIcon() {
    switch (_weather?.weatherMain) {
      case 'Clear':
        return 'assets/sunny.png';
      case 'Rain':
        return 'assets/rain.png';
      default:
        return 'assets/cloud.png';
    }
  }
}
