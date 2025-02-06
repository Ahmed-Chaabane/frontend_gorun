import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'forgot_password_screen.dart';
import 'get_started_signup.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google sign-up method
  Future<User?> _signUpWithGoogle() async {
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
            builder: (context) => GetStartedSignupScreen(
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
    double signupFormHeight = screenHeight * 0.65; // 60% for signup form

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
                  const SizedBox(height: 20), // Added padding below the indicator
                ],
              ),
            ),
            // Use SingleChildScrollView for the signup form only
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
                  child: _buildSignupForm(),
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

  Widget _buildSignupForm() {
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
          _buildSignupHeader(),
          const SizedBox(height: 24),
          _buildFirstNameField(),
          const SizedBox(height: 16),
          _buildLastNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPhoneNumberField(context),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildAgree(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          Divider(), // Added a separator
          const SizedBox(height: 24),
          _buildSignUpPrompt(),
          Divider(), // Added a separator
          const SizedBox(height: 24),
          _buildGoogleSignUpButton(),
        ],
      ),
    );
  }

  Widget _buildSignupHeader() {
    return Column(
      children: [
        Text(
          'Sign up',
          style: TextStyle(
            color: Color(0xFF39434F),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Hello there! Let\'s create your account',
          style: TextStyle(
            color: Color(0xFF808B9A),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstNameField() {
    return SizedBox(
      height: 60, // Increased height
      child: TextField(
        decoration: InputDecoration(
          labelText: 'First name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFFD1E6FF)), // Default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF1B85F3)), // Blue border when focused
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildLastNameField() {
    return SizedBox(
      height: 60, // Increased height
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Last name',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFFD1E6FF)), // Default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF1B85F3)), // Blue border when focused
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
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
            borderSide: BorderSide(color: Color(0xFFD1E6FF)), // Default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF1B85F3)), // Blue border when focused
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(BuildContext context) {
    String selectedCountryCode = '+216'; // Default country code
    String selectedCountryFlag = 'TN'; // Default country flag code

    return SizedBox(
      height: 70, // Ensuring the height is consistent with other fields
      child: IntlPhoneField(
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Country flag (using SVG assets)
                SvgPicture.asset(
                  'assets/flags/${selectedCountryFlag.toLowerCase()}.svg',
                  width: 24,
                  height: 16,
                  placeholderBuilder: (BuildContext context) =>
                  const Icon(Icons.flag, size: 24),
                ),
                const SizedBox(width: 8),
                // Country code with a tap-to-select feature
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() {
                          selectedCountryCode = '+${country.phoneCode}';
                          selectedCountryFlag = country.countryCode;
                        });
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        selectedCountryCode,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Vertical divider for visual separation
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          labelText: 'Phone number',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD1E6FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1B85F3)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        initialCountryCode: 'TN', // Default country code
        onChanged: (phone) {
          // Handle phone number change if needed
          print(phone.completeNumber);
        },
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
            borderSide: BorderSide(color: Color(0xFFD9DFE6)), // Default border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF1B85F3)), // Blue border when focused
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildAgree() {
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
          'I agree to the terms and conditions',
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
              //  logic
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
              'Create account',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Joined us before? ',
          style: TextStyle(color: Color(0xFF606873), fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: const Text(
            'Login',
            style: TextStyle(color: Color(0xFF1B85F3), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignUpButton() {
    return GestureDetector( // On garde GestureDetector pour le style exact
      onTap: () async {
        User? user = await _signUpWithGoogle();

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Google sign-in failed!")),
          );
        }
      },
      child: Container( // On garde Container pour le style exact
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blue, // Google color
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/google.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Sign up with Google',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}