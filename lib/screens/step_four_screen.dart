import 'package:flutter/material.dart';

class Step4 extends StatefulWidget {
  @override
  _Step4State createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  final List<Map<String, dynamic>> sports = [
    {'name': 'Outdoor'},
    {'name': 'Indoor'},
    {'name': 'Home'},
    {'name': 'At the gym'},
    {'name': 'At the park'},
  ];

  List<String> selectedSports = [];
  final int totalSteps = 8;
  int currentStep = 4;

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
            for (int i = 0; i < sports.length; i++)
              _buildSportCard(sports[i], i),
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
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Step 4',
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
      onPressed: () {},
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
      'Where do you enjoy the most to train?',
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

    // Mapping sport names to their respective icons
    final Map<String, IconData> sportIcons = {
      'Outdoor': Icons.outdoor_grill,
      'Indoor': Icons.home_work,
      'Home': Icons.house,
      'At the gym': Icons.fitness_center,
      'At the park': Icons.park,
    };

    bool isSelected = selectedSports.contains(sport);

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
                width: 1,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: const Color(0xFFF7FAFC),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            shadows: [
              BoxShadow(
                color: const Color(0x05323247),
                blurRadius: 15,
                offset: const Offset(0, 3),
                spreadRadius: -1.50,
              ),
              BoxShadow(
                color: const Color(0x0C0C1A4B),
                blurRadius: 3.75,
                offset: const Offset(0, 0),
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
                          color: isSelected ? Colors.white : Color(0xFF808B9A),
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                  ),
                  child: Icon(
                    sportIcons[sport], // Display the corresponding icon
                    size: 40,
                    color: isSelected ? Colors.white : Color(0xFF808B9A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () {
          if (selectedSports.isNotEmpty) {
            Navigator.of(context).pushReplacementNamed('/step_five');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select at least one sport!')),
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
