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
        // Utilise un cercle avatar avec gestion d'erreur et image par défaut
        CircleAvatar(
          radius: 100 * scaleFactor,
          backgroundColor: Colors.white, // Couleur de fond si l'image est vide
          child: ClipOval(
            child: _buildProfileImage(),
          ),
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
          "Welcome back! We're excited to see you again.\n Keep going, you're doing great!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF808B9A),
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (userImageUrl.isEmpty) {
      // Si pas d'URL d'image, utiliser l'image par défaut
      return Image.asset(
        'assets/icons/sportsman.png',
        width: 300,
        height: 300,
        fit: BoxFit.cover,
      );
    } else {
      // Si URL d'image existe, essayer de la charger
      return Image.network(
        userImageUrl,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // En cas d'erreur de chargement, utiliser l'image par défaut
          return Image.asset(
            'assets/icons/sportsman.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
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
              fontSize: 16, // Scales the text size
            ),
          ),
        ),
      ),
    );
  }
}
