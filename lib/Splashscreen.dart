import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mujjiweather/homescreen.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Set a timer for 3 seconds, then navigate to HomeView
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           
            Icon(
              Icons.cloud, 
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              "Weather App",
              style: TextStyle(
                color: Colors.white, 
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2, // Adds some spacing between letters
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Your go-to weather forecast",
              style: TextStyle(
                color: Colors.white70, // Slightly dimmed secondary text
                fontSize: 16,
              ),
            ),
            SizedBox(height: 50), // Adds space for better layout
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ), // Add a loading indicator for a better UX
          ],
        ),
      ),
    );
  }
}
