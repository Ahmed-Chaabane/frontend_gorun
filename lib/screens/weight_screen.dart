import 'dart:async';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

// Habit Model
class Habit {
  final String title;
  final String value;
  final IconData icon;

  Habit({
    required this.title,
    required this.value,
    required this.icon,
  });
}

// Main Widget
class WeightTrainingTracker extends StatefulWidget {
  @override
  _WeightTrainingTrackerState createState() => _WeightTrainingTrackerState();
}

class _WeightTrainingTrackerState extends State<WeightTrainingTracker>
    with TickerProviderStateMixin {
  final ConfettiController _confettiController = ConfettiController(
      duration: const Duration(seconds: 1)); // Pour les confettis

  // Variables pour gérer l'état de l'activité
  bool _isStarted = false;
  bool _isPaused = false;

  // Statistiques de musculation
  int _exercises = 0;
  int _sets = 0;
  int _reps = 0;
  double _totalWeightLifted = 0.0;
  int _restTime = 0; // en secondes
  Timer? _timer;
  int _secondsElapsed = 0;

  late PageController _pageController;
  int currentPage = 0;

  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _initializeHabits(); // Initialisation des habitudes
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeHabits() {
    habits = [
      Habit(title: 'Exercices', value: '$_exercises', icon: Icons.fitness_center),
      Habit(title: 'Séries', value: '$_sets', icon: Icons.repeat),
      Habit(title: 'Répétitions', value: '$_reps', icon: Icons.format_list_numbered),
      Habit(title: 'Poids Total', value: '${_totalWeightLifted.toStringAsFixed(1)} kg', icon: Icons.fitness_center),
      Habit(title: 'Temps de Repos', value: '${_formatTime(_restTime)}', icon: Icons.timer),
      Habit(
          title: 'Temps Total',
          value: '${_formatTime(_secondsElapsed)}',
          icon: Icons.timer),
    ];
  }

  void _startActivity() {
    setState(() {
      if (!_isStarted || _isPaused) {
        _isStarted = true;
        _isPaused = false;
        _startTracking();
      } else {
        _isPaused = true;
        _stopTracking();
      }
    });
  }

  void _stopActivity() {
    if (_secondsElapsed > 0) {
      setState(() {
        _isStarted = false;
        _isPaused = false;
        _stopTracking();
        _showSummary();
        _resetActivity(); // Réinitialiser le compteur après affichage du résumé
      });
    }
  }

  void _resetActivity() {
    setState(() {
      _secondsElapsed = 0;
      _exercises = 0;
      _sets = 0;
      _reps = 0;
      _totalWeightLifted = 0.0;
      _restTime = 0;
      _initializeHabits();
    });
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  void _incrementExercises() {
    setState(() {
      _exercises++;
      habits[0] = Habit(title: 'Exercices', value: '$_exercises', icon: Icons.fitness_center);
    });
  }

  void _incrementSets() {
    setState(() {
      _sets++;
      habits[1] = Habit(title: 'Séries', value: '$_sets', icon: Icons.repeat);
    });
  }

  void _incrementReps() {
    setState(() {
      _reps++;
      habits[2] = Habit(title: 'Répétitions', value: '$_reps', icon: Icons.format_list_numbered);
    });
  }

  void _addWeightLifted(double weight) {
    setState(() {
      _totalWeightLifted += weight;
      habits[3] = Habit(title: 'Poids Total', value: '${_totalWeightLifted.toStringAsFixed(1)} kg', icon: Icons.fitness_center);
    });
  }

  void _incrementRestTime() {
    setState(() {
      _restTime += 30; // Ajouter 30 secondes de repos
      habits[4] = Habit(title: 'Temps de Repos', value: '${_formatTime(_restTime)}', icon: Icons.timer);
    });
  }

  void _showSummary() {
    _confettiController.play(); // Jouer les confettis

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Fond transparent
          insetPadding: EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Effet de flou
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7), // Fond semi-transparent
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé de la Séance',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 28,
                        color: Colors.black87, // Texte doux (gris foncé)
                        fontWeight: FontWeight.normal, // Pas de gras
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(Icons.fitness_center, 'Exercices', '$_exercises', Colors.blue),
                    _buildSummaryRow(Icons.repeat, 'Séries', '$_sets', Colors.green),
                    _buildSummaryRow(Icons.format_list_numbered, 'Répétitions', '$_reps', Colors.orange),
                    _buildSummaryRow(Icons.fitness_center, 'Poids Total', '${_totalWeightLifted.toStringAsFixed(1)} kg', Colors.purple),
                    _buildSummaryRow(Icons.timer, 'Temps de Repos', '${_formatTime(_restTime)}', Colors.teal),
                    _buildSummaryRow(Icons.timer, 'Temps Total', '${_formatTime(_secondsElapsed)}', Colors.pink),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Fonction pour construire la section supérieure
  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home_screen'),
          ),
          const SizedBox(width: 8),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String title, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28), // Icône colorée
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              color: Colors.black87, // Texte doux (gris foncé)
              fontWeight: FontWeight.normal, // Pas de gras
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              color: Colors.black87, // Texte doux (gris foncé)
              fontWeight: FontWeight.normal, // Pas de gras
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, y').format(DateTime.now());
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildTopSection(),
              _buildMainTitle(),
              _buildDateText(),
              _buildWeightTrainingIconSection(),
              _buildHabitsSection(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.blue,
                Colors.green,
                Colors.red,
                Colors.yellow
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _incrementExercises,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.fitness_center, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementSets,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.repeat, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementReps,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.format_list_numbered, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _addWeightLifted(10.0), // Ajouter 10 kg
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.add, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementRestTime,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.timer, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _startActivity,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(
              _isStarted && !_isPaused ? Icons.pause : Icons.play_arrow,
              size: 30,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _secondsElapsed > 0 ? _stopActivity : null, // Désactiver si le compteur est à 00:00
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.stop, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 8),
      child: Text(
        'Suivi de votre séance de musculation',
        style: GoogleFonts.bebasNeue(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Titre en noir
        ),
      ),
    );
  }

  Widget _buildDateText() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Text(
        _getFormattedDate(),
        style: GoogleFonts.bebasNeue(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildWeightTrainingIconSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            gradient: AppConstants.kPrimaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Icon(
              Icons.fitness_center,
              size: 150,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vos Statistiques',
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Titre en noir
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Listener(
              onPointerMove: (details) {
                if (details.delta.dx > 5 && currentPage > 0) {
                  _pageController.animateToPage(
                    currentPage - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else if (details.delta.dx < -5 &&
                    currentPage < habits.length - 1) {
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
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final double offset =
                      (index - currentPage) * 0.5; // Parallax effect
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: _buildBenefitCard(habits[index].title,
                        habits[index].value, habits[index].icon),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 300, // Ajustez cette valeur selon vos besoins
              child: SportyCounter(
                time: '${_formatTime(_secondsElapsed)}',
                fontSize: 96.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(String title, String value, IconData icon) {
    return GestureDetector(
      onTap: () {}, // Add an action if necessary
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: AppConstants.kCardMargin,
        width: 120,
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
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return AppConstants.kPrimaryGradient.createShader(bounds);
              },
              child: Icon(icon, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return AppConstants.kPrimaryGradient.createShader(bounds);
              },
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Compteur sportif
class SportyCounter extends StatelessWidget {
  final String time;
  final double fontSize;

  const SportyCounter({required this.time, this.fontSize = 48.0, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)], // Dégradé sportif
          begin: Alignment.center,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        time,
        style: GoogleFonts.bebasNeue(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}