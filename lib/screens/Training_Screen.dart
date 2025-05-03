import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/gradient_icon_painter.dart';

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String? selectedActivity;

  final Map<String, Map<String, dynamic>> _activities = {
    'Running': {
      'icon': FontAwesomeIcons.running,
      'description': 'Cardio exercise that improves endurance',
      'route': '/running_screen',
      'calories': '500-800 kcal/h',
      'duration': '30-60 min',
      'intensity': 'High',
    },
    'Cycling': {
      'icon': FontAwesomeIcons.bicycle,
      'description': 'Low-impact exercise for leg strength',
      'route': '/cycling_screen',
      'calories': '400-700 kcal/h',
      'duration': '45-90 min',
      'intensity': 'Medium',
    },
    'Yoga': {
      'icon': FontAwesomeIcons.spa,
      'description': 'Improves flexibility and mental focus',
      'route': '/yoga_screen',
      'calories': '200-400 kcal/h',
      'duration': '30-60 min',
      'intensity': 'Low',
    },
    'Swimming': {
      'icon': FontAwesomeIcons.swimmer,
      'description': 'Full-body workout with low joint impact',
      'route': '/swimming_screen',
      'calories': '500-700 kcal/h',
      'duration': '30-45 min',
      'intensity': 'High',
    },
    'Football': {
      'icon': FontAwesomeIcons.futbol,
      'description': 'Team sport that improves coordination',
      'route': '/football_screen',
      'calories': '600-900 kcal/h',
      'duration': '60-90 min',
      'intensity': 'High',
    },
    'Tennis': {
      'icon': FontAwesomeIcons.tableTennis,
      'description': 'Improves reflexes and agility',
      'route': '/tennis_screen',
      'calories': '400-600 kcal/h',
      'duration': '45-60 min',
      'intensity': 'Medium',
    },
    'Basketball': {
      'icon': FontAwesomeIcons.basketballBall,
      'description': 'High-intensity team sport',
      'route': '/basketball_screen',
      'calories': '500-800 kcal/h',
      'duration': '60-90 min',
      'intensity': 'High',
    },
    'Volleyball': {
      'icon': FontAwesomeIcons.volleyballBall,
      'description': 'Improves teamwork and reflexes',
      'route': '/volleyball_screen',
      'calories': '400-600 kcal/h',
      'duration': '60-90 min',
      'intensity': 'Medium',
    },
    'Weight Training': {
      'icon': FontAwesomeIcons.dumbbell,
      'description': 'Builds muscle strength and mass',
      'route': '/weighttraining_screen',
      'calories': '300-500 kcal/h',
      'duration': '45-60 min',
      'intensity': 'Medium',
    },
    'Hiking': {
      'icon': FontAwesomeIcons.hiking,
      'description': 'Nature walk that improves endurance',
      'route': '/hiking_screen',
      'calories': '350-550 kcal/h',
      'duration': '60-120 min',
      'intensity': 'Medium',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(context),
              const SizedBox(height: 20),
              _buildTitleSection(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 24),
              ..._buildActivityCards(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activityData, bool isExpanded) {
    final String activityName = activityData['name'] ?? 'Unknown Activity';
    final IconData icon = activityData['icon'] ?? Icons.help_outline;
    final String description = activityData['description'] ?? 'No description available';
    final String route = activityData['route'] ?? '/';
    final String calories = activityData['calories'] ?? 'N/A';
    final String duration = activityData['duration'] ?? 'N/A';
    final String intensity = activityData['intensity'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedActivity = isExpanded ? null : activityName;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: isExpanded ? 240 : 130,
          decoration: BoxDecoration(
            color: isExpanded ? const Color(0xFFF5BA41) : Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activityName.toUpperCase(),
                              style: TextStyle(
                                color: isExpanded ? Colors.white : const Color(0xFF808B9A),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                color: isExpanded ? Colors.white70 : const Color(0xFF808B9A),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        if (isExpanded) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.local_fire_department, 'Calories: $calories', isExpanded),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.timer, 'Duration: $duration', isExpanded),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.speed, 'Intensity: $intensity', isExpanded),
                          const SizedBox(height: 16),

                          // Bouton Start amélioré
                          Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.pushNamed(context, route);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_arrow_rounded,
                                        size: 22,
                                        color: const Color(0xFF162A5A),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'START',
                                        style: TextStyle(
                                          color: const Color(0xFF162A5A),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: isExpanded
                        ? Icon(
                      icon,
                      size: 64,
                      color: Colors.white,
                    )
                        : CustomPaint(
                      size: const Size(70, 70),
                      painter: GradientIconPainter(
                        icon: icon,
                        size: 70,
                        gradient: const LinearGradient(
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

  Widget _buildDetailRow(IconData icon, String text, bool isExpanded) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isExpanded ? Colors.white : const Color(0xFF808B9A),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isExpanded ? Colors.white : const Color(0xFF808B9A),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActivityCards() {
    return _activities.entries.map((entry) {
      return _buildActivityCard(
        {
          'name': entry.key,
          'icon': entry.value['icon'],
          'description': entry.value['description'],
          'route': entry.value['route'],
          'calories': entry.value['calories'],
          'duration': entry.value['duration'],
          'intensity': entry.value['intensity'],
        },
        selectedActivity == entry.key,
      );
    }).toList();
  }

  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 8, right: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF808B9A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF808B9A)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Training',
        style: TextStyle(
          color: Color(0xFF39434F),
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Choose your workout activity',
        style: TextStyle(
          color: Color(0xFF808B9A),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}