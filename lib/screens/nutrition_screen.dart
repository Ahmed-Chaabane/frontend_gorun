import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/gradient_icon_painter.dart'; // Assurez-vous que ce fichier existe

class NutritionScreen extends StatefulWidget {
  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // États de l'application
  String? selectedGoal;
  List<Map<String, dynamic>> nutritionGoals = [];
  Map<String, int> mealsConsumed = {};
  bool isLoading = false;
  Map<String, dynamic>? userNutritionProgress;
  bool isGoalAchieved = false;

  // Map pour associer les noms d'icônes aux icônes Flutter
  final Map<String, IconData> iconNameToIconData = {
    'apple': FontAwesomeIcons.apple,
    'cookie': FontAwesomeIcons.cookie,
    'fish': FontAwesomeIcons.fish,
    'glassWater': FontAwesomeIcons.glassWater,
    'seedling': FontAwesomeIcons.seedling,
    'utensils': FontAwesomeIcons.utensils,
    'bacon': FontAwesomeIcons.bacon,
    'kiwiBird': FontAwesomeIcons.kiwiBird,
    'mugHot': FontAwesomeIcons.mugHot,
    'pizzaSlice': FontAwesomeIcons.pizzaSlice,
    'hamburger': FontAwesomeIcons.hamburger,
    'carrot': FontAwesomeIcons.carrot,
    'breadSlice': FontAwesomeIcons.breadSlice,
    'egg': FontAwesomeIcons.egg,
    'cheese': FontAwesomeIcons.cheese,
    'drumstickBite': FontAwesomeIcons.drumstickBite,
  };

  @override
  void initState() {
    super.initState();
    fetchNutritionGoals(); // Charger les objectifs nutritionnels
    fetchUserNutritionProgress(); // Charger la progression de l'utilisateur
    _loadMealsConsumed(); // Charger les repas consommés
  }

  Future<void> incrementMealsConsumed(String goalName, int requiredMeals) async {
    setState(() {
      if (mealsConsumed[goalName] == null) {
        mealsConsumed[goalName] = 0; // Initialiser à 0 si null
      }
      if (mealsConsumed[goalName]! < requiredMeals) {
        mealsConsumed[goalName] = mealsConsumed[goalName]! + 1;
        saveMealsConsumed(goalName, mealsConsumed[goalName]!);
      }
      if (mealsConsumed[goalName]! >= requiredMeals) {
        _resetProgress(goalName); // Réinitialiser la progression
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Félicitations ! Vous avez atteint votre objectif.')),
        );
      }
    });
  }

  Future<void> decrementMealsConsumed(String goalName) async {
    setState(() {
      if (mealsConsumed[goalName] == null) {
        mealsConsumed[goalName] = 0; // Initialiser à 0 si null
      }
      if (mealsConsumed[goalName]! > 0) {
        mealsConsumed[goalName] = mealsConsumed[goalName]! - 1;
        saveMealsConsumed(goalName, mealsConsumed[goalName]!);
      }
    });
  }

  Future<void> _resetProgress(String goalName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalName, 0); // Réinitialiser à 0
    setState(() {
      mealsConsumed[goalName] = 0;
    });
  }

  Future<void> resetUserNutritionProgress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/utilisateurnutrition/firebase/${user.uid}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          userNutritionProgress = null; // Réinitialiser l'état de participation
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

  Future<void> fetchNutritionGoals() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/nutritiongoal'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          nutritionGoals = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'icon': iconNameToIconData[item['icon']] ?? FontAwesomeIcons.question,
              'description': item['description'],
              'required_meals': item['required_meals'] ?? 0,
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load nutrition goals');
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

  Future<void> fetchUserNutritionProgress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/utilisateurnutrition/firebase/${user.uid}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            userNutritionProgress = data[0]; // Store the current participation
          });
        } else {
          setState(() {
            userNutritionProgress = null; // No current participation
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de la progression : $e')),
      );
    }
  }

  Future<void> saveMealsConsumed(String goalName, int meals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalName, meals);
  }

  Future<void> _loadMealsConsumed() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mealsConsumed = {
        for (var goal in nutritionGoals)
          goal['name']: prefs.getInt(goal['name']) ?? 0
      };
    });
  }

  Future<void> joinGoalChallenge(String goalId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour rejoindre un objectif.')),
      );
      return;
    }
    if (userNutritionProgress != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous participez déjà à un programme nutritionnel.')),
      );
      return;
    }
    final String firebaseUid = user.uid;
    try {
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
      final Uri url = Uri.parse('http://localhost:3000/api/utilisateurnutrition');
      final body = json.encode({
        'id_utilisateur': userId,
        'id_nutrition_goal': goalIdInt,
        'firebase_uid': firebaseUid,
      });
      final postResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (postResponse.statusCode == 201) {
        setState(() {
          userNutritionProgress = {
            'id_nutrition_goal': goalIdInt,
            'id_utilisateur': userId,
          };
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous avez rejoint l\'objectif avec succès !')),
        );
      } else {
        final errorResponse = jsonDecode(postResponse.body);
        final errorMessage = errorResponse['message'] ?? 'Erreur inconnue';
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

  Future<void> deleteNutritionGoal(int goalId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/nutritiongoal/$goalId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          nutritionGoals.removeWhere((goal) => goal['id'] == goalId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Objectif supprimé avec succès.')),
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

  Widget _buildGoalCard(Map<String, dynamic> goalData, int index) {
    final String goalName = goalData['name'] ?? 'Objectif inconnu';
    final IconData icon = goalData['icon'] ?? Icons.help_outline;
    final String description = goalData['description'] ?? 'Aucune description disponible';
    final int requiredMeals = goalData['required_meals'] ?? 0;
    bool isGoalSelected = selectedGoal == goalName;
    bool isParticipating = userNutritionProgress != null &&
        userNutritionProgress!['id_nutrition_goal'] == goalData['id'];
    bool isGoalAchievedLocal = mealsConsumed[goalName] != null && mealsConsumed[goalName]! >= requiredMeals;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
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
                                'Repas requis : $requiredMeals',
                                style: TextStyle(
                                  color: isGoalSelected ? Colors.white : Color(0xFF808B9A),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Repas consommés : ${mealsConsumed[goalName] ?? 0}',
                                style: TextStyle(
                                  color: isGoalAchievedLocal ? Colors.green : (isGoalSelected ? Colors.white : Color(0xFF808B9A)),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: mealsConsumed[goalName] != null ? mealsConsumed[goalName]! / requiredMeals : 0.0,
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
                                      decrementMealsConsumed(goalName);
                                    }
                                        : null,
                                    icon: Icon(Icons.remove, color: isGoalSelected ? Colors.white : Color(0xFF0A1F4D)),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.restaurant,
                                    color: isGoalSelected ? Colors.white : Color(0xFF0A1F4D),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    onPressed: isParticipating
                                        ? () {
                                      incrementMealsConsumed(goalName, requiredMeals);
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
                : nutritionGoals.isEmpty
                ? Center(child: Text('Aucun objectif disponible.'))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: nutritionGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(nutritionGoals[index], index);
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
      'Définissez votre plan nutritionnel',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Définissez votre plan nutritionnel :',
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
        onPressed: selectedGoal == null || userNutritionProgress != null
            ? null
            : () {
          final selectedGoalData = nutritionGoals.firstWhere(
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
          backgroundColor: selectedGoal == null || userNutritionProgress != null
              ? Colors.grey
              : const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70),
        ),
        child: Text(
          userNutritionProgress != null
              ? 'Déjà participant à un objectif'
              : 'Rejoindre l\'objectif',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}