import 'package:flutter/material.dart';
import 'intro_screen.dart';
import 'login_screen.dart'; // Import your login screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Duration of the animation
      vsync: this,
    );

    // Scale animation: Start small and grow bigger
    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut), // Bounce effect
    );

    // Opacity animation: Fade out after growing
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Background color transition: Change background color over time
    _backgroundColorAnimation = ColorTween(begin: Colors.white, end: Colors.blue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start the animation
    _controller.forward();

    // After the animation completes, navigate to the login screen
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(seconds: 1), () {
          _navigateToLogin();
        });
      }
    });
  }

  // Function to navigate to the login screen
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IntroScreen()), // Navigate to your LoginScreen
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: _backgroundColorAnimation.value, // Dynamically changing background color
        body: Center(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image(
                image: AssetImage('assets/images/gorun_logo.png'), // Your logo image
              ),
            ),
          ),
        ),
      ),
    );
  }
}