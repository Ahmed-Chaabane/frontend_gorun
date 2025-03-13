import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DefineGoalScreen extends StatefulWidget {
  @override
  _DefineGoalScreenState createState() => _DefineGoalScreenState();
}

class _DefineGoalScreenState extends State<DefineGoalScreen> {
  String? selectedGoal; // Variable pour stocker l'objectif sélectionné
  DateTime? startDate; // Date de début sélectionnée
  DateTime? endDate; // Date de fin sélectionnée
  List<Map<String, dynamic>> goalOptions = []; // Liste des objectifs récupérés depuis le backend
  bool isLoading = true; // Indicateur de chargement
  String? firebaseUid; // UID Firebase de l'utilisateur
  int? utilisateurId; // ID de l'utilisateur dans la base de données

  // Mapper les icônes
  final Map<String, IconData> iconNameToIconData = {
    'dumbbell': FontAwesomeIcons.dumbbell,
    'weight': FontAwesomeIcons.weight,
    'running': FontAwesomeIcons.running,
    'spa': FontAwesomeIcons.spa,
    'heartbeat': FontAwesomeIcons.heartbeat,
    'tachometer-alt': FontAwesomeIcons.tachometerAlt,
    'heart': FontAwesomeIcons.heart,
    'user': FontAwesomeIcons.user,
    'om': FontAwesomeIcons.om,
    'brain': FontAwesomeIcons.brain,
    'balance-scale': FontAwesomeIcons.balanceScale,
    'bed': FontAwesomeIcons.bed,
  };

  @override
  void initState() {
    super.initState();
    fetchGoals(); // Charger les objectifs au démarrage
    _fetchUserData(); // Récupérer les données de l'utilisateur
  }

  // Récupérer le firebase_uid et l'id_utilisateur
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

  // Récupérer les objectifs depuis le backend
  Future<void> fetchGoals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/objectifsportif'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          goalOptions = data.map((item) {
            // Mapper les noms d'icônes aux icônes correspondantes
            String iconName = item['icon'] ?? 'question'; // Utiliser 'question' comme valeur par défaut
            IconData icon = iconNameToIconData[iconName] ?? FontAwesomeIcons.question;

            return {
              'id_objectif_sportif': item['id_objectif_sportif'],
              'name': item['name'],
              'description': item['description'],
              'icon': icon,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erreur lors de la récupération des objectifs : ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des objectifs : $e')),
      );
    }
  }

  // Méthode pour construire le champ de date
  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return SizedBox(
      height: 60,
      child: TextField(
        readOnly: true, // Rendre le champ en lecture seule
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF39434F)),
          prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF0C1A37)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF0C1A37)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF4DD4DE)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        controller: TextEditingController(
          text: date != null ? date.toString().substring(0, 10) : '',
        ),
        onTap: () async {
          // Afficher le sélecteur de date
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2101),
          );
          if (picked != null && picked != date) {
            onDateSelected(picked); // Mettre à jour la date sélectionnée
          }
        },
      ),
    );
  }

  // Méthode pour construire la section des objectifs
  Widget _buildGoalCard(Map<String, dynamic> goalData) {
    final String goalName = goalData['name'];
    final IconData icon = goalData['icon'];
    final String description = goalData['description'];
    bool isSelected = selectedGoal == goalName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Sélectionner cet objectif et désélectionner les autres
            selectedGoal = isSelected ? null : goalName;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: isSelected ? 200 : 150, // Hauteur réduite pour un design compact
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFF5BA41) : Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                // Section de gauche : Détails de l'objectif
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Color(0xFF39434F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.black54 : Color(0xFF808B9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Section de droite : Icône
                Expanded(
                  flex: 1,
                  child: Center(
                    child: isSelected
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

  // Méthode pour construire le bouton de confirmation
  Widget _buildActionButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () async {
          if (selectedGoal == null || startDate == null || endDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Veuillez sélectionner un objectif et définir les dates.')),
            );
            return;
          }

          // Récupérer l'ID de l'objectif sélectionné
          final selectedGoalId = goalOptions.firstWhere(
                (goal) => goal['name'] == selectedGoal,
            orElse: () => <String, dynamic>{}, // Retourner un objet vide si non trouvé
          )['id_objectif_sportif'];

          if (selectedGoalId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Objectif sélectionné non trouvé.')),
            );
            return;
          }

          // Vérifier que firebaseUid et utilisateurId sont disponibles
          if (firebaseUid == null || utilisateurId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur : données utilisateur manquantes.')),
            );
            return;
          }

          // Préparer les données pour la requête POST
          final url = Uri.parse('http://localhost:3000/api/utilisateur-objectif');
          final body = json.encode({
            'id_objectif_sportif': selectedGoalId,
            'date_debut': startDate!.toIso8601String().split('T')[0],
            'date_fin': endDate!.toIso8601String().split('T')[0],
            'id_utilisateur': utilisateurId,
            'etat': 'en cours',
            'firebase_uid': firebaseUid,
          });

          try {
            final response = await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: body,
            );

            if (response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Objectif défini avec succès !')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur lors de la définition de l\'objectif.')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur réseau : $e')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 60),
        ),
        child: const Text(
          'Confirmer',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(),
            const SizedBox(height: 16),
            _buildSubtitle(),
            const SizedBox(height: 16),
            _buildDateField('Date de début', startDate, (DateTime newDate) {
              setState(() {
                startDate = newDate;
              });
            }),
            const SizedBox(height: 16),
            _buildDateField('Date de fin', endDate, (DateTime newDate) {
              setState(() {
                endDate = newDate;
              });
            }),
            const SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: goalOptions.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(goalOptions[index]);
              },
            ),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire le titre
  Widget _buildTitleSection() {
    return Text(
      'Quel est votre objectif ?',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Méthode pour construire le sous-titre
  Widget _buildSubtitle() {
    return Text(
      'Sélectionnez un objectif :',
      style: TextStyle(
        color: const Color(0xFF808B9A),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// Classe pour dessiner une icône avec un gradient
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