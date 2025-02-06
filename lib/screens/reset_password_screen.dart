import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final PageController _pageController = PageController();
  String? _passwordError;
  String? _repeatPasswordError;
  bool isPasswordVisible = false;
  bool isRepeatPasswordVisible = false;
  int _currentPage = 0;

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
      '“I am the greatest, I said that even before I knew I was. Luck is a combination of hard work and opportunity. Put in the effort, and the world will open doors for you.”',
      'author': 'Muhammad Ali',
      'role': 'Boxer',
      'image': 'assets/images/legend/klay.png',
    },
    {
      'text':
      '“I don\'t think limits. You can go as far as your talent and effort can take you. Aim high, push yourself, and keep breaking your own records.”',
      'author': 'Usain Bolt',
      'role': 'Olympic Sprinter',
      'image': 'assets/images/legend/bolt.png',
    },
    {
      'text':
      '“Success is not about how much money you make, but the difference you make in people’s lives. Inspire others, lead with integrity, and never give up.”',
      'author': 'Stephen Curry',
      'role': 'Basketball Player',
      'image': 'assets/images/legend/curry.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 30), _autoScrollQuotes);
  }

  void _autoScrollQuotes() {
    if (!mounted || !_pageController.hasClients) return;
    int nextPage = (_currentPage + 1) % _quotes.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 5), _autoScrollQuotes);
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
            colors: [
              Color(0xFF4DD4DE),
              Color(0xFF0C1A37),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              height: quoteSectionHeight,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int index) {
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
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x28808080),
                        blurRadius: 20,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: _buildLoginForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(String text, String author, String role, String image) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x26202326),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFF7FAFC),
                fontSize: 14,
                height: 1.67,
              ),
              textAlign: TextAlign.left,
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
      crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildLoginForm() {
    return Column(
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(
            color: Color(0xFF39434F),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 26),
        _buildPasswordInputField(
          controller: _passwordController,
          label: 'Password',
          isVisible: isPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          onChanged: (value) {
            setState(() {
              _passwordError = validatePassword(value);
            });
          },
          error: _passwordError,
        ),
        const SizedBox(height: 26),
        _buildPasswordInputField(
          controller: _repeatPasswordController,
          label: 'Repeat Password',
          isVisible: isRepeatPasswordVisible,
          onToggleVisibility: () {
            setState(() {
              isRepeatPasswordVisible = !isRepeatPasswordVisible;
            });
          },
          onChanged: (value) {
            setState(() {
              _repeatPasswordError = value != _passwordController.text
                  ? 'Passwords do not match'
                  : null;
            });
          },
          error: _repeatPasswordError,
        ),
        const SizedBox(height: 290),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPasswordInputField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required ValueChanged<String> onChanged,
    String? error,
  }) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          prefixIcon: const Icon(Icons.lock, color: Colors.grey), // Restored Icon
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _passwordError = validatePassword(_passwordController.text);
            _repeatPasswordError =
            _repeatPasswordController.text != _passwordController.text
                ? 'Passwords do not match'
                : null;
          });

          if (_passwordError == null && _repeatPasswordError == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password reset successful!')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  String? validatePassword(String password) {
    if (password.length < 12) {
      return 'Password must be at least 12 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}
