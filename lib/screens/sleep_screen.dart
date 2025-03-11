import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SleepGoalScreen extends StatefulWidget {
  @override
  _SleepGoalScreenState createState() => _SleepGoalScreenState();
}

class _SleepGoalScreenState extends State<SleepGoalScreen> {
  String? selectedGoal; // Variable pour stocker l'objectif sélectionné
  DateTime? startDate; // Date de début sélectionnée
  DateTime? endDate; // Date de fin sélectionnée

  final List<Map<String, dynamic>> sleepGoals = [
    {
      'name': 'Améliorer la qualité du sommeil',
      'icon': FontAwesomeIcons.moon,
      'description': 'Suivez votre sommeil et adoptez des habitudes pour mieux dormir.',
    },
    {
      'name': 'Réduire le temps d\'endormissement',
      'icon': FontAwesomeIcons.bed,
      'description': 'Apprenez des techniques pour vous endormir plus rapidement.',
    },
    {
      'name': 'Dormir plus longtemps',
      'icon': FontAwesomeIcons.clock,
      'description': 'Augmentez la durée de votre sommeil pour un repos optimal.',
    },
    {
      'name': 'Réduire les réveils nocturnes',
      'icon': FontAwesomeIcons.bellSlash,
      'description': 'Minimisez les interruptions pendant votre sommeil.',
    },
    {
      'name': 'Établir une routine de sommeil',
      'icon': FontAwesomeIcons.calendarCheck,
      'description': 'Créez une routine régulière pour améliorer votre sommeil.',
    },
    {
      'name': 'Réduire le stress avant le coucher',
      'icon': FontAwesomeIcons.spa,
      'description': 'Pratiquez des techniques de relaxation pour mieux dormir.',
    },
    {
      'name': 'Limiter la caféine avant le coucher',
      'icon': FontAwesomeIcons.coffee,
      'description': 'Évitez la caféine le soir pour un sommeil plus profond.',
    },
    {
      'name': 'Créer un environnement propice au sommeil',
      'icon': FontAwesomeIcons.lightbulb,
      'description': 'Optimisez votre chambre pour un sommeil réparateur.',
    },
    {
      'name': 'Suivre les cycles de sommeil',
      'icon': FontAwesomeIcons.chartLine,
      'description': 'Analysez vos cycles de sommeil pour mieux comprendre vos habitudes.',
    },
    {
      'name': 'Améliorer la respiration pendant le sommeil',
      'icon': FontAwesomeIcons.lungs,
      'description': 'Pratiquez des exercices de respiration pour un sommeil plus calme.',
    },
  ];
  final List<Map<String, dynamic>> communityChallenges = [
    {
      'name': 'Course de 5 km',
      'description': 'Participez à une course avec vos amis !',
      'icon': Icons.directions_run_rounded,
    },
    {
      'name': 'Hydratation',
      'description': 'Buvez 2L d\'eau par jour pendant une semaine.',
      'icon': Icons.local_drink,
    },
    {
      'name': 'Yoga Challenge',
      'description': 'Faites du yoga tous les jours pendant 7 jours.',
      'icon': Icons.self_improvement_rounded,
    },
    {
      'name': 'Cycling Challenge',
      'description': 'Parcourez 50 km à vélo en une semaine.',
      'icon': Icons.directions_bike_rounded,
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
            for (int i = 0; i < sleepGoals.length; i++)
              _buildGoalCard(sleepGoals[i], i),
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
      'Définissez votre plan de sommeil ?',
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