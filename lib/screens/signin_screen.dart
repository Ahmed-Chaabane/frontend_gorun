import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_gorun/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'get_started_signin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs et focus nodes
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Variables d'état
  int _currentPage = 0;
  bool _isPasswordVisible = false;
  bool _isCheckboxChecked = false;
  bool _isLoading = false;

  // Authentification Google
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '358465763062-0isj5g1km6p4nr01atoj1hagftotd1v7.apps.googleusercontent.com',
  );

  // Citations
  static const List<Map<String, dynamic>> _quotes = [
    {
      'text': '“I’ve missed more than 9,000 shots in my career. I’ve lost almost 300 games. Twenty-six times I’ve been trusted to take the game-winning shot and missed. I’ve failed over and over and over again in my life. And that is why I succeed.”',
      'author': 'Michael Jordan',
      'role': 'Basketball Player',
      'image': 'assets/images/legend/jordan.png',
    },
    {
      'text': '“I am the greatest, I said that even before I knew I was. I always knew I was destined for greatness. Some people will say, \'You\'re lucky.\' But luck is a combination of hard work and opportunity. If you put in the effort, the world will open doors for you.”',
      'author': 'Muhammad Ali',
      'role': 'Boxer',
      'image': 'assets/images/legend/klay.png',
    },
    {
      'text': '“I don\'t think limits. I think you can go as far as your talent and effort can take you. A true champion knows that the limit does not exist. You must aim high, push yourself, and keep going until you’re breaking your own records, rewriting your own history.”',
      'author': 'Usain Bolt',
      'role': 'Olympic Sprinter',
      'image': 'assets/images/legend/bolt.png',
    },
    {
      'text': '“Success is not about how much money you make, but the difference you make in people’s lives. Being a leader is not about being the loudest in the room. It’s about inspiring others, having the courage to lead with integrity, and never giving up on the journey.”',
      'author': 'Stephen Curry',
      'role': 'Basketball Player',
      'image': 'assets/images/legend/curry.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _isCheckboxChecked = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isCheckboxChecked) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 30), () {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _quotes.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        setState(() => _currentPage = nextPage);
        _startAutoScroll();
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GetStartedSigninScreen(
              userName: user.displayName ?? "Utilisateur",
              userImageUrl: user.photoURL ?? "",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_validateFields()) return;

    setState(() => _isLoading = true);
    try {
      await _saveCredentials();

      final result = await AuthService().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result.startsWith('Connexion réussie') && mounted) {
        Navigator.pushReplacementNamed(context, '/get_started_signin');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateFields() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un email valide')),
      );
      return false;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le mot de passe doit contenir au moins 6 caractères')),
      );
      return false;
    }

    return true;
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
                  child: _buildLoginForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> quote) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x26202326),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
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
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 14),
              _buildQuoteAuthor(quote),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteAuthor(Map<String, dynamic> quote) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildLoginHeader(),
        const SizedBox(height: 24),
        _buildEmailField(),
        const SizedBox(height: 26),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildRememberMeCheckbox(),
        const SizedBox(height: 24),
        _buildLoginButtons(),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildSignUpPrompt(),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        _buildGoogleSignInButton(),
      ],
    );
  }

  Widget _buildLoginHeader() {
    return const Column(
      children: [
        Text(
          'Login',
          style: TextStyle(
            color: Color(0xFF39434F),
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
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
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
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

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
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

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _isCheckboxChecked,
          onChanged: (value) => setState(() => _isCheckboxChecked = value ?? false),
          activeColor: _isCheckboxChecked ? const Color(0xFF1B85F3) : const Color(0xFF808B9A),
        ),
        const Text(
          'Remember information',
          style: TextStyle(
            color: Color(0xFF808B9A),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C1A37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              'Join now',
              style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/forgot_password'),
          child: const Text(
            'Forget password?',
            style: TextStyle(color: Color(0xFF1B85F3), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'First time here? ',
          style: TextStyle(color: Color(0xFF606873), fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
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
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 1,
          shadowColor: const Color(0xFF4285F4).withOpacity(0.3),
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
              "Continuer avec Google",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}