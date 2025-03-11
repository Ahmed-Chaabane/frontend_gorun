import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DefineGoalScreen extends StatefulWidget {
  @override
  _DefineGoalScreenState createState() => _DefineGoalScreenState();
}

class _DefineGoalScreenState extends State<DefineGoalScreen> {
  String? selectedGoal; // Variable pour stocker l'objectif sélectionné
  DateTime? startDate; // Date de début sélectionnée
  DateTime? endDate; // Date de fin sélectionnée

  final List<Map<String, dynamic>> goalOptions = [
    {
      'name': 'Perte de poids',
      'icon': FontAwesomeIcons.dumbbell,
      'description': 'Atteindre un poids santé avec des exercices réguliers et une alimentation équilibrée.',
    },
    {
      'name': 'Amélioration de la force',
      'icon': FontAwesomeIcons.weight,
      'description': 'Renforcer les muscles et améliorer la condition physique générale.',
    },
    {
      'name': 'Préparation pour une course',
      'icon': FontAwesomeIcons.running,
      'description': 'Se préparer pour une course, qu\'elle soit courte ou longue distance.',
    },
    {
      'name': 'Flexibilité et mobilité',
      'icon': FontAwesomeIcons.spa,
      'description': 'Améliorer la flexibilité et prévenir les blessures.',
    },
    {
      'name': 'Bien-être général',
      'icon': FontAwesomeIcons.heartbeat,
      'description': 'Maintenir une activité physique régulière pour la santé globale.',
    },
    {
      'name': 'Amélioration de l\'endurance',
      'icon': FontAwesomeIcons.tachometerAlt,
      'description': 'Augmenter votre endurance pour des performances durables.',
    },
    {
      'name': 'Amélioration de la santé cardiovasculaire',
      'icon': FontAwesomeIcons.heart,
      'description': 'Renforcer le cœur et les poumons grâce à des exercices cardiovasculaires.',
    },
    {
      'name': 'Amélioration de la posture',
      'icon': FontAwesomeIcons.user,
      'description': 'Corriger la posture pour prévenir les douleurs dorsales.',
    },
    {
      'name': 'Réduction du stress',
      'icon': FontAwesomeIcons.om,
      'description': 'Pratiquer des exercices de relaxation pour réduire le stress.',
    },
    {
      'name': 'Amélioration de la concentration',
      'icon': FontAwesomeIcons.brain,
      'description': 'Améliorer la concentration et la clarté mentale.',
    },
    {
      'name': 'Amélioration de l\'équilibre',
      'icon': FontAwesomeIcons.balanceScale,
      'description': 'Travailler sur l\'équilibre pour améliorer la stabilité et la coordination.',
    },
  ];

  // Méthode pour construire le champ de sélection de date
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
            text: date != null ? date.toString().substring(0, 10) : ''),
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
  Widget _buildGoalCard(Map<String, dynamic> goalData, int index) {
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
        child: Container(
          width: double.infinity,
          height: 130,
          decoration: ShapeDecoration(
            color: isSelected ? Color(0xFFF5BA41) : Colors.white,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goalName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF808B9A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          description,
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Color(0xFF808B9A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
    );
  }

  // Méthode pour construire le bouton de confirmation
  Widget _buildActionButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          if (selectedGoal != null) {
            // Logique pour enregistrer l'objectif sélectionné
            print('Objectif sélectionné: $selectedGoal');
            // Vous pouvez sauvegarder cet objectif dans la base de données ou l'envoyer au backend

            // Naviguer vers l'écran suivant
            Navigator.pushNamed(context, '/next_screen');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Veuillez sélectionner un objectif')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70),
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
            for (int i = 0; i < goalOptions.length; i++)
              _buildGoalCard(goalOptions[i], i),
            const SizedBox(height: 24),
            _buildDatePicker(),
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
      'Quel est votre objectif ?',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

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

  // Méthode pour afficher le picker de date
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de début :',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        SizedBox(height: 8),
        _buildDateField(
          'Sélectionner la date de début',
          startDate,
              (pickedDate) {
            setState(() {
              startDate = pickedDate;
            });
          },
        ),
        SizedBox(height: 16),
        Text(
          'Date de fin :',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        SizedBox(height: 8),
        _buildDateField(
          'Sélectionner la date de fin',
          endDate,
              (pickedDate) {
            setState(() {
              endDate = pickedDate;
            });
          },
        ),
      ],
    );
  }
}

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