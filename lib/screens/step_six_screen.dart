import 'package:flutter/material.dart';

class Step6 extends StatefulWidget {
  @override
  _Step6State createState() => _Step6State();
}

class _Step6State extends State<Step6> {
  final List<Map<String, dynamic>> sports = [
    {'name': 'No, I don’t have'},
    {'name': 'Yes, I have'},
  ];

  List<String> selectedSports = [];
  final int totalSteps = 8;
  int currentStep = 6;
  final TextEditingController _conditionController = TextEditingController();

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
            ...sports.map((sportData) => _buildSportCard(sportData)),
            const SizedBox(height: 24),
            _buildLargeTextField(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Step 6',
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
      'Do you have any health problems that can affect your trainings?',
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

  Widget _buildSportCard(Map<String, dynamic> sportData) {
    final String sport = sportData['name'];
    bool isSelected = selectedSports.contains(sport);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedSports.remove(sport);
            } else {
              selectedSports.add(sport);
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
          child: Center(
            child: Text(
              sport,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF808B9A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us more about your condition:',
            style: TextStyle(
              color: const Color(0xFF808B9A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _conditionController,
            maxLines: 5,  // Make the text field larger for multi-line input
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color(0xFFB0B0B0),  // Set the border color here
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color(0xFF6B6B6B),  // Dark gray color for focused border
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Color(0xFFB0B0B0),  // Gray border when not focused
                  width: 1.5,
                ),
              ),
              hintText: 'Suggested',
              hintStyle: TextStyle(
                color: Color(0xFFB0B0B0),  // Set your desired hint text color
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0),
      child: ElevatedButton(
        onPressed: () {
          if (selectedSports.isNotEmpty) {
            Navigator.of(context).pushReplacementNamed('/step_seven');
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
