import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpotifyApiService {
  final storage = FlutterSecureStorage();

  // Récupérer les informations de profil utilisateur
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final accessToken = await storage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Token expiré, gérer le rafraîchissement ici
        throw Exception('Token expiré. Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur lors de la récupération du profil utilisateur : ${response.body}');
      }
    } catch (e) {
      print("❌ Erreur : $e");
      return null;
    }
  }

  // Récupérer les playlists de l'utilisateur
  Future<List<dynamic>> getUserPlaylists() async {
    try {
      final accessToken = await storage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['items'];
      } else if (response.statusCode == 401) {
        // Token expiré, gérer le rafraîchissement ici
        throw Exception('Token expiré. Veuillez vous reconnecter');
      } else {
        throw Exception('Erreur lors de la récupération des playlists : ${response.body}');
      }
    } catch (e) {
      print("❌ Erreur : $e");
      return [];
    }
  }
}
