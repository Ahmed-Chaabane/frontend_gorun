import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isPasswordVisible = false;
  bool isCheckboxChecked = false;

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
      'image': 'assets/images/legend/klay.png',
    },
    {
      'text':
      '“I don\'t think limits. I think you can go as far as your talent and effort can take you. A true champion knows that the limit does not exist. You must aim high, push yourself, and keep going until you’re breaking your own records, rewriting your own history.”',
      'author': 'Usain Bolt',
      'role': 'Olympic Sprinter',
      'image': 'assets/images/legend/bolt.png',
    },
    {
      'text':
      '“Success is not about how much money you make, but the difference you make in people’s lives. Being a leader is not about being the loudest in the room. It’s about inspiring others, having the courage to lead with integrity, and never giving up on the journey.”',
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
    if (_pageController.hasClients) {
      int nextPage = (_currentPage + 1) % _quotes.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = nextPage;
      });
      Future.delayed(const Duration(seconds: 5), _autoScrollQuotes);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double quoteSectionHeight = screenHeight * 0.35;
    double loginFormHeight = screenHeight * 0.65;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4DD4DE), // Ocean blue
              const Color(0xFF0C1A37), // Deeper ocean
              const Color(0xFF0C1A37), // Deeper ocean
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLoginHeader(),
                      const SizedBox(height: 24),
                      _buildEmailField(),
                      const SizedBox(height: 300),
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
          color: Color(0x26202326),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              role,
              style: TextStyle(
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
        _buildLoginHeader(),
        const SizedBox(height: 24),
        _buildEmailField(),
        const SizedBox(height: 20), // Adjusted size to avoid hardcoding
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildLoginHeader() {
    return Column(
      children: [
        Text(
          'Forgot password',
          style: TextStyle(
            color: Color(0xFF39434F),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Don’t worry! It’s happens. Please enter the email address associated with your account.',
          style: TextStyle(
            color: Color(0xFF808B9A),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return SizedBox(
      height: 80,
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Insert email address',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFFD1E6FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF1B85F3)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/validation_code');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF162A5A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}