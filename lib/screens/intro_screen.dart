import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final String quote = "Unleash Your True Strength.";
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          _buildGradientBackground(),

          // Ocean Light Reflection
          AnimatedOceanLight(controller: _backgroundController),

          // Floating Bubbles
          AnimatedBackground(controller: _backgroundController),

          // Content
          _buildContent(scaleFactor),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double scaleFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "AWAKEN THE BEAST WITHIN",
          style: TextStyle(
            fontSize: 22 * scaleFactor,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                offset: const Offset(0, 4),
                blurRadius: 8,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0 * scaleFactor),
          child: TypewriterText(
            text: quote,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16 * scaleFactor,
              fontWeight: FontWeight.bold,
            ),
            durationPerChar: 50, // Slightly faster typewriter effect
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/signup');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 100 * scaleFactor,
              vertical: 16 * scaleFactor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            "Join Now",
            style: TextStyle(
              color: const Color(0xFF1B85F3),
              fontWeight: FontWeight.bold,
              fontSize: 15 * scaleFactor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already a member?",
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text("Log in", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// Typewriter Effect
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final int durationPerChar;

  const TypewriterText({
    required this.text,
    required this.textStyle,
    required this.durationPerChar,
    super.key,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String displayedText = "";
  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: widget.durationPerChar), (timer) {
      if (currentIndex < widget.text.length) {
        setState(() {
          displayedText += widget.text[currentIndex];
          currentIndex++;
        });
      } else {
        timer.cancel();
        _timer = null; // Important: Set timer to null after completion
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(displayedText, style: widget.textStyle, textAlign: TextAlign.center);
  }
}

// Ocean Light Reflection
class AnimatedOceanLight extends StatelessWidget {
  final AnimationController controller;

  const AnimatedOceanLight({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: OceanLightPainter(controller.value),
          size: Size.infinite, // Important for CustomPaint to fill the screen
        );
      },
    );
  }
}

class OceanLightPainter extends CustomPainter {
  final double progress;

  OceanLightPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.3), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..blendMode = BlendMode.lighten;

    final path = Path();
    for (double i = 0; i <= size.width; i+=2) { // Increment i for smoother wave
      path.lineTo(i, size.height * 0.5 + sin(i * 0.005 + progress * 2 * pi) * 20); // Smaller wave, adjust as needed
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(OceanLightPainter oldDelegate) => progress != oldDelegate.progress;
}


// Animated Background Bubbles
class AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const AnimatedBackground({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final random = Random();

    return Stack(
      children: List.generate(30, (index) {
        final initialX = random.nextDouble() * screenWidth;
        final size = random.nextDouble() * 40 + 10; // Smaller bubbles
        final speed = random.nextDouble() * 0.5 + 0.5; // Varying speeds

        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final progress = (controller.value * speed + index * 0.05) % 1.0; // Apply speed to animation
            final top = screenHeight * (1 - progress);
            final left = initialX + sin(progress * pi * 2) * 50 * (size/20); // Adjust horizontal movement based on size
            final opacity = (1 - (progress - 0.5).abs() * 2).clamp(0.1, 0.5); // More subtle opacity

            return Positioned(
              left: left,
              top: top,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(opacity),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
