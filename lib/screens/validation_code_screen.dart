import 'package:flutter/material.dart';

class ValidationCodeScreen extends StatefulWidget {
  const ValidationCodeScreen({super.key});

  @override
  State<ValidationCodeScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ValidationCodeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  final List<Map<String, String>> _quotes = [
    {
      'text':
      '“I’ve missed more than 9,000 shots in my career. I’ve lost almost 300 games. Twenty-six times I’ve been trusted to take the game-winning shot and missed. I’ve failed over and over and over again in my life. And that is why I succeed.”',
      'author': 'Michael Jordan',
      'role': 'Basketball Player',
      'image': 'assets/images/legend/jordan.png',
    },
    {
      'text':
      '“I am the greatest, I said that even before I knew I was. I always knew I was destined for greatness. Some people will say, \'You\'re lucky.\' But luck is a combination of hard work and opportunity. If you put in the effort, the world will open doors for you.”',
      'author': 'Muhammad Ali',
      'role': 'Boxer',
      'image': 'assets/images/legend/ali.png',
    },
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double quoteSectionHeight = screenHeight * 0.35;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
          ),
        ),
        child: Column(
          children: [
            // Quote Section
            Container(
              height: quoteSectionHeight,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _quotes.length,
                      itemBuilder: (context, index) {
                        final quote = _quotes[index];
                        return _buildQuoteCard(
                          quote['text']!,
                          quote['author']!,
                          quote['role']!,
                          quote['image']!,
                        );
                      },
                    ),
                  ),
                  _buildIndicator(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Validation Code Input Section
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x28808080),
                        blurRadius: 20,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enter Validation Code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF39434F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Please enter the 4-digit code sent to your email.',
                        style: TextStyle(
                          color: Color(0xFF808B9A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildValidationCodeField(),
                      const SizedBox(height: 360),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(
      String text, String author, String role, String image) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x26202326),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFF7FAFC),
                fontSize: 14,
                height: 1.67,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            _buildQuoteAuthor(author, role, image),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteAuthor(String author, String role, String image) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 17),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              role,
              style: const TextStyle(
                color: Color(0xFFC6CED9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _quotes.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationCodeField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 50,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            controller: _controllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.cyan),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final code = _controllers.map((c) => c.text).join();
          print("Entered code: $code"); // Replace with your logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Verify Code',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
