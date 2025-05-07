import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = '';
  double temperature = 0;
  String description = '';
  double tempMin = 0;
  double tempMax = 0;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'Lokasi tidak aktif.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = 'Izin lokasi tidak disetujui';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage =
              'Izin lokasi ditolak secara permanen. Silakan aktifkan izin di pengaturan aplikasi.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String apiKey = 'c1b0b9c755f84ba9954a2c3fa67b68bd';
      String url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          city = data['name'];
          temperature = data['main']['temp'];
          tempMin = data['main']['temp_min'];
          tempMax = data['main']['temp_max'];
          description = data['weather'][0]['description'];
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data cuaca.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan saat mengambil data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child:
                errorMessage.isNotEmpty
                    ? Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    )
                    : city.isEmpty
                    ? const CircularProgressIndicator()
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          city,
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 80,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          child: DottedLine(
                            dashLength: 10,
                            lineThickness: 2,
                            dashColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          description[0].toUpperCase() +
                              description.substring(1),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${tempMin.toStringAsFixed(1)}°C / ${tempMax.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
