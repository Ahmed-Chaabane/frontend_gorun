import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend_gorun/screens/Community_Challenge_Screen.dart';
import 'package:frontend_gorun/screens/Goals_Screen.dart';
import 'package:frontend_gorun/screens/Hydration_Screen.dart';
import 'package:frontend_gorun/screens/audioPlayerModel.dart';
import 'package:frontend_gorun/screens/basketball_screen.dart';
import 'package:frontend_gorun/screens/cycling_screen.dart';
import 'package:frontend_gorun/screens/football_screen.dart';
import 'package:frontend_gorun/screens/get_started_signin.dart';
import 'package:frontend_gorun/screens/get_started_signup.dart';
import 'package:frontend_gorun/screens/hiking_screen.dart';
import 'package:frontend_gorun/screens/home_screen.dart';
import 'package:frontend_gorun/screens/music_screen.dart';
import 'package:frontend_gorun/screens/nutrition_screen.dart';
import 'package:frontend_gorun/screens/personalized_journey_screen.dart';
import 'package:frontend_gorun/screens/running_screen.dart';
import 'package:frontend_gorun/screens/signup_screen.dart';
import 'package:frontend_gorun/screens/sleep_screen.dart';
import 'package:frontend_gorun/screens/splash_screen.dart';
import 'package:frontend_gorun/screens/step_eight_screen.dart';
import 'package:frontend_gorun/screens/step_five_screen.dart';
import 'package:frontend_gorun/screens/step_four_screen.dart';
import 'package:frontend_gorun/screens/step_one_screen.dart';
import 'package:frontend_gorun/screens/step_seven_screen.dart';
import 'package:frontend_gorun/screens/step_six_screen.dart';
import 'package:frontend_gorun/screens/step_three_screen.dart';
import 'package:frontend_gorun/screens/step_two_screen.dart';
import 'package:frontend_gorun/screens/swimming_screen.dart';
import 'package:frontend_gorun/screens/tennis_screen.dart';
import 'package:frontend_gorun/screens/validation_code_screen.dart';
import 'package:frontend_gorun/screens/volleyball_screen.dart';
import 'package:frontend_gorun/screens/weight_screen.dart';
import 'package:frontend_gorun/screens/yoga_screen.dart';
import 'package:provider/provider.dart';
import 'providers/notification_provider.dart';
import 'firebase_options.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signin_screen.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:frontend_gorun/screens/Recuperation_Blessure_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialisation de Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    runApp(
      MultiProvider(
        providers: [
          // Fournisseur pour gérer l'état du lecteur audio
          ChangeNotifierProvider(create: (_) => AudioPlayerModel()),

          // Fournisseur pour gérer les notifications de motivation
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    print("Erreur lors de l'initialisation de Firebase: $e");

    // Afficher un message d'erreur dans l'UI si Firebase échoue
    runApp(MyAppError(error: e.toString()));
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
      debugShowCheckedModeBanner: false, // Supprime le bandeau de débogage
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/validation_code': (context) => ValidationCodeScreen(),
        '/get_started_signin': (context) => GetStartedSigninScreen(
          userName: '',
          userImageUrl: '',
        ),
        '/get_started_signup': (context) => GetStartedSignupScreen(
          userName: '',
          userImageUrl: '',
        ),
        '/personalized_journey': (context) => PersonalizedJourney(),
        '/step_one': (context) => Step1(),
        '/step_two': (context) => Step2(),
        '/step_three': (context) => Step3(),
        '/step_four': (context) => Step4(),
        '/step_five': (context) => Step5(),
        '/step_six': (context) => Step6(),
        '/step_seven': (context) => Step7(),
        '/step_eight': (context) => Step8(),
        '/home_screen': (context) => HomeScreen(),
        '/music_screen': (context) => MusicScreen(),
        '/yoga_screen': (context) => YogaTracker(),
        '/weight_screen': (context) => WeightTrainingTracker(),
        '/volleyball_screen': (context) => VolleyballTracker(),
        '/tennis_screen': (context) => TennisTracker(),
        '/swimming_screen': (context) => SwimmingTracker(),
        '/running_screen': (context) => RunningTracker(),
        '/hiking_screen': (context) => HikingTracker(),
        '/football_screen': (context) => FootballTracker(),
        '/basketball_screen': (context) => BasketballTracker(),
        '/cycling_screen': (context) => CyclingTracker(),
        '/objectif_screen': (context) => DefineGoalScreen(),
        '/community_challenge_screen': (context) => CommunityChallengeScreen(),
        '/SleepGoalScreen': (context) => SleepGoalScreen(),
        '/hydration_screen': (context) => HydrationScreen(),
        '/nutrition_screen': (context) => NutritionScreen(),
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
