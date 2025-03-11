import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class Step2 extends StatefulWidget {
  @override
  _Step2State createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  final List<Map<String, dynamic>> sports = [
    {'name': 'BaseBall', 'availablePractices': 4},
    {'name': 'Tennis', 'availablePractices': 5},
    {'name': 'Volleyball', 'availablePractices': 3},
    {'name': 'Basketball', 'availablePractices': 6},
    {'name': 'Football', 'availablePractices': 7},
    {'name': 'Handball', 'availablePractices': 4},
    {'name': 'Rugby', 'availablePractices': 5},
    {'name': 'Cricket', 'availablePractices': 4},
    {'name': 'Swimming', 'availablePractices': 3},
    {'name': 'Boxing', 'availablePractices': 2},
    {'name': 'Cycling', 'availablePractices': 4},
    {'name': 'Golf', 'availablePractices': 3},
  ];
  final AuthService _authService = AuthService();
  List<String> selectedSports = [];
  final int totalSteps = 8;
  int currentStep = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 40),
            _buildProgressBar(),
            const SizedBox(height: 16),
            _buildTitleSection(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            const SizedBox(height: 24),
            for (int i = 0; i < sports.length; i++) _buildSportCard(sports[i], i),
            const SizedBox(height: 24),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: currentStep / totalSteps,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      minHeight: 8,
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/step_one');
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Step 2',
            style: TextStyle(
              color: const Color(0xFF808B9A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildSkipButton(),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/step_three');
      },
      child: Text(
        'Skip question',
        style: TextStyle(
          color: const Color(0xFF808B9A),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      'First up, which sports do you enjoy the most?',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Select all that apply:',
      style: TextStyle(
        color: const Color(0xFF808B9A),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSportCard(Map<String, dynamic> sportData, int index) {
    final String sport = sportData['name'];
    final int availablePractices = sportData['availablePractices'];
    bool isSelected = selectedSports.contains(sport);

    // Icons for each sport
    final Map<String, IconData> sportIcons = {
      'BaseBall': Icons.sports_baseball,
      'Tennis': Icons.sports_tennis,
      'Volleyball': Icons.sports_volleyball,
      'Basketball': Icons.sports_basketball,
      'Football': Icons.sports_soccer,
      'Handball': Icons.sports_handball,
      'Rugby': Icons.sports_rugby,
      'Cricket': Icons.sports_cricket,
      'Swimming': Icons.pool,
      'Boxing': Icons.sports_mma,
      'Cycling': Icons.directions_bike,
      'Golf': Icons.sports_golf,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedSports.remove(sport); // Deselect if already selected
            } else {
              selectedSports.add(sport); // Select if not selected
            }
          });
        },
        child: Container(
          width: double.infinity,
          height: 110,
          decoration: ShapeDecoration(
            color: isSelected ? Color(0xFFF5BA41) : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: const Color(0xFFF1F1F1),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0x05323247),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: -1.50,
              ),
              BoxShadow(
                color: const Color(0x0C0C1A4B),
                blurRadius: 3.75,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF39434F),
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: const Color(0xFFECEFF2)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFDCF0FF),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 0.50, color: const Color(0xFF1B85F3)),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF1B85F3),
                                  shape: OvalBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$availablePractices available practices',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Color(0xFF808B9A),
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w500,
                                height: 1.38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: isSelected
                      ? Icon(
                    sportIcons[sport],
                    size: 70,
                    color: Colors.white, // White when selected
                  )
                      : ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Icon(
                      sportIcons[sport],
                      size: 70,
                      color: Colors.white, // Base color for gradient
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bouton "Continue"
  Widget _buildActionButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () async {
          String firebaseUid = FirebaseAuth.instance.currentUser!.uid; // Récupérer l'UID de l'utilisateur connecté

          // Appel de la méthode pour mettre à jour avec uniquement selectedSports
          String result = await _authService.updateUserDetails(
            firebaseUid: firebaseUid,
            selectedSports: selectedSports, // Passer la liste des sports sélectionnés
          );

          // Vérifier le résultat de la mise à jour
          if (result == 'Mise à jour réussie') {
            Navigator.of(context).pushReplacementNamed('/step_three');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result)),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

}
