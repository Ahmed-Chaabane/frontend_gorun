import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = 'http://localhost:3000/api/notifications';

  // Récupérer une notification aléatoire
  static Future<String?> getRandomNotification() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/random'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message']; // Récupère le message de motivation
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de la notification: $e');
      return null;
    }
  }
}
