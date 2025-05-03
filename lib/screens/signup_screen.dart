import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/auth_service.dart';

final AuthService _authService = AuthService();

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isPasswordVisible = false;
  bool _isCheckboxChecked = false;

  // Contrôleurs
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUpUser() async {
    try {
      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();
      String email = _emailController.text.trim();
      String phoneNumber = _phoneNumberController.text.trim();
      String password = _passwordController.text.trim();

      if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || phoneNumber.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez remplir tous les champs.")),
        );
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        String result = await _authService.createAccount(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          firebaseUid: user.uid,
          password: '',
        );

        if (result.contains('Compte créé')) {
          Navigator.pushReplacementNamed(context, '/get_started_signup');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
              Color(0xFF0C1A37),
            ],
          ),
        ),
        child: Column(
          children: [
            // Section des citations (35% de l'écran)
            SizedBox(
              height: screenHeight * 0.35,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemCount: _quotes.length,
                      itemBuilder: (context, index) => _buildQuoteCard(_quotes[index]),
                    ),
                  ),
                  _buildPageIndicator(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Section du formulaire (65% de l'écran)
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
                  child: _buildSignupForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Liste des citations (identique au login)
  static const List<Map<String, dynamic>> _quotes = [
    {
      'text': '“I’ve missed more than 9,000 shots in my career. I’ve lost almost 300 games. Twenty-six times I’ve been trusted to take the game-winning shot and missed. I’ve failed over and over and over again in my life. And that is why I succeed.”',
      'author': 'Michael Jordan',
      'role': 'Basketball Player',
      'image': 'assets/images/legend/jordan.png',
    },
    // ... autres citations
  ];

  Widget _buildQuoteCard(Map<String, dynamic> quote) {
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
              quote['text']!,
              style: const TextStyle(
                color: Color(0xFFF7FAFC),
                fontSize: 14,
                height: 1.67,
              ),
            ),
            const SizedBox(height: 14),
            _buildQuoteAuthor(quote),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteAuthor(Map<String, dynamic> quote) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            quote['image']!,
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
              quote['author']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              quote['role']!,
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

  Widget _buildPageIndicator() {
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
    return Column(
      children: [
        _buildSignupHeader(),
        const SizedBox(height: 24),
        _buildFirstNameField(),
        const SizedBox(height: 16),
        _buildLastNameField(),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPhoneNumberField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildAgreeCheckbox(),
        const SizedBox(height: 24),
        _buildSignupButton(),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        _buildLoginPrompt(),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        _buildGoogleSignInButton(),
      ],
    );
  }

  Widget _buildSignupHeader() {
    return const Column(
      children: [
        Text(
          'Sign up',
          style: TextStyle(
            color: Color(0xFF39434F),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
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
    return TextField(
      controller: _firstNameController,
      decoration: InputDecoration(
        labelText: 'First name',
        labelStyle: const TextStyle(
          color: Color(0xFF808B9A),
          fontSize: 16,
        ),
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0C1A37)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1B85F3),
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      style: const TextStyle(color: Color(0xFF39434F), fontSize: 16),
    );
  }

  Widget _buildLastNameField() {
    return TextField(
      controller: _lastNameController,
      decoration: InputDecoration(
        labelText: 'Last name',
        labelStyle: const TextStyle(
          color: Color(0xFF808B9A),
          fontSize: 16,
        ),
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF0C1A37)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1B85F3),
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      style: const TextStyle(color: Color(0xFF39434F), fontSize: 16),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(
          color: Color(0xFF808B9A),
          fontSize: 16,
        ),
        hintText: 'entrez@votre.email',
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0C1A37)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1B85F3),
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      style: const TextStyle(color: Color(0xFF39434F), fontSize: 16),
    );
  }

  Widget _buildPhoneNumberField() {
    return IntlPhoneField(
      controller: _phoneNumberController,
      decoration: InputDecoration(
        labelText: 'Phone number',
        labelStyle: const TextStyle(
          color: Color(0xFF808B9A),
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1B85F3),
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      initialCountryCode: 'TN',
      style: const TextStyle(color: Color(0xFF39434F), fontSize: 16),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(
          color: Color(0xFF808B9A),
          fontSize: 16,
        ),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF0C1A37)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF808B9A),
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1B85F3),
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      style: const TextStyle(color: Color(0xFF39434F), fontSize: 16),
    );
  }

  Widget _buildAgreeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isCheckboxChecked,
          onChanged: (value) => setState(() => _isCheckboxChecked = value ?? false),
          activeColor: _isCheckboxChecked ? const Color(0xFF1B85F3) : const Color(0xFF808B9A),
        ),
        const Text(
          'I agree to the terms and conditions',
          style: TextStyle(color: Color(0xFF808B9A), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isCheckboxChecked ? _signUpUser : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C1A37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Create account',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Joined us before? ',
          style: TextStyle(color: Color(0xFF606873), fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Login',
            style: TextStyle(color: Color(0xFF1B85F3), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final User? user = await _authService.signInWithGoogle();
            if (user != null && mounted) {
              // Vérifier si l'utilisateur est nouveau ou existant
              bool isNewUser = user.metadata.creationTime == user.metadata.lastSignInTime;

              if (isNewUser) {
                // Nouvel utilisateur - rediriger vers l'écran d'inscription
                Navigator.pushReplacementNamed(context, '/get_started_signup');
              } else {
                // Utilisateur existant - rediriger vers l'écran de connexion
                Navigator.pushReplacementNamed(context, '/get_started_signin');
              }
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'account-exists-with-different-credential') {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Un compte existe déjà avec cette adresse email.'),
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur: ${e.toString()}")),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Erreur: ${e.toString()}")),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(6),
              child: const FaIcon(
                FontAwesomeIcons.google,
                color: Color(0xFF4285F4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Sign up with Google",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}