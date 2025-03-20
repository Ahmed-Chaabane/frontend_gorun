import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  static Future<List<dynamic>> fetchPlaylists(String userId) async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/spotify/playlists?userId=$userId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Erreur de récupération des playlists Spotify');
    }
  }
}
