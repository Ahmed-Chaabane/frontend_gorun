import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/gradient_icon_painter.dart';

class HistoryActiviteSportifScreen extends StatefulWidget {
  @override
  _HistoryActiviteSportifScreenState createState() => _HistoryActiviteSportifScreenState();
}

class _HistoryActiviteSportifScreenState extends State<HistoryActiviteSportifScreen> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _selectedActivityId;

  @override
  void initState() {
    super.initState();
    _fetchSportActivities();
  }

  Future<void> _fetchSportActivities() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Utilisateur non connecté';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/activitesportive/user/activities?firebase_uid=${user.uid}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _activities = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int? totalSeconds) {
    final seconds = totalSeconds ?? 0;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _safeFormatNumber(dynamic value, {int fractionDigits = 2}) {
    if (value == null) return '0.${'0' * fractionDigits}';
    if (value is num) return value.toStringAsFixed(fractionDigits);
    try {
      return double.parse(value.toString()).toStringAsFixed(fractionDigits);
    } catch (e) {
      return '0.${'0' * fractionDigits}';
    }
  }

  IconData _getActivityIcon(String? activityType) {
    switch (activityType?.toLowerCase()) {
      case 'course': return FontAwesomeIcons.running;
      case 'running': return FontAwesomeIcons.running;
      case 'vélo': return FontAwesomeIcons.bicycle;
      case 'cycling': return FontAwesomeIcons.bicycle;
      case 'natation': return FontAwesomeIcons.swimmer;
      case 'swimming': return FontAwesomeIcons.swimmer;
      case 'marche': return FontAwesomeIcons.walking;
      case 'walking': return FontAwesomeIcons.walking;
      case 'musculation': return FontAwesomeIcons.dumbbell;
      default: return FontAwesomeIcons.heartbeat;
    }
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, int index) {
    final activityId = activity['id']?.toString() ?? index.toString();
    final isSelected = _selectedActivityId == activityId;
    final distance = _safeFormatNumber(activity['distance']);
    final speed = _safeFormatNumber(activity['speed'], fractionDigits: 1);
    final heartRate = activity['heart_rate']?.toString() ?? 'N/A';
    final calories = activity['calories']?.toString() ?? '0';
    final duration = activity['duration'] is Map ? activity['duration']['seconds'] : 0;
    final activityType = activity['type']?.toString() ?? 'Activité';
    final icon = _getActivityIcon(activityType);
    final date = activity['date']?.toString() ?? 'Date inconnue';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedActivityId = isSelected ? null : activityId;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: isSelected ? 340 : 130, // Augmenté de 20px pour accommoder le padding supplémentaire
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF5BA41) : Colors.white,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activityType.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF808B9A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : const Color(0xFF808B9A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildMetricRow(
                                Icons.timer,
                                'Durée',
                                _formatDuration(duration),
                                isSelected: isSelected,
                              ),
                              const SizedBox(height: 12),
                              _buildMetricRow(
                                Icons.map,
                                'Distance',
                                '$distance km',
                                isSelected: isSelected,
                              ),
                              const SizedBox(height: 12),
                              _buildMetricRow(
                                Icons.speed,
                                'Vitesse',
                                '$speed m/s',
                                isSelected: isSelected,
                              ),
                              const SizedBox(height: 12),
                              _buildMetricRow(
                                FontAwesomeIcons.heartbeat,
                                'Rythme cardiaque',
                                '$heartRate bpm',
                                isSelected: isSelected,
                              ),
                              const SizedBox(height: 12),
                              _buildMetricRow(
                                Icons.local_fire_department,
                                'Calories brûlées',
                                '$calories kcal',
                                isSelected: isSelected,
                              ),
                              const SizedBox(height: 20), // Padding ajouté ici
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: isSelected
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 60,
                          color: Colors.white,
                        ),
                      ],
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

  Widget _buildMetricRow(IconData icon, String label, String value, {required bool isSelected}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isSelected ? Colors.white : const Color(0xFF4DD4DE)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white70 : const Color(0xFF808B9A),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0A1F4D),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                : _activities.isEmpty
                ? const Center(child: Text('Aucune activité enregistrée'))
                : Column(
              children: List.generate(
                _activities.length,
                    (index) => _buildActivityCard(_activities[index], index),
              ),
            ),
            const SizedBox(height: 24),
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Text(
      'Historique des Activités',
      style: TextStyle(
        color: Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Retrouvez toutes vos performances sportives',
      style: TextStyle(
        color: Color(0xFF808B9A),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}