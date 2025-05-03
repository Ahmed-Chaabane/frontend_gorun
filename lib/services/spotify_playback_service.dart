import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/spotify_token_service.dart';

class SpotifyPlaybackService {
  final String baseUrl = "https://api.spotify.com/v1";
  final SpotifyTokenService _tokenService = SpotifyTokenService();

  // Récupère un token valide
  Future<String> getValidAccessToken() async {
    String? accessToken = await _tokenService.getAccessToken();
    if (accessToken == null) {
      throw Exception("Token d'accès non disponible");
    }

    // TODO : Ajouter une vérification de l'expiration du token
    // Si expiré, rafraîchissez le token
    return accessToken;
  }

  // Démarrer ou reprendre la lecture
  Future<void> play(String? deviceId, {String? playlistUri}) async {
    final accessToken = await getValidAccessToken();

    final response = await http.put(
      Uri.parse("$baseUrl/me/player/play${deviceId != null ? '?device_id=$deviceId' : ''}"),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: playlistUri != null ? jsonEncode({"context_uri": playlistUri}) : null,
    );

    if (response.statusCode != 204) {
      throw Exception("Échec du démarrage de la lecture : ${response.body}");
    }
  }

// Autres méthodes (pause, nextTrack, previousTrack, etc.)...
}