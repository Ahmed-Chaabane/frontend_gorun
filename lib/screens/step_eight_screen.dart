import 'package:flutter/material.dart';

class Step8 extends StatefulWidget {
  @override
  _Step8State createState() => _Step8State();
}

class _Step8State extends State<Step8> {
  final List<Map<String, String>> benefits = [
    {
      'name': 'Reduce Stress',
      'description': 'Sports help you manage stress. Exercise causes your body to release endorphins, the chemicals that relieve pain and stress.',
      'image': 'assets/images/stress.png'
    },
    {
      'name': 'Improve Sleep',
      'description': 'Regular exercise can help you fall asleep faster and deepen your sleep.',
      'image': 'assets/images/sleep.png'
    },
    {
      'name': 'Boost Confidence',
      'description': 'Achieving fitness goals boosts your self-esteem and confidence.',
      'image': 'assets/images/confidence.png'
    },
    {
      'name': 'Increase Energy',
      'description': 'Exercise improves cardiovascular health, giving you more stamina.',
      'image': 'assets/images/energy.png'
    },
    {
      'name': 'Improve Mental Health',
      'description': 'Regular physical activity reduces feelings of depression and anxiety by increasing the production of endorphins and serotonin.',
      'image': 'assets/images/mental_health.png'
    },
    {
      'name': 'Enhance Flexibility',
      'description': 'Stretching exercises help improve flexibility, reducing the risk of injury.',
      'image': 'assets/images/flexibility.png'
    },
    {
      'name': 'Strengthen Muscles',
      'description': 'Weight training and resistance exercises help build and maintain muscle strength.',
      'image': 'assets/images/strength.png'
    },
    {
      'name': 'Improve Balance',
      'description': 'Activities like yoga and Pilates improve balance and coordination.',
      'image': 'assets/images/balance.png'
    },
    {
      'name': 'Support Weight Management',
      'description': 'Regular exercise helps maintain a healthy weight by burning calories and improving metabolism.',
      'image': 'assets/images/weight_management.png'
    },
    {
      'name': 'Boost Immunity',
      'description': 'Exercise improves the immune system by promoting better circulation and healthier lung function.',
      'image': 'assets/images/immunity.png'
    },
    {
      'name': 'Increase Longevity',
      'description': 'Studies show that regular exercise can increase life expectancy and reduce the risk of chronic diseases.',
      'image': 'assets/images/longevity.png'
    },
    {
      'name': 'Enhance Mood',
      'description': 'Physical activity triggers the release of endorphins, which can enhance mood and reduce feelings of anxiety.',
      'image': 'assets/images/mood.png'
    },
    {
      'name': 'Improve Brain Function',
      'description': 'Exercise increases blood flow to the brain, improving memory and cognitive function.',
      'image': 'assets/images/brain_function.png'
    },
    {
      'name': 'Improve Posture',
      'description': 'Strengthening core muscles through exercise can lead to improved posture and reduced back pain.',
      'image': 'assets/images/posture.png'
    },
  ];

  List<bool> isChecked = [false, false, false, false, false, false, false, false,false, false, false, false, false, false];
  List<String> selectedSports = [];
  final int totalSteps = 8;
  int currentStep = 8; // Always fixed at Step 8

  late PageController _pageController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSection(),
          const SizedBox(height: 16),
          _buildMainTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 24),
          _buildPageView(),
          _buildPageIndicators(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Top Section: Title, Progress Bar, Skip
  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepRow(),
          const SizedBox(height: 8),
          _buildProgressBar(),
        ],
      ),
    );
  }

  // Step Row with Back Button, Step Title, and Skip Button
  Widget _buildStepRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Text(
          'Step $currentStep',
          style: TextStyle(fontSize: 16, color: Color(0xFF808B9A)),
        ),
        Spacer(),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Skipped!')),
            );
          },
          child: Text(
            'Skip',
            style: TextStyle(color: Color(0xFF808B9A)),
          ),
        ),
      ],
    );
  }

  // Progress Bar
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: currentStep / totalSteps,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      minHeight: 8,
    );
  }

  // Main Title
  Widget _buildMainTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'What do you want to improve?',
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  // Subtitle
  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'Select all that apply:',
        style: TextStyle(
          color: const Color(0xFF808B9A),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // PageView for cards
  Widget _buildPageView() {
    return Expanded(
      child: Listener(
        onPointerMove: (details) {
          if (details.delta.dx > 5 && currentPage > 0) {
            _pageController.animateToPage(
              currentPage - 1,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (details.delta.dx < -5 && currentPage < benefits.length - 1) {
            _pageController.animateToPage(
              currentPage + 1,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) => setState(() => currentPage = index),
          itemCount: benefits.length,
          itemBuilder: (context, index) => _buildBenefitCard(benefits[index], index),
        ),
      ),
    );
  }

  // Page Indicators
  Widget _buildPageIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(benefits.length, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: currentPage == index ? 24 : 8,
            decoration: BoxDecoration(
              color: currentPage == index ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  // Continue Button
  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // Save selected benefits in the list
          selectedSports = benefits
              .where((benefit) => isChecked[benefits.indexOf(benefit)]).map((benefit) => benefit['name']!).toList();

          if (selectedSports.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected benefits: ${selectedSports.join(', ')}')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select at least one benefit!')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 70),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  // Benefit Card
  Widget _buildBenefitCard(Map<String, String> benefit, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipOval(
                  child: Image.asset(benefit['image']!, height: 180, width: 180, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  benefit['name']!,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  benefit['description']!,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Checkbox(
                key: ValueKey(isChecked[index]),
                value: isChecked[index],
                onChanged: (bool? value) {
                  setState(() {
                    isChecked[index] = value!;
                    if (value) {
                      selectedSports.add(benefit['name']!); // Add to selectedSports when checked
                    } else {
                      selectedSports.remove(benefit['name']!); // Remove when unchecked
                    }
                  });
                },
                activeColor: Colors.blue, // Checkbox selected color
                checkColor: Colors.white, // Checkmark color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
