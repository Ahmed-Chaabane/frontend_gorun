import 'package:flutter/material.dart';

class Step5 extends StatefulWidget {
  @override
  _Step5State createState() => _Step5State();
}

class _Step5State extends State<Step5> {
  final List<Map<String, dynamic>> sports = [
    {'name': '1 time per week'},
    {'name': '2 times per week'},
    {'name': '3 times per week'},
    {'name': 'more than 3 times per week'},
  ];

  List<String> selectedSports = [];
  final int totalSteps = 8;
  int currentStep = 5;

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
            'Step 5',
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
      'How often do you train?',
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
          child: Center(  // Center the content inside the card
            child: Text(
              sport,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF808B9A),
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 90.0),
      child: ElevatedButton(
        onPressed: () {
          if (selectedSports.isNotEmpty) {
            Navigator.of(context).pushReplacementNamed('/step_six');
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
