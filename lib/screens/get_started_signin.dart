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
    return WillPopScope(
      onWillPop: () async {
        return false; // Bloque la flèche de retour
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: _buildUserProfile(),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Utilisation d'Image.network avec un fallback d'image en cas d'erreur
        CircleAvatar(
          radius: 80,
          backgroundImage: NetworkImage(userImageUrl),
          // Gestion de l'erreur de chargement d'image
          onBackgroundImageError: (error, stackTrace) {
            // Affichage d'une image par défaut en cas d'erreur de chargement
          },
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome back! We\'re excited to see you again. Keep going, you\'re doing great!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF808B9A),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/validation_code');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF162A5A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
