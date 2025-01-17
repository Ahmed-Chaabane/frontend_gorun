import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _floatingAnimation;

  final List<String> quotes = [
    "This is the perfect place to keep track of your hobbies and practice the sport you like!",
    "Challenge yourself and discover new possibilities!",
    "Every journey begins with a single step. Let's take it together!",
  ];

  int currentQuoteIndex = 0;

  @override
  void initState() {
    super.initState();

    // Animation for floating/swimming photos
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: Offset(0, -0.05),
      end: Offset(0, 0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4DD4DE), // Ocean top color
              Color(0xFF162A5A), // Ocean deep color
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Photos
              Expanded(
                flex: 4,
                child: Center(
                  child: SlideTransition(
                    position: _floatingAnimation,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: List.generate(8, (index) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/photo${index + 1}.jpg'), // Replace with your photos
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Title
              Text(
                "FIND YOUR INNER STRENGTH",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 16),

              // Description with swipable quotes
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          setState(() {
                            if (details.velocity.pixelsPerSecond.dx < 0) {
                              // Swipe left
                              currentQuoteIndex =
                                  (currentQuoteIndex + 1) % quotes.length;
                            } else if (details.velocity.pixelsPerSecond.dx >
                                0) {
                              // Swipe right
                              currentQuoteIndex =
                                  (currentQuoteIndex - 1 + quotes.length) %
                                      quotes.length;
                            }
                          });
                        },
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: Text(
                            quotes[currentQuoteIndex],
                            key: ValueKey(currentQuoteIndex),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Join Now Button
              ElevatedButton(
                onPressed: () {
                  // Handle Join Now button
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  "Join Now",
                  style: TextStyle(
                    color: Color(0xFF162A5A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Log In Text Button
              TextButton(
                onPressed: () {
                  // Handle Log In button
                },
                child: Text(
                  "Already a member? Log in",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}