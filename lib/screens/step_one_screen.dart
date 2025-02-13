import 'package:flutter/material.dart';

class Step1 extends StatefulWidget {
  @override
  _Step1State createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  String selectedGender = 'Male';
  int age = 26;
  double height = 175;
  double weight = 82; // Keep weight as a double
  final int totalSteps = 8;
  int currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
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
                _buildGenderSection(), // Only one call for _buildGenderSection
                const SizedBox(height: 32),
                _buildAgeSection(),
                const SizedBox(height: 32),
                _buildHeightSection(),
                const SizedBox(height: 32),
                _buildWeightSection(),
                const SizedBox(height: 240), // Add spacing for the button at the bottom
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
          // Back arrow button
          IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
            onPressed: () {
              Navigator.of(context).pop(); // Go back to the previous screen
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
      'Let us know you better!',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Your gender: $selectedGender'), // Include value in label
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: const Color(0x33F5BA41),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              BoxShadow(
                color: const Color(0x05323247),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 48, // Adjust the width as needed
                height: 48, // Adjust the height as needed
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

  Widget _buildSliderSection(
      String label, double value, Function(double) onChanged, double min, double max, String leftImagePath, String rightImagePath, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('$label ${value.toStringAsFixed(0)} $unit'), // Include value and unit in label
        const SizedBox(height: 12),
        Row(
          children: [
            Image.asset(
              leftImagePath,
              width: 36, // Adjust the width as needed
              height: 36, // Adjust the height as needed
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  // Customize slider colors
                  activeTrackColor: Colors.grey.shade700, // Filled part of the slider
                  inactiveTrackColor: Colors.grey.shade300, // Unfilled part of the slider
                  thumbColor: Colors.grey.shade500, // Thumb (circle) color
                  overlayColor: Colors.transparent, // Remove overlay effect

                  // Customize tooltip appearance
                  valueIndicatorColor: Colors.grey.shade700, // Tooltip background color
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white, // Tooltip text color
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
                  label: value.toStringAsFixed(0), // Tooltip text
                ),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              rightImagePath,
              width: 36, // Adjust the width as needed
              height: 36, // Adjust the height as needed
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeSection() {
    return _buildSliderSection(
      'Age:',
      age.toDouble(),
          (value) {
        setState(() {
          age = value.toInt(); // Update state
        });
      },
      18,
      100,
      'assets/icons/Vector-1.png', // Left image for age slider
      'assets/icons/Vector.png', // Right image for age slider
      '', // No unit for age
    );
  }

  Widget _buildHeightSection() {
    return _buildSliderSection(
      'Height:',
      height,
          (value) {
        setState(() {
          height = value; // Update state
        });
      },
      100,
      250,
      'assets/icons/Vector-3.png', // Left image for height slider
      'assets/icons/Vector-2.png', // Right image for height slider
      'cm', // Add cm unit
    );
  }

  Widget _buildWeightSection() {
    return _buildSliderSection(
      'Weight:',
      weight,
          (value) {
        setState(() {
          weight = value; // Update state
        });
      },
      30,
      200,
      'assets/icons/Vector-5.png', // Left image for weight slider
      'assets/icons/Vector-4.png', // Right image for weight slider
      'kg', // Add kg unit
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      color: Colors.white, // Background color for the button area
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/step_two');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70), // Full width button
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

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