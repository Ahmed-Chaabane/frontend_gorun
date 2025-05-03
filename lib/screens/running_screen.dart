import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

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
class RunningTracker extends StatefulWidget {
  @override
  _RunningTrackerState createState() => _RunningTrackerState();
}

class _RunningTrackerState extends State<RunningTracker>
    with TickerProviderStateMixin {
  // Variables pour gérer l'état de l'activité
  bool _isStarted = false;
  bool _isPaused = false;
  final ConfettiController _confettiController = ConfettiController(
      duration: const Duration(seconds: 1)); // Pour les confettis
  int _sessions = 0;
  int _totalDuration = 0; // en secondes
  double _distance = 0.0; // en kilomètres
  int _caloriesBurned = 0;
  int _heartRate = 0; // Fréquence cardiaque en bpm
  Timer? _timer;
  int _secondsElapsed = 0;

  // Carte Google Maps
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng _currentPosition = const LatLng(0, 0);
  bool _isLoading = true;
  List<LatLng> _polylinePoints = [];
  late PageController _pageController;
  int currentPage = 0;
  List<Habit> habits = [];

  // Variables pour Firebase et utilisateur
  String? firebaseUid;
  int? utilisateurId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _initializeHabits(); // Initialisation des habitudes
    _initializeLocation(); // Initialisation de la position
    _fetchUserData(); // Récupérer les données utilisateur
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
      Habit(title: 'Sessions', value: '$_sessions', icon: Icons.directions_run),
      Habit(
          title: 'Distance',
          value: '${_distance.toStringAsFixed(2)} km',
          icon: Icons.map),
      Habit(
          title: 'Durée totale',
          value: '${_formatTime(_totalDuration)}',
          icon: Icons.timer),
      Habit(
          title: 'Calories',
          value: '$_caloriesBurned kcal',
          icon: Icons.local_fire_department),
      Habit(
          title: 'Heart Rate',
          value: '$_heartRate bpm',
          icon: Icons.favorite), // Nouvelle statistique
    ];
  }

  // Modifiez votre méthode _initializeLocation() comme suit :
  Future<void> _initializeLocation() async {
    try {
      _currentPosition = await LocationService().getCurrentLocation();
      setState(() => _isLoading = false);

      // Attendez que le contrôleur soit disponible
      final GoogleMapController controller = await _mapController.future;

      // Vérifiez que le widget est toujours monté
      if (!mounted) return;

      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de localisation: ${e.toString()}")),
      );
    }
  }


  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non connecté.')),
      );
      return;
    }

    setState(() {
      firebaseUid = user.uid; // Récupérer le firebase_uid
    });

    try {
      // Récupérer l'id_utilisateur depuis le backend
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/utilisateur/firebase_uid/$firebaseUid'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          utilisateurId = userData['id_utilisateur']; // Récupérer l'id_utilisateur
        });
      } else {
        throw Exception('Erreur lors de la récupération des données utilisateur');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des données utilisateur : $e')),
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
      // Vérifiez s'il y a des points avant de sauvegarder
      if (_polylinePoints.isNotEmpty) {
        _saveActivity();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun trajet GPS enregistré")),
        );
      }
      setState(() {
        _isStarted = false;
        _isPaused = false;
        _stopTracking();
        _showSummary();
        _resetActivity();
      });
    }
  }

  void _resetActivity() {
    setState(() {
      _secondsElapsed = 0;
      _sessions = 0;
      _totalDuration = 0;
      _distance = 0.0;
      _caloriesBurned = 0;
      _heartRate = 0;
      _polylinePoints.clear();
      _initializeHabits();
    });
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        _totalDuration++;
      });
    });
    _startHeartRateSimulation(); // Démarrer la simulation de la fréquence cardiaque
    LocationService().getPositionStream().listen((Position position) async {
      setState(() {
        LatLng newPosition = LatLng(position.latitude, position.longitude);
        _polylinePoints.add(newPosition);
        _updateDistance();
        _currentPosition = newPosition;
      });
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(_currentPosition));
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
        _distance = totalDistance / 1000; // Convertir en kilomètres
        habits[1] = Habit(
            title: 'Distance',
            value: '${_distance.toStringAsFixed(2)} km',
            icon: Icons.map);
      });
    }
  }

  void _startHeartRateSimulation() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _heartRate = 60 + (_secondsElapsed % 40); // Simulation aléatoire entre 60 et 100 bpm
        habits[4] = Habit(
            title: 'Heart Rate',
            value: '$_heartRate bpm',
            icon: Icons.favorite);
      });
    });
  }

  Future<void> _saveActivity() async {
    if (firebaseUid == null || utilisateurId == null) {
      print("Erreur : Données utilisateur manquantes");
      return;
    }

    if (_polylinePoints.isEmpty) {
      print("Aucun trajet enregistré");
      return;
    }

    final activityData = {
      "type_activite": "running",
      "date_activite": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "duree": _secondsElapsed ~/ 60, // en minutes
      "duree_secondes": _secondsElapsed,
      "distance": _distance, // Notez le nom du champ différent
      "calories_brulees": _caloriesBurned,
      "latitude_debut": _polylinePoints.first.latitude,
      "longitude_debut": _polylinePoints.first.longitude,
      "latitude_fin": _polylinePoints.last.latitude,
      "longitude_fin": _polylinePoints.last.longitude,
      "id_utilisateur": utilisateurId,
      "id_objectif_sportif": 2, // À adapter ou rendre dynamique
      "details_raw": "Session running via l'application mobile",
      "date_heure": DateTime.now().toUtc().toIso8601String(),
      "i_client": utilisateurId.toString(),
      "firebase_uid": firebaseUid!,
    };

    print("Envoi des données: ${jsonEncode(activityData)}");

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/activitesportive'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(activityData),
      );

      if (response.statusCode == 201) {
        print("Activité sauvegardée avec succès!");
      } else {
        print("Erreur du serveur: ${response.body}");
        throw Exception('Échec de la sauvegarde: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur réseau: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de sauvegarde: ${e.toString()}")),
      );
    }
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
                    _buildSummaryRow(Icons.directions_run, 'Sessions',
                        '$_sessions', Colors.purple),
                    _buildSummaryRow(Icons.map, 'Distance',
                        '${_distance.toStringAsFixed(2)} km', Colors.yellow),
                    _buildSummaryRow(Icons.timer, 'Durée totale',
                        '${_formatTime(_totalDuration)}', Colors.green),
                    _buildSummaryRow(Icons.local_fire_department, 'Calories',
                        '$_caloriesBurned kcal', Colors.blue),
                    _buildSummaryRow(Icons.favorite, 'Heart Rate',
                        '$_heartRate bpm', Colors.red), // Nouvelle ligne
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
      IconData icon, String title, String value, Color iconColor) {
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
              _buildMapSection(), // Carte Google Maps
              _buildHabitsSection(), // Cartes des statistiques
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
            heroTag: 'uniqueTagForFAZAQB',
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
            heroTag: 'uniqueTagForBEBEBE',
            onPressed:
            _secondsElapsed > 0 ? _stopActivity : null, // Désactiver si le compteur est à 00:00
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
        'Suivi de votre séance de running',
        style: GoogleFonts.bebasNeue(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black, // Titre en noir
        ),
      ),
    );
  }

  // Fonction pour construire la section supérieure
  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(0xFF808B9A), size: 24),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/home_screen'),
          ),
          const SizedBox(width: 8),
          const Spacer(),
        ],
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

  // Et dans votre build(), ajoutez une vérification :
  Widget _buildMapSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 400,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                position: _currentPosition,
                infoWindow: const InfoWindow(title: "You are here"),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: _polylinePoints,
                color: Colors.blue,
                width: 5,
              ),
            },
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            myLocationEnabled: true,
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
                  final double offset = (index - currentPage) * 0.5; // Parallax effect
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: _buildBenefitCard(
                        habits[index].title,
                        habits[index].value,
                        habits[index].icon),
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
      onTap: () {}, // Ajoutez une action si nécessaire
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
                  color: Colors.white,
                ),
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