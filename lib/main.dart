import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend_gorun/screens/About_Screen.dart';
import 'package:frontend_gorun/screens/Community_Challenge_Screen.dart';
import 'package:frontend_gorun/screens/Goals_Screen.dart';
import 'package:frontend_gorun/screens/HelpSupportScreen.dart';
import 'package:frontend_gorun/screens/History_Activity_Screen.dart';
import 'package:frontend_gorun/screens/Hydration_Screen.dart';
import 'package:frontend_gorun/screens/Profile_Screen.dart';
import 'package:frontend_gorun/screens/Settings_Screen.dart';
import 'package:frontend_gorun/screens/Training_Screen.dart';
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
import 'package:frontend_gorun/screens/spotify_login_screen.dart';
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
import 'package:frontend_gorun/theme_controller.dart';
import 'firebase_options.dart';
import 'providers/notification_provider.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeController()),
          ChangeNotifierProvider(create: (_) => AudioPlayerModel()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    runApp(MyAppError(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          title: 'GoRun App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          themeMode: themeController.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot_password': (context) => const ForgotPasswordScreen(),
            '/reset_password': (context) => const ResetPasswordScreen(),
            '/validation_code': (context) => const ValidationCodeScreen(),
            '/get_started_signin': (context) => GetStartedSigninScreen(
              userName: '',
              userImageUrl: '',
            ),
            '/get_started_signup': (context) => GetStartedSignupScreen(
              userName: '',
              userImageUrl: '',
            ),
            '/personalized_journey': (context) => const PersonalizedJourney(),
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
            '/profile': (context) => SpotifyLoginScreen(),
            '/help_support': (context) => HelpSupportScreen(),
            '/settings': (context) => SettingsScreen(),
            '/about': (context) => AboutScreen(),
            '/profilo': (context) => ProfileScreen(),
            '/history': (context) => HistoryActiviteSportifScreen(),
            '/trainings': (context) => TrainingScreen(),
          },
        );
      },
    );
  }
}

class MyAppError extends StatelessWidget {
  final String error;

  const MyAppError({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Erreur d'initialisation")),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }
}