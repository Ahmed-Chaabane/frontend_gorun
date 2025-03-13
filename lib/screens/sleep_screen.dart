import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/gradient_icon_painter.dart';

class SleepGoalScreen extends StatefulWidget {
  @override
  _SleepGoalScreenState createState() => _SleepGoalScreenState();
}

class _SleepGoalScreenState extends State<SleepGoalScreen> {
  // États de l'application
  String? selectedGoal;
  List<Map<String, dynamic>> sleepGoals = [];
  Map<String, int> hoursSlept = {};
  bool isLoading = false;
  Map<String, dynamic>? userSleepProgress;

  // Map pour associer les noms d'icônes aux icônes Flutter
  final Map<String, IconData> iconNameToIconData = {
    'moon_icon': FontAwesomeIcons.moon,
    'clock_icon': FontAwesomeIcons.clock,
    'bed_icon': FontAwesomeIcons.bed,
    'bell_slash_icon': FontAwesomeIcons.bellSlash,
    'calendar_check_icon': FontAwesomeIcons.calendarCheck,
    'coffee_icon': FontAwesomeIcons.coffee,
  };

  @override
  void initState() {
    super.initState();
    fetchSleepGoals(); // Charger les objectifs de sommeil
    fetchUserSleepProgress(); // Charger la progression de l'utilisateur
    _loadHoursSlept(); // Charger les heures de sommeil consommées
  }

  Future<void> incrementHoursSlept(String goalName, int requiredHours) async {
    setState(() {
      if (hoursSlept[goalName] == null) {
        hoursSlept[goalName] = 0; // Initialiser à 0 si null
      }
      if (hoursSlept[goalName]! < requiredHours) {
        hoursSlept[goalName] = hoursSlept[goalName]! + 1;
        saveHoursSlept(goalName, hoursSlept[goalName]!);
      }
      if (hoursSlept[goalName]! >= requiredHours) {
        _resetProgress(goalName); // Réinitialiser la progression
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Félicitations ! Vous avez atteint votre objectif.')),
        );
      }
    });
  }

  Future<void> decrementHoursSlept(String goalName) async {
    setState(() {
      if (hoursSlept[goalName] == null) {
        hoursSlept[goalName] = 0; // Initialiser à 0 si null
      }
      if (hoursSlept[goalName]! > 0) {
        hoursSlept[goalName] = hoursSlept[goalName]! - 1;
        saveHoursSlept(goalName, hoursSlept[goalName]!);
      }
    });
  }

  Future<void> _resetProgress(String goalName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalName, 0); // Réinitialiser à 0
    setState(() {
      hoursSlept[goalName] = 0;
    });
  }

  Future<void> fetchSleepGoals() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/sleepgoals'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          sleepGoals = data.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'icon': iconNameToIconData[item['icon']] ?? FontAwesomeIcons.question,
              'description': item['description'],
              'required_hours': item['required_hours'] ?? 0,
              'quality_goal': item['quality_goal'],
              'sport_type': item['sport_type'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load sleep goals');
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

  Future<void> fetchUserSleepProgress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/utilisateursleep/firebase/${user.uid}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            userSleepProgress = data[0]; // Store the current participation
          });
        } else {
          setState(() {
            userSleepProgress = null; // No current participation
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement de la progression : $e')),
      );
    }
  }

  Future<void> saveHoursSlept(String goalName, int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalName, hours);
  }

  Future<void> _loadHoursSlept() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hoursSlept = {
        for (var goal in sleepGoals)
          goal['name']: prefs.getInt(goal['name']) ?? 0
      };
    });
  }

  Widget _buildGoalCard(Map<String, dynamic> goalData, int index) {
    final String goalName = goalData['name'] ?? 'Objectif inconnu';
    final IconData icon = goalData['icon'] ?? Icons.help_outline;
    final String description = goalData['description'] ?? 'Aucune description disponible';
    final int requiredHours = goalData['required_hours'] ?? 0;

    bool isGoalSelected = selectedGoal == goalName;
    bool isParticipating = userSleepProgress != null &&
        userSleepProgress!['id_sleep_goal'] == goalData['id'];
    bool isGoalAchievedLocal = hoursSlept[goalName] != null && hoursSlept[goalName]! >= requiredHours;

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
                                'Heures requises : $requiredHours',
                                style: TextStyle(
                                  color: isGoalSelected ? Colors.white : Color(0xFF808B9A),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Heures dormies : ${hoursSlept[goalName] ?? 0}',
                                style: TextStyle(
                                  color: isGoalAchievedLocal ? Colors.green : (isGoalSelected ? Colors.white : Color(0xFF808B9A)),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: hoursSlept[goalName] != null ? hoursSlept[goalName]! / requiredHours : 0.0,
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
                                      decrementHoursSlept(goalName);
                                    }
                                        : null,
                                    icon: Icon(Icons.remove, color: isGoalSelected ? Colors.white : Color(0xFF0A1F4D)),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.bedtime,
                                    color: isGoalSelected ? Colors.white : Color(0xFF0A1F4D),
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    onPressed: isParticipating
                                        ? () {
                                      incrementHoursSlept(goalName, requiredHours);
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
                : sleepGoals.isEmpty
                ? Center(child: Text('Aucun objectif disponible.'))
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sleepGoals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(sleepGoals[index], index);
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
      'Définissez votre plan de sommeil',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Définissez votre plan de sommeil :',
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
        onPressed: selectedGoal == null || userSleepProgress != null
            ? null
            : () {
          final selectedGoalData = sleepGoals.firstWhere(
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
          backgroundColor: selectedGoal == null || userSleepProgress != null
              ? Colors.grey
              : const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70),
        ),
        child: Text(
          userSleepProgress != null
              ? 'Déjà participant à un objectif'
              : 'Rejoindre l\'objectif',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Future<void> joinGoalChallenge(String goalId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour rejoindre un objectif.')),
      );
      return;
    }
    if (userSleepProgress != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous participez déjà à un programme de sommeil.')),
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
      final Uri url = Uri.parse('http://localhost:3000/api/utilisateursleep');
      final body = json.encode({
        'id_utilisateur': userId,
        'id_sleep_goal': goalIdInt,
        'firebase_uid': firebaseUid,
      });
      final postResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (postResponse.statusCode == 201) {
        setState(() {
          userSleepProgress = {
            'id_sleep_goal': goalIdInt,
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
}