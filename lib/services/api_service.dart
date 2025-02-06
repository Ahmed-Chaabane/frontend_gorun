import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000'; // L'URL de votre backend

  static Future<void> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/activite_sportive'));  // Remplacez par la route correcte
      if (response.statusCode == 200) {
        print('Connexion réussie avec le backend');
      } else {
        print('Erreur de connexion : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la connexion au backend: $e');
    }
  }
}