import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mujjiweather/api.dart';
import 'package:mujjiweather/weathermodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ApiResponse? response;
  bool inProgress = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Weather App',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SearchWidget(),
                const SizedBox(height: 20),
                inProgress
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : response != null
                        ? WeatherCard(response!)
                        : const Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _getCurrentLocationWeather,
          child: const Icon(Icons.my_location),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }

  Widget SearchWidget() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search any location",
        prefixIcon: const Icon(Icons.search, color: Colors.blue),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: (value) {
        getweatherdata(value);
      },
    );
  }

  Widget WeatherCard(ApiResponse response) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      shadowColor: Colors.blue.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response.location?.name ?? 'Unknown Location',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              response.location?.country ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Image.network(
                  'https:${response.current?.condition?.icon ?? ''}',
                  width: 64,
                  height: 64,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${response.current?.tempC?.toStringAsFixed(1) ?? '--'}°C',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      response.current?.condition?.text ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                WeatherDetailItem(
                  icon: Icons.air,
                  label: 'Wind',
                  value: '${response.current?.windKph?.toStringAsFixed(1) ?? '--'} kph',
                ),
                WeatherDetailItem(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${response.current?.humidity ?? '--'}%',
                ),
                WeatherDetailItem(
                  icon: Icons.wb_sunny,
                  label: 'UV Index',
                  value: '${response.current?.uv?.toStringAsFixed(1) ?? '--'}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget WeatherDetailItem({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

Future<void> _getCurrentLocationWeather() async {
  setState(() {
    inProgress = true;
  });

  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled, handle it accordingly
    setState(() {
      inProgress = false;
    });
    return Future.error('Location services are disabled.');
  }

  // Check for location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, handle it accordingly
      setState(() {
        inProgress = false;
      });
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are permanently denied
    setState(() {
      inProgress = false;
    });
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // If permissions are granted, get the current location
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String location = "${position.latitude},${position.longitude}";
    await getweatherdata(location);
  } catch (e) {
    print("Error: $e");
  } finally {
    setState(() {
      inProgress = false;
    });
  }
}


  getweatherdata(String location) async {
    setState(() {
      inProgress = true;
    });
    try {
      response = await weatherApi().getcurrentweather(location);
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
