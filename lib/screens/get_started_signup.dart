import 'package:flutter/material.dart';

class GetStartedSignupScreen extends StatelessWidget {
  final String userName;
  final String userImageUrl;

  const GetStartedSignupScreen({
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
        // Utilisation de Image.network avec gestion du chargement et des erreurs
        CircleAvatar(
          radius: 80,
          backgroundImage: NetworkImage(userImageUrl),
          // Si l'image échoue à se charger, il ne faut pas retourner une valeur ici
          onBackgroundImageError: (error, stackTrace) {
            // Il n'y a rien à retourner ici. L'image de remplacement sera gérée autrement.
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
          'Welcome! We\'re excited to have you here. Let\'s get started and make great things happen!',
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
            Navigator.of(context).pushReplacementNamed('/personalized_journey');
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
