import 'package:flutter/material.dart';
import 'intro_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the IntroScreen after a 3-second delay
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4DD4DE), // Vibrant blue
                  Color(0xFF0C1A37), // Deep navy blue
                ],
              ),
            ),
          ),
          // Centered content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clean logo (without glow)
                Image.asset(
                  'assets/images/gorun_logo_white.png', // Replace with your logo asset path
                  width: 300,
                  height: 300,
                ),
                SizedBox(height: 20),
                // Motivational tagline
              ],
            ),
          ),
          // Footer with a subtle motivational message
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              "FIND YOUR INNER STRENGTH",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
