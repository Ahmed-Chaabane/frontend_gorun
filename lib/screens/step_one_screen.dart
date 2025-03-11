import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_gorun/services/auth_service.dart';
import 'package:http/http.dart' as http;

class Step1 extends StatefulWidget {
  @override
  _Step1State createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  String selectedGender = 'Male';
  int age = 26;
  double height = 175;
  double weight = 82;
  final int totalSteps = 8;
  int currentStep = 1;

  final AuthService _authService = AuthService(); // Instance de AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopSection(),
                const SizedBox(height: 40),
                _buildProgressBar(),
                const SizedBox(height: 16),
                _buildTitleSection(),
                const SizedBox(height: 24),
                _buildGenderSection(),
                const SizedBox(height: 32),
                _buildAgeSection(),
                const SizedBox(height: 32),
                _buildHeightSection(),
                const SizedBox(height: 32),
                _buildWeightSection(),
                const SizedBox(height: 240),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildActionButton(context),
          ),
        ],
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

          String result = await _authService.updateUserDetails(
            firebaseUid: firebaseUid,
            sexe: selectedGender,
            age: age,
            taille: height,
            poids: weight, selectedSports: [],
          );

          if (result == 'Mise à jour réussie') {
            Navigator.of(context).pushReplacementNamed('/step_two');
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

  // Section supérieure (flèche de retour et bouton "Skip")
  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Flèche de retour
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/personalized_journey');
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Step 1',
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

  // Bouton "Skip question"
  Widget _buildSkipButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/step_two');
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

  // Barre de progression
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: currentStep / totalSteps,
      backgroundColor: Colors.grey.shade200,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      minHeight: 8,
    );
  }

  // Titre de l'écran
  Widget _buildTitleSection() {
    return Text(
      'Let us know you better!',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Section "Gender"
  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Your gender: $selectedGender'),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildGenderOption('assets/icons/Vector-6.png', 'Male', selectedGender == 'Male'),
            const SizedBox(width: 16),
            _buildGenderOption('assets/icons/Vector-7.png', 'Female', selectedGender == 'Female'),
          ],
        ),
      ],
    );
  }

  // Option de genre (Male/Female)
  Widget _buildGenderOption(String imagePath, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGender = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5BA41) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFFF5BA41) : const Color(0xFFF1F1F1),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0x33F5BA41),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 48,
                height: 48,
                color: isSelected ? Colors.white : const Color(0xFF808B9A),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF808B9A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section "Age"
  Widget _buildAgeSection() {
    return _buildSliderSection(
      'Age:',
      age.toDouble(),
          (value) {
        setState(() {
          age = value.toInt();
        });
      },
      18,
      100,
      'assets/icons/Vector-1.png',
      'assets/icons/Vector.png',
      '',
    );
  }

  // Section "Height"
  Widget _buildHeightSection() {
    return _buildSliderSection(
      'Height:',
      height,
          (value) {
        setState(() {
          height = value;
        });
      },
      100,
      250,
      'assets/icons/Vector-3.png',
      'assets/icons/Vector-2.png',
      'cm',
    );
  }

  // Section "Weight"
  Widget _buildWeightSection() {
    return _buildSliderSection(
      'Weight:',
      weight,
          (value) {
        setState(() {
          weight = value;
        });
      },
      30,
      200,
      'assets/icons/Vector-5.png',
      'assets/icons/Vector-4.png',
      'kg',
    );
  }

  // Slider générique
  Widget _buildSliderSection(
      String label,
      double value,
      Function(double) onChanged,
      double min,
      double max,
      String leftImagePath,
      String rightImagePath,
      String unit,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('$label ${value.toStringAsFixed(0)} $unit'),
        const SizedBox(height: 12),
        Row(
          children: [
            Image.asset(
              leftImagePath,
              width: 36,
              height: 36,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.grey.shade700,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.grey.shade500,
                  overlayColor: Colors.transparent,
                  valueIndicatorColor: Colors.grey.shade700,
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: (max - min).toInt(),
                  onChanged: onChanged,
                  label: value.toStringAsFixed(0),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              rightImagePath,
              width: 36,
              height: 36,
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  // Label générique
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF808B9A),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}