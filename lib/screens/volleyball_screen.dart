import 'dart:async';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

// Location Service
class LocationService {
  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream();
  }
}

// Main Widget
class VolleyballTracker extends StatefulWidget {
  @override
  _VolleyballTrackerState createState() => _VolleyballTrackerState();
}

class _VolleyballTrackerState extends State<VolleyballTracker>
    with TickerProviderStateMixin {
  // Variables pour gérer l'état de l'activité
  bool _isStarted = false;
  bool _isPaused = false;

  final ConfettiController _confettiController = ConfettiController(
      duration: const Duration(seconds: 1)); // Pour les confettis

  int _points = 0;
  int _aces = 0;
  int _blocks = 0;
  int _digs = 0;
  int _kills = 0;
  int _errors = 0;
  int _serviceErrors = 0;
  int _totalServes = 0;
  int _successfulServes = 0;
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
      Habit(title: 'Points', value: '$_points', icon: Icons.emoji_events),
      Habit(title: 'Aces', value: '$_aces', icon: Icons.star),
      Habit(title: 'Blocks', value: '$_blocks', icon: Icons.block),
      Habit(title: 'Digs', value: '$_digs', icon: Icons.security),
      Habit(title: 'Kills', value: '$_kills', icon: Icons.bolt),
      Habit(title: 'Erreurs', value: '$_errors', icon: Icons.error),
      Habit(title: 'Erreurs de service', value: '$_serviceErrors', icon: Icons.warning),
      Habit(
          title: 'Services',
          value: '$_successfulServes/$_totalServes',
          icon: Icons.flag),
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
      _points = 0;
      _aces = 0;
      _blocks = 0;
      _digs = 0;
      _kills = 0;
      _errors = 0;
      _serviceErrors = 0;
      _totalServes = 0;
      _successfulServes = 0;
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

  void _incrementPoints() {
    setState(() {
      _points++;
      habits[0] = Habit(title: 'Points', value: '$_points', icon: Icons.emoji_events);
      _confettiController.play(); // Confettis pour chaque point
    });
  }

  void _incrementAces() {
    setState(() {
      _aces++;
      habits[1] = Habit(title: 'Aces', value: '$_aces', icon: Icons.star);
    });
  }

  void _incrementBlocks() {
    setState(() {
      _blocks++;
      habits[2] = Habit(title: 'Blocks', value: '$_blocks', icon: Icons.block);
    });
  }

  void _incrementDigs() {
    setState(() {
      _digs++;
      habits[3] = Habit(title: 'Digs', value: '$_digs', icon: Icons.security);
    });
  }

  void _incrementKills() {
    setState(() {
      _kills++;
      habits[4] = Habit(title: 'Kills', value: '$_kills', icon: Icons.bolt);
    });
  }

  void _incrementErrors() {
    setState(() {
      _errors++;
      habits[5] = Habit(title: 'Erreurs', value: '$_errors', icon: Icons.error);
    });
  }

  void _incrementServiceErrors() {
    setState(() {
      _serviceErrors++;
      habits[6] = Habit(title: 'Erreurs de service', value: '$_serviceErrors', icon: Icons.warning);
    });
  }

  void _incrementServe(bool success) {
    setState(() {
      _totalServes++;
      if (success) _successfulServes++;
      habits[7] = Habit(
          title: 'Services',
          value: '$_successfulServes/$_totalServes',
          icon: Icons.flag);
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
                      'Résumé du Match',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 28,
                        color: Colors.black87, // Texte doux (gris foncé)
                        fontWeight: FontWeight.normal, // Pas de gras
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(Icons.emoji_events, 'Points', '$_points', Colors.purple),
                    _buildSummaryRow(Icons.star, 'Aces', '$_aces', Colors.yellow),
                    _buildSummaryRow(Icons.block, 'Blocks', '$_blocks', Colors.green),
                    _buildSummaryRow(Icons.security, 'Digs', '$_digs', Colors.blue),
                    _buildSummaryRow(Icons.bolt, 'Kills', '$_kills', Colors.teal),
                    _buildSummaryRow(Icons.error, 'Erreurs', '$_errors', Colors.red),
                    _buildSummaryRow(Icons.warning, 'Erreurs de service', '$_serviceErrors', Colors.orange),
                    _buildSummaryRow(Icons.flag, 'Services', '$_successfulServes/$_totalServes', Colors.pink),
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
              _buildVolleyballIconSection(),
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
            onPressed: _incrementPoints,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.emoji_events, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementAces,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.star, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementBlocks,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.block, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementDigs,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.security, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementKills,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.bolt, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementErrors,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.error, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementServiceErrors,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.warning, size: 30, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _incrementServe(true),
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.flag, size: 30, color: Colors.white),
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
        'Suivi de votre match de volleyball',
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

  Widget _buildVolleyballIconSection() {
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
              Icons.sports_volleyball,
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