import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:frontend_gorun/screens/signup_screen.dart';
import 'package:frontend_gorun/screens/validation_code_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'package:frontend_gorun/screens/get_started_signin.dart';
import 'package:frontend_gorun/screens/get_started_signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(MyApp());
  } catch (e) {
    print("Erreur lors de l'initialisation de Firebase: $e");
    runApp(MyAppError(error: e.toString())); // Affiche un message d'erreur dans l'UI si Firebase échoue
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoRun App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Utiliser Roboto comme police par défaut
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/validation_code': (context) => ValidationCodeScreen(),
        '/get_started_signin': (context) => GetStartedSigninScreen(userName: '', userImageUrl: '',),
        '/get_started_signup': (context) => GetStartedSignupScreen(userName: '', userImageUrl: '',),
      },
    );
  }
}

class MyAppError extends StatelessWidget {
  final String error;
  MyAppError({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Erreur d'initialisation")),
        body: Center(
          child: Text('Erreur lors de l\'initialisation de Firebase: $error'),
        ),
      ),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Authentification avec Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Erreur d\'authentification avec Google: $e');
      return null;
    }
  }

  // Se déconnecter
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Vérifier si l'utilisateur est connecté
  Stream<User?> get user => _auth.authStateChanges();
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome Home')),
      body: Center(child: Text('You are logged in!')),
    );
  }
}

class SignInScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await authService.signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}
