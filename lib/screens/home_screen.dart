import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend_gorun/screens/basketball_screen.dart';
import 'package:frontend_gorun/screens/cycling_screen.dart';
import 'package:frontend_gorun/screens/football_screen.dart';
import 'package:frontend_gorun/screens/hiking_screen.dart';
import 'package:frontend_gorun/screens/music_screen.dart';
import 'package:frontend_gorun/screens/running_screen.dart';
import 'package:frontend_gorun/screens/sleep_screen.dart';
import 'package:frontend_gorun/screens/swimming_screen.dart';
import 'package:frontend_gorun/screens/tennis_screen.dart';
import 'package:frontend_gorun/screens/volleyball_screen.dart';
import 'package:frontend_gorun/screens/weight_screen.dart';
import 'package:frontend_gorun/screens/yoga_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'Community_Challenge_Screen.dart';
import 'Goals_Screen.dart';
import 'Hydration_Screen.dart';

// Constants for reusability
class AppConstants {
  static const kPrimaryGradient = LinearGradient(
    colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const kDefaultPadding =
  EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  static const kCardMargin = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  static const kCardBorderRadius = BorderRadius.all(Radius.circular(15));
}

// Custom theme
final ThemeData customTheme = ThemeData(
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
    headlineSmall: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
  ),
);

// Widget for gradient text
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    Key? key,
    required this.text,
    required this.style,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Widget for gradient icons
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    Key? key,
    required this.icon,
    required this.size,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}

// Main screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> benefits = [
    {
      'name': 'Running',
      'description':
      'Améliorez votre endurance et votre santé cardiovasculaire.',
      'icon': Icons.directions_run_rounded
    },
    {
      'name': 'Cycling',
      'description':
      'Renforcez vos muscles des jambes et améliorez votre endurance.',
      'icon': Icons.directions_bike_rounded
    },
    {
      'name': 'Yoga',
      'description': 'Améliorez votre flexibilité, équilibre et santé mentale.',
      'icon': Icons.self_improvement_rounded
    },
    {
      'name': 'Swimming',
      'description':
      'Entraînement complet du corps avec un faible impact sur les articulations.',
      'icon': Icons.pool
    },
    {
      'name': 'Football',
      'description': 'Améliorez votre coordination et esprit d\'équipe.',
      'icon': Icons.sports_soccer
    },
    {
      'name': 'Tennis',
      'description': 'Boostez vos réflexes et coordination main-œil.',
      'icon': Icons.sports_tennis
    },
    {
      'name': 'Basketball',
      'description': 'Améliorez votre agilité et endurance cardiovasculaire.',
      'icon': Icons.sports_basketball
    },
    {
      'name': 'Volleyball',
      'description':
      'Renforcez le travail d\'équipe et les muscles du haut du corps.',
      'icon': Icons.sports_volleyball
    },
    {
      'name': 'Weight Training',
      'description': 'Augmentez la force musculaire et la densité osseuse.',
      'icon': Icons.fitness_center
    },
    {
      'name': 'Hiking',
      'description': 'Explorez la nature tout en améliorant votre endurance.',
      'icon': Icons.terrain
    },
  ];

  final List<Map<String, dynamic>> additionalHabits = [
    {
      'name': 'Radio',
      'description': 'Écoutez votre musique préférée.',
      'icon': Icons.radio_rounded
    },
    {
      'name': 'Nutrition',
      'description': 'Suivez votre apport nutritionnel quotidien.',
      'icon': Icons.fastfood
    },
    {
      'name': 'Challenges',
      'description': 'Relevez et complétez des défis fitness.',
      'icon': Icons.fitness_center
    },
    {
      'name': 'Goals',
      'description': 'Fixez et atteignez vos objectifs personnels.',
      'icon': Icons.check_circle_outline
    },
    {
      'name': 'Sleep',
      'description': 'Surveillez et améliorez votre qualité de sommeil.',
      'icon': Icons.bedtime
    },
    {
      'name': 'Hydration',
      'description': 'Restez hydraté tout au long de la journée.',
      'icon': Icons.local_drink
    },
  ];

  final List<Map<String, dynamic>> achievements = [
    {
      'name': 'Débutant',
      'icon': Icons.star,
      'unlocked': true,
    },
    {
      'name': 'Runner',
      'icon': Icons.directions_run_rounded,
      'unlocked': false,
    },
    {
      'name': 'Hydraté',
      'icon': Icons.local_drink,
      'unlocked': false,
    },
    {
      'name': 'Champion',
      'icon': FontAwesomeIcons.trophy,
      'unlocked': false,
    },
    {
      'name': 'Marathonien',
      'icon': Icons.flag,
      'unlocked': false,
    },
  ];

  late PageController _pageController;
  int currentPage = 0;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> userChallenges = []; // Défis de l'utilisateur

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialiser le fuseau horaire
    _pageController = PageController(viewportFraction: 0.9);
    initNotifications();
    fetchUserChallenges(); // Récupérer les défis de l'utilisateur au démarrage
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Map<String, IconData> iconNameToIconData = {
    'dumbbell': FontAwesomeIcons.dumbbell,
    'running': FontAwesomeIcons.running,
    'spa': FontAwesomeIcons.spa,
    'heartbeat': FontAwesomeIcons.heartbeat,
    'weight': FontAwesomeIcons.weight,
    'bicycle': FontAwesomeIcons.bicycle,
    'swimmer': FontAwesomeIcons.swimmer,
    'om': FontAwesomeIcons.om,
    'shoePrints': FontAwesomeIcons.shoePrints,
    'users': FontAwesomeIcons.users,
    'hiking': FontAwesomeIcons.hiking,
    'bed': FontAwesomeIcons.bed,
    'dancing': FontAwesomeIcons.personDressBurst,
    // Ajoute d'autres icônes ici selon le besoin
  };

  // Récupérer les défis de l'utilisateur
  Future<void> fetchUserChallenges() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Aucun utilisateur connecté.');
        return;
      }

      final String firebaseUid = user.uid;

      // Récupérer les défis auxquels l'utilisateur participe via l'API
      final challengesResponse = await http.get(
        Uri.parse('http://localhost:3000/api/defiparticipants/user/challenges?firebase_uid=$firebaseUid'),
      );

      print('Réponse de l\'API pour les défis utilisateur : ${challengesResponse.statusCode} - ${challengesResponse.body}'); // Log de débogage

      if (challengesResponse.statusCode == 200) {
        List<dynamic> data = jsonDecode(challengesResponse.body);

        setState(() {
          userChallenges = data.map((item) {
            // Gestion de l'icône : utilisation d'une icône par défaut si l'icône est invalidée ou nulle
            String iconName = item['icon'] ?? 'default';  // Si aucune icône n'est trouvée, utiliser "default"
            IconData icon = iconNameToIconData[iconName] ?? FontAwesomeIcons.question;  // Icône par défaut si non trouvé

            return {
              'id': item['id_defi_communautaire'],
              'name': item['nom_defi'],
              'icon': icon,  // Assigner l'icône valide
              'description': item['description'],
              'participants': item['participants'] ?? 0,
              'reward': item['recompense'] ?? '',
              'progress': item['progression'] ?? 0.0,
            };
          }).toList();
        });
      } else {
        print('Erreur lors de la récupération des défis utilisateur : ${challengesResponse.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la récupération des défis utilisateur.')),
        );
      }
    } catch (e) {
      print('Erreur lors de la récupération des défis utilisateur : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 16),
            _buildMainTitle(),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: _buildPageView(),
            ),
            const SizedBox(height: 16),
            _buildHabitsTitle(),
            const SizedBox(height: 8),
            _buildAdditionalCards(),
            const SizedBox(height: 16),
            _buildCommunityChallenges(),
            const SizedBox(height: 16),
            _buildAchievements(),
            const SizedBox(height: 16),
            _buildFixedCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'uniqueTagForFAB',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MusicScreen()),
          );
        },
        child: const Icon(Icons.music_note, color: Colors.white),
        backgroundColor: const Color(0xFF0C1A37),
      ),
    );
  }

  // Top section with gradient menu icon
  Widget _buildTopSection() {
    return Container(
      padding: AppConstants.kDefaultPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return AppConstants.kPrimaryGradient.createShader(bounds);
            },
            child: IconButton(
              icon: const Icon(Icons.menu, size: 35),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu ouvert !')),
                );
              },
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // PageView for cards
  Widget _buildPageView() {
    return Listener(
      onPointerMove: (details) {
        if (details.delta.dx > 5 && currentPage > 0) {
          _pageController.animateToPage(
            currentPage - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else if (details.delta.dx < -5 && currentPage < benefits.length - 1) {
          _pageController.animateToPage(
            currentPage + 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) => setState(() => currentPage = index),
        itemCount: benefits.length,
        itemBuilder: (context, index) {
          final double offset = (index - currentPage) * 0.5;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: _buildBenefitCard(benefits[index], index),
          );
        },
      ),
    );
  }

  // Benefit card with specific navigation for each sport
  Widget _buildBenefitCard(Map<String, dynamic> benefit, int index) {
    final Map<String, Widget Function()> sportScreens = {
      'Running': () => RunningTracker(),
      'Cycling': () => CyclingTracker(),
      'Yoga': () => YogaTracker(),
      'Swimming': () => SwimmingTracker(),
      'Football': () => FootballTracker(),
      'Tennis': () => TennisTracker(),
      'Basketball': () => BasketballTracker(),
      'Volleyball': () => VolleyballTracker(),
      'Weight Training': () => WeightTrainingTracker(),
      'Hiking': () => HikingTracker(),
    };

    return GestureDetector(
      onTap: () {
        if (sportScreens.containsKey(benefit['name'])) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => sportScreens[benefit['name']]!()),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: AppConstants.kCardMargin,
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppConstants.kCardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C1A37).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: AppConstants.kPrimaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(benefit['icon'], size: 100, color: Colors.white),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // Main title
  Widget _buildMainTitle() {
    return Padding(
      padding: AppConstants.kDefaultPadding,
      child: const Text(
        'What are you up to today?',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  // Habits title
  Widget _buildHabitsTitle() {
    return Padding(
      padding: AppConstants.kDefaultPadding,
      child: const Text(
        'Your habits',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  // Additional cards
  Widget _buildAdditionalCards() {
    return Padding(
      padding: AppConstants.kDefaultPadding,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: (additionalHabits.length / 2).ceil(),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, rowIndex) {
          final startIndex = rowIndex * 2;
          final endIndex = startIndex + 1;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (startIndex < additionalHabits.length)
                _buildSmallCard(additionalHabits[startIndex], startIndex),
              if (endIndex < additionalHabits.length)
                _buildSmallCard(additionalHabits[endIndex], endIndex),
            ],
          );
        },
      ),
    );
  }

  // Small card with specific navigation for each habit
  Widget _buildSmallCard(Map<String, dynamic> habit, int index) {
    final Map<String, Widget Function()> habitScreens = {
      'Radio': () => MusicScreen(),
      'Challenges': () => CommunityChallengeScreen(),
      'Goals': () => DefineGoalScreen(),
      'Sleep': () => SleepGoalScreen(),
      'Hydration': () => HydrationScreen(),
    };

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (habitScreens.containsKey(habit['name'])) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => habitScreens[habit['name']]!()),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: AppConstants.kCardMargin,
          width: 140,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppConstants.kCardBorderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientIcon(
                icon: habit['icon'],
                size: 50,
                gradient: AppConstants.kPrimaryGradient,
              ),
              const SizedBox(height: 8),
              GradientText(
                text: habit['name'],
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                gradient: AppConstants.kPrimaryGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fixed card (Rapports quotidiens)
  Widget _buildFixedCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/daily_reports');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width - 48,
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          gradient: AppConstants.kPrimaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rapports Quotidiens',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tous vos détails en un seul endroit.',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.white, Colors.white70],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(
                Icons.arrow_circle_right_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section des défis communautaires
  Widget _buildCommunityChallenges() {
    return Padding(
      padding: AppConstants.kDefaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Défis communautaires',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (userChallenges.isEmpty)
            Text(
              'Vous ne participez à aucun défi pour le moment.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          for (int i = 0; i < userChallenges.length; i++)
            _buildChallengeCard(userChallenges[i], i),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Padding(
      padding: AppConstants.kDefaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Médailles et Badges',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: achievements.map((achievement) {
              return _buildAchievementIcon(achievement);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon(Map<String, dynamic> achievement) {
    final bool unlocked = achievement['unlocked'];
    final IconData icon = achievement['icon'];
    final String name = achievement['name'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: unlocked ? Colors.yellow : Colors.grey,
                width: 4,
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: unlocked ? Colors.yellow : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Carte de défi communautaire
  Widget _buildChallengeCard(Map<String, dynamic> challengeData, int index) {
    final String challengeName = challengeData['name'];
    final IconData icon = challengeData['icon'];
    final String description = challengeData['description'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        height: 100, // Fixed height
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 2,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: const Color(0xFFF1F1F1),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x05323247),
              blurRadius: 15,
              offset: const Offset(0, 3),
              spreadRadius: -1.50,
            ),
            BoxShadow(
              color: const Color(0x0C0C1A4B),
              blurRadius: 3.75,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challengeName,
                      style: TextStyle(
                        color: Color(0xFF808B9A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Color(0xFF808B9A),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: CustomPaint(
                  size: Size(70, 70),
                  painter: GradientIconPainter(
                    icon: icon,
                    size: 60,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter pour les icônes avec dégradé
class GradientIconPainter extends CustomPainter {
  final IconData icon;
  final double size;
  final Gradient gradient;

  GradientIconPainter({
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, this.size, this.size);
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    final TextSpan span = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: this.size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        foreground: paint,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: this.size, maxWidth: this.size);
    textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}