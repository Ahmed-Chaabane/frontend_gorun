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
class SwimmingTracker extends StatefulWidget {
  @override
  _SwimmingTrackerState createState() => _SwimmingTrackerState();
}

class _SwimmingTrackerState extends State<SwimmingTracker>
    with TickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final ConfettiController _confettiController = ConfettiController(
      duration: const Duration(seconds: 1)); // Pour les confettis

  LatLng _currentPosition = const LatLng(40.7128, -74.0060);
  bool _isLoading = true;
  bool _isStarted = false;
  bool _isPaused = false;
  List<LatLng> _polylinePoints = [];
  double _distance = 0.0;
  double _speed = 0.0; // Speed in km/h
  int _laps = 0;
  Timer? _timer;
  int _secondsElapsed = 0;

  late PageController _pageController;
  int currentPage = 0;

  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
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
      Habit(title: 'Distance', value: '-- km', icon: Icons.pool),
      Habit(title: 'Vitesse', value: '-- km/h', icon: Icons.speed),
      Habit(title: 'Longueurs', value: '$_laps', icon: Icons.repeat),
      Habit(
          title: 'Temps',
          value: '${_formatTime(_secondsElapsed)}',
          icon: Icons.timer),
    ];
  }

  Future<void> _initializeLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
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
      _distance = 0.0;
      _speed = 0.0;
      _laps = 0;
      _polylinePoints.clear();
      _initializeHabits();
    });
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
      _updateSpeed();
    });

    _locationService.getPositionStream().listen((Position position) async {
      setState(() {
        LatLng newPosition = LatLng(position.latitude, position.longitude);
        _polylinePoints.add(newPosition);
        _updateDistance();
        _currentPosition = newPosition;
      });
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateDistance() {
    if (_polylinePoints.length > 1) {
      double totalDistance = 0.0;
      for (int i = 1; i < _polylinePoints.length; i++) {
        totalDistance += Geolocator.distanceBetween(
          _polylinePoints[i - 1].latitude,
          _polylinePoints[i - 1].longitude,
          _polylinePoints[i].latitude,
          _polylinePoints[i].longitude,
        );
      }
      setState(() {
        _distance = totalDistance / 1000; // Convert to kilometers
        habits[0] = Habit(
            title: 'Distance',
            value: '${_distance.toStringAsFixed(2)} km',
            icon: Icons.pool);
      });
    }
  }

  void _updateSpeed() {
    if (_secondsElapsed > 0) {
      setState(() {
        _speed = _distance / (_secondsElapsed / 3600); // km/h
        habits[1] = Habit(
            title: 'Vitesse',
            value: '${_speed.toStringAsFixed(2)} km/h',
            icon: Icons.speed);
      });
    }
  }

  void _incrementLaps() async {
    setState(() {
      _laps++;
      habits[2] =
          Habit(title: 'Longueurs', value: '$_laps', icon: Icons.repeat);

      // Célébration tous les 10 longueurs
      if (_laps % 10 == 0) {
        _confettiController.play(); // Confettis
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Bravo ! Vous avez atteint $_laps longueurs ! 🎉')),
        );
      }
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
                    _buildSummaryRow(Icons.pool, 'Distance', '${_distance.toStringAsFixed(2)} km', Colors.blue),
                    _buildSummaryRow(Icons.speed, 'Vitesse Moyenne', '${_speed.toStringAsFixed(2)} km/h', Colors.green),
                    _buildSummaryRow(Icons.timer, 'Temps', '${_formatTime(_secondsElapsed)}', Colors.orange),
                    _buildSummaryRow(Icons.repeat, 'Longueurs', '$_laps', Colors.purple),
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
              _buildSwimmingIconSection(),
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
            onPressed: _incrementLaps,
            backgroundColor: Color(0xFF0C1A37),
            child: Icon(Icons.repeat, size: 30, color: Colors.white),
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
        'Suivi de votre séance de natation',
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

  Widget _buildSwimmingIconSection() {
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
              Icons.pool,
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