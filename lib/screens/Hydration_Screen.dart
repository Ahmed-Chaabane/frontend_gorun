import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/gradient_icon_painter.dart';

class HydrationScreen extends StatefulWidget {
  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  // États de l'application
  String? selectedGoal;
  List<Map<String, dynamic>> hydrationGoals = [];
  Map<String, int> glassesConsumed = {};
  bool isLoading = false;
  Map<String, dynamic>? userHydrationProgress;
  bool isGoalAchieved = false;
  bool isSelected = false;

  // Map pour associer les noms d'icônes aux icônes Flutter
  final Map<String, IconData> iconNameToIconData = {
    'glassWater': FontAwesomeIcons.glassWater,
    'clock': FontAwesomeIcons.clock,
    'bottleDroplet': FontAwesomeIcons.bottleDroplet,
    'dumbbell': FontAwesomeIcons.dumbbell,
    'chartLine': FontAwesomeIcons.chartLine,
    'sun': FontAwesomeIcons.sun,
    'tintSlash': FontAwesomeIcons.dropletSlash,
    'recycle': FontAwesomeIcons.recycle,
    'utensils': FontAwesomeIcons.utensils,
    'moon': FontAwesomeIcons.moon,
    'medal': FontAwesomeIcons.medal,
    'sunHeat': FontAwesomeIcons.sun,
    'trophy': FontAwesomeIcons.trophy,
    'spa': FontAwesomeIcons.spa,
  };

  @override
  void initState() {
    super.initState();
    fetchHydrationGoals(); // Charger les objectifs d'hydratation
    fetchUserHydrationProgress(); // Charger la progression de l'utilisateur
    _loadGlassesConsumed(); // Charger les verres consommés

    // Vérifier si l'utilisateur a atteint l'objectif
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkIfGoalAchieved();
    });
  }

  Future<void> _checkIfGoalAchieved() async {
    for (var goal in hydrationGoals) {
      final String goalName = goal['name'];
      final int requiredGlasses = goal['required_glasses'] ?? 0;

      if (glassesConsumed[goalName] != null &&
          glassesConsumed[goalName]! >= requiredGlasses) {
        setState(() {
          userHydrationProgress =
              null; // Réinitialiser la participation de l'utilisateur
        });
        break;
      }
    }
  }

  Future<void> incrementGlassesConsumed(String goalName, int requiredGlasses) async {
    setState(() {
      // Vérifier si glassesConsumed[goalName] est null
      if (glassesConsumed[goalName] == null) {
        glassesConsumed[goalName] = 0; // Initialiser à 0 si null
      }

      if (glassesConsumed[goalName]! < requiredGlasses) {
        glassesConsumed[goalName] = glassesConsumed[goalName]! + 1;
        saveGlassesConsumed(goalName, glassesConsumed[goalName]!);
      }

      // Vérifier si l'objectif est atteint
      if (glassesConsumed[goalName]! >= requiredGlasses) {
        _resetProgress(goalName); // Réinitialiser la progression
        deactivateUserHydrationProgress(); // Désactiver l'objectif dans le backend
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Félicitations ! Vous avez atteint votre objectif.')),
        );
      }
    });
  }

  Future<void> decrementGlassesConsumed(String goalName) async {
    setState(() {
      // Vérifier si glassesConsumed[goalName] est null
      if (glassesConsumed[goalName] == null) {
        glassesConsumed[goalName] = 0; // Initialiser à 0 si null
      }

      if (glassesConsumed[goalName]! > 0) {
        glassesConsumed[goalName] = glassesConsumed[goalName]! - 1;
        saveGlassesConsumed(goalName, glassesConsumed[goalName]!);
      }
    });
  }

// Réinitialiser la progression pour un objectif donné
  Future<void> _resetProgress(String goalName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalName, 0); // Réinitialiser à 0
    setState(() {
      glassesConsumed[goalName] = 0;
    });
  }
  // reset User Hydration Progress
  Future<void> resetUserHydrationProgress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/utilisateurhydration/firebase/${user.uid}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userHydrationProgress = null; // Réinitialiser l'état de participation
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous avez quitté l\'objectif avec succès.')),
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de l\'objectif : $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
    }
  }

  // Récupérer les objectifs d'hydratation depuis l'API
  Future<void> fetchHydrationGoals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/hydrationgoal'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          hydrationGoals = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'icon': iconNameToIconData[item['icon']] ?? FontAwesomeIcons.question,
              'description': item['description'],
              'required_glasses': item['required_glasses'] ?? 0,
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load hydration goals');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des objectifs : $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Récupérer la progression de l'utilisateur depuis l'API
  Future<void> fetchUserHydrationProgress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/utilisateurhydration/firebase/${user.uid}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Check if the user is already participating in a goal
        if (data.isNotEmpty) {
          setState(() {
            userHydrationProgress = data[0]; // Store the current participation
          });
        } else {
          setState(() {
            userHydrationProgress = null; // No current participation
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de la progression : $e')),
      );
    }
  }

  // Sauvegarder les verres consommés localement
  Future<void> saveGlassesConsumed(String goalName, int glasses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalName, glasses);
  }

  // Charger les verres consommés depuis le stockage local
  Future<void> _loadGlassesConsumed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      glassesConsumed = {
        for (var goal in hydrationGoals)
          goal['name']: prefs.getInt(goal['name']) ?? 0
      };
    });
  }

  // Rejoindre un objectif d'hydratation
  Future<void> joinGoalChallenge(String goalId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour rejoindre un objectif.')),
      );
      return;
    }

    // Vérifier si l'utilisateur a un objectif actif
    final activeGoalResponse = await http.get(
      Uri.parse(
          'http://localhost:3000/api/utilisateurhydration/firebase/${user.uid}/active'),
    );

    if (activeGoalResponse.statusCode == 200) {
      final activeGoal = jsonDecode(activeGoalResponse.body);
      if (activeGoal != null && activeGoal['is_active'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Vous participez déjà à un programme d\'hydratation.')),
        );
        return;
      }
    }

    final String firebaseUid = user.uid;

    try {
      // Récupérer l'ID de l'utilisateur depuis l'API
      final userResponse = await http.get(
        Uri.parse('http://localhost:3000/api/utilisateur/firebase_uid/$firebaseUid'),
      );

      if (userResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la récupération des informations utilisateur.')),
        );
        return;
      }

      final Map<String, dynamic> userData = jsonDecode(userResponse.body);
      final int userId = userData['id_utilisateur'] as int;
      final int goalIdInt = int.tryParse(goalId) ?? -1;

      if (goalIdInt == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID de l\'objectif invalide.')),
        );
        return;
      }

      // Préparer les données pour la requête POST
      final Uri url = Uri.parse('http://localhost:3000/api/utilisateurhydration');
      final body = json.encode({
        'id_utilisateur': userId,
        'id_hydration_goal': goalIdInt,
        'firebase_uid': firebaseUid,
        'is_active': true, // Marquer l'objectif comme actif
      });

      print('Données envoyées : $body'); // Afficher les données envoyées

      // Envoyer la requête POST
      final postResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print(
          'Réponse de l\'API : ${postResponse.body}'); // Afficher la réponse de l'API

      if (postResponse.statusCode == 201) {
        setState(() {
          userHydrationProgress = {
            'id_hydration_goal': goalIdInt,
            'id_utilisateur': userId,
          };
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous avez rejoint l\'objectif avec succès !')),
        );
      } else {
        final errorResponse = jsonDecode(postResponse.body);
        final errorMessage = errorResponse['error'] ?? 'Erreur inconnue';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la participation à l\'objectif : $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
    }
  }

  Future<void> deactivateUserHydrationProgress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final response = await http.patch(
        Uri.parse(
            'http://localhost:3000/api/utilisateurhydration/firebase/${user.uid}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_active': false}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userHydrationProgress = null; // Réinitialiser l'état de participation
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Objectif désactivé avec succès.')),
        );
      } else {
        final errorMessage =
            jsonDecode(response.body)['error'] ?? 'Erreur inconnue';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur lors de la désactivation de l\'objectif : $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
    }
  }

  // Construire une carte d'objectif
  Widget _buildGoalCard(Map<String, dynamic> goalData, int index) {
    final String goalName = goalData['name'] ?? 'Objectif inconnu';
    final IconData icon = goalData['icon'] ?? Icons.help_outline; // Icône par défaut si null
    final String description = goalData['description'] ?? 'Aucune description disponible';
    final int requiredGlasses = goalData['required_glasses'] ?? 0;

    // Vérifier si cet objectif est sélectionné
    bool isGoalSelected = selectedGoal == goalName;

    bool isParticipating = userHydrationProgress != null &&
        userHydrationProgress!['id_hydration_goal'] == goalData['id'];

    bool isGoalAchievedLocal = glassesConsumed[goalName] != null && glassesConsumed[goalName]! >= requiredGlasses;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Mettre à jour l'objectif sélectionné
            selectedGoal = isGoalSelected ? null : goalName;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: isGoalSelected ? 230 : 130,
          decoration: BoxDecoration(
            color: isGoalSelected ? Color(0xFFF5BA41) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isParticipating
                ? Border.all(color: Colors.blue, width: 2)
                : isGoalAchievedLocal
                ? Border.all(color: Colors.green, width: 2)
                : null,
            boxShadow: [
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
          child: SingleChildScrollView(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goalName,
                          style: TextStyle(
                            color: isGoalSelected ? Colors.white : Color(0xFF808B9A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            description,
                            style: TextStyle(
                              color: isGoalSelected ? Colors.white70 : Color(0xFF808B9A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isGoalSelected)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Verres requis : $requiredGlasses',
                                style: TextStyle(
                                  color: isGoalSelected ? Colors.white : Color(0xFF808B9A),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Verres consommés : ${glassesConsumed[goalName] ?? 0}',
                                style: TextStyle(
                                  color: isGoalAchievedLocal ? Colors.green : (isGoalSelected ? Colors.white : Color(0xFF808B9A)),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: glassesConsumed[goalName] != null ? glassesConsumed[goalName]! / requiredGlasses : 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    isGoalSelected ? Colors.white : Color(0xFF4DD4DE)),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: isParticipating
                                        ? () {
                                      decrementGlassesConsumed(goalName);
                                    }
                                        : null,
                                    icon: Icon(Icons.remove, color: isGoalSelected ? Colors.white : Color(0xFF0A1F4D)),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.local_drink,
                                    color: isGoalSelected ? Colors.white : Color(0xFF0A1F4D),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    onPressed: isParticipating
                                        ? () {
                                      incrementGlassesConsumed(goalName, requiredGlasses);
                                    }
                                        : null,
                                    icon: Icon(Icons.add, color: isGoalSelected ? Colors.white : Color(0xFF0A1F4D)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: isGoalSelected
                        ? Icon(
                      icon,
                      size: 70,
                      color: Colors.white,
                    )
                        : CustomPaint(
                      size: Size(70, 70),
                      painter: GradientIconPainter(
                        icon: icon,
                        size: 70,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 40),
            _buildTitleSection(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            const SizedBox(height: 24),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : hydrationGoals.isEmpty
                ? Center(child: Text('Aucun objectif disponible.'))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: hydrationGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(hydrationGoals[index], index);
              },
            ),
            const SizedBox(height: 24),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTitleSection() {
    return Text(
      'Définissez votre plan d\'hydratation',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Définissez votre plan d\'hydratation :',
      style: TextStyle(
        color: const Color(0xFF808B9A),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: selectedGoal == null || userHydrationProgress != null
            ? null // Désactiver le bouton si aucun objectif n'est sélectionné ou si l'utilisateur participe déjà
            : () {
          final selectedGoalData = hydrationGoals.firstWhere(
                (goal) => goal['name'] == selectedGoal,
            orElse: () {
              return {};
            },
          );

          if (selectedGoalData.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aucun objectif sélectionné trouvé.')),
            );
            return;
          }

          final dynamic goalIdDynamic = selectedGoalData['id'];
          if (goalIdDynamic == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ID de l\'objectif non trouvé.')),
            );
            return;
          }

          final String goalId = goalIdDynamic.toString();
          joinGoalChallenge(goalId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedGoal == null || userHydrationProgress != null
              ? Colors.grey // Changer la couleur du bouton si désactivé
              : const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70),
        ),
        child: Text(
          userHydrationProgress != null
              ? 'Déjà participant à un objectif'
              : 'Rejoindre l\'objectif',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}