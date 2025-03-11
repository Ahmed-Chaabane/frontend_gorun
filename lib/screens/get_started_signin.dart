import 'package:flutter/material.dart';

class GetStartedSigninScreen extends StatelessWidget {
  final String userName;
  final String userImageUrl;

  const GetStartedSigninScreen({
    Key? key,
    required this.userName,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.width / 375;
    scaleFactor = scaleFactor.clamp(1.0, 1.5); // Set min and max scaling factor (1.0 for no scaling, 1.5 for a cap on scaling)

    return WillPopScope(
      onWillPop: () async {
        return false; // Blocks the back button
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: _buildUserProfile(scaleFactor),
              ),
            ),
            _buildActionButtons(context, scaleFactor),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(double scaleFactor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Utilizes Image.network with fallback image in case of error
        CircleAvatar(
          radius: 100 * scaleFactor, // Scales the avatar size
          backgroundImage: NetworkImage(userImageUrl),
          onBackgroundImageError: (error, stackTrace) {
            // Fallback image in case of error
          },
        ),
        SizedBox(height: 16 * scaleFactor),
        Text(
          userName,
          style: TextStyle(
            fontSize: 25 * scaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16 * scaleFactor),
        const Text(
          "Welcome back! We\'re excited to see you again.\n Keep going, you\'re doing great!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF808B9A),
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home_screen');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF162A5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Get Started',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Scales the text size
            ),
          ),
        ),
      ),
    );
  }
}
