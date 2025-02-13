import 'package:flutter/material.dart';

class PersonalizedJourney extends StatelessWidget {
  const PersonalizedJourney({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildBackgroundImages(),
                _buildContent(),
              ],
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // Background images placed using Positioned widgets
  Widget _buildBackgroundImages() {
    return Stack(
      children: [
        Positioned(
          left: -66,
          top: 50,
          child: CircleAvatar(
            radius: 121,
            backgroundImage: AssetImage("assets/images/image2.png"),
          ),
        ),
        Positioned(
          right: 120,
          top: 250,
          child: CircleAvatar(
            radius: 80,
            backgroundImage: AssetImage("assets/images/image1.png"),
          ),
        ),
        Positioned(
          right: -30,
          top: 30,
          child: CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage("assets/images/image3.png"),
          ),
        ),
      ],
    );
  }

  // Content section with text
  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 250), // Adjust height to push text below images
          Text(
            'Give us a chance to\n personalize your journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Simplify your journey through our smart\n configurator.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // Action buttons (Start button and Skip for now clickable text)
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/step_one');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162A5A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/step_one');
            },
            splashColor: Colors.blue.withOpacity(0.3),
            highlightColor: Colors.blue.withOpacity(0.1),
            child: Text(
              'Skip for now',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF808B9A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
