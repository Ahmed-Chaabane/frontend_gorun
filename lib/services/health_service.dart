import 'package:health/health.dart';

class HealthService {
  final HealthFactory _health = HealthFactory();

  Future<List<HealthDataPoint>> fetchHealthData() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    // Demander les permissions
    bool accessGranted = await _health.requestAuthorization(types);
    if (!accessGranted) {
      throw Exception("Accès refusé à Google Fit / Apple Health");
    }

    // Récupérer les données
    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(yesterday, now, types);
    return healthData;
  }
}
