import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_gorun/screens/get_started_signin.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '358465763062-0isj5g1km6p4nr01atoj1hagftotd1v7.apps.googleusercontent.com', // Remplacez par votre Client ID
  );

  // Fonction de connexion Google
  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        String userName = user.displayName ?? "User";
        String userImageUrl = user.photoURL ?? "https://via.placeholder.com/150";

        print("User Name: $userName");
        print("User Email: ${user.email}");
        print("User Image: $userImageUrl");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GetStartedSigninScreen(
              userName: userName,
              userImageUrl: userImageUrl,
            ),
          ),
        );
      }
      return user;
    } catch (e) {
      print("Error with Google sign-in: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Start auto scrolling after a 5-second delay
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
      // Schedule the next scroll after 5 seconds
      Future.delayed(const Duration(seconds: 5), _autoScrollQuotes);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double quoteSectionHeight = screenHeight * 0.35; // 40% for quotes section
    double loginFormHeight = screenHeight * 0.65; // 60% for login form

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4DD4DE), // Ocean blue
              Color(0xFF0C1A37), // Deeper ocean
              Color(0xFF0C1A37), // Deeper ocean
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              height: quoteSectionHeight, // Set quote section to 40% height
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
                  // Added padding below the indicator
                ],
              ),
            ),
            // Use SingleChildScrollView for the login form only
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
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
                  child: _buildLoginForm(),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
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
        children: [
          _buildLoginHeader(),
          const SizedBox(height: 24),
          _buildEmailField(),
          const SizedBox(height: 26),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberMe(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          Divider(), // Added a separator
          const SizedBox(height: 24),
          _buildSignInPrompt(),
          const SizedBox(height: 24),
          Divider(), // Added a
          const SizedBox(height: 24),
          _buildGoogleSignInButton(),
        ],
      ),
    );
  }

  Widget _buildLoginHeader() {
    return Column(
      children: [
        Text(
          'Login',
          style: TextStyle(
            color: Color(0xFF39434F),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome back! Please enter your details.',
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
      height: 60, // Increased height
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Color(0xFFD1E6FF)), // Default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Color(0xFF1B85F3)), // Blue border when focused
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      height: 60, // Increased height
      child: TextField(
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Color(0xFFD9DFE6)), // Default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Color(0xFF1B85F3)), // Blue border when focused
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: isCheckboxChecked,
          onChanged: (value) {
            setState(() {
              isCheckboxChecked = value!;
            });
          },
        ),
        const Text(
          'Remember information',
          style: TextStyle(color: Color(0xFF808B9A), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          // Match the width of the email/password fields
          height: 60,
          // Set a consistent height
          child: ElevatedButton(
            onPressed: isCheckboxChecked
                ? () {
                    // Login logic
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isCheckboxChecked ? Color(0xFF162A5A) : Color(0xFFC6CED9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Join now',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Forget password logic
            Navigator.of(context).pushReplacementNamed('/forgot_password');
          },
          child: const Text(
            'Forget password?',
            style: TextStyle(color: Color(0xFF1B85F3), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'First time here? ',
          style: TextStyle(color: Color(0xFF606873), fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/signup');
          },
          child: const Text(
            'Sign up for free',
            style: TextStyle(color: Color(0xFF1B85F3), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity, // Match the width of the "Join now" button
      height: 60, // Match the height to "Join now"
      child: ElevatedButton(
        onPressed: () async {
          User? user = await _signInWithGoogle();
          if (user != null) {
            print("Utilisateur connecté avec Google: ${user.displayName}");
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            print("Échec de la connexion Google");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4285F4), // Google blue color
          foregroundColor: Colors.white, // Text color set to white
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14), // Same radius as "Join now"
          ),
          padding: EdgeInsets
              .zero, // Remove internal padding to control the size manually
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/google-icon.png', width: 24),
            SizedBox(width: 10),
            Text(
              "Sign in with Google",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
