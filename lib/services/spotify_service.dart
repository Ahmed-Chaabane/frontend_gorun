import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyService {
  static Future<String?> getSpotifyAccessToken() async {
    final String clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
    final String clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;
    const String url = "https://accounts.spotify.com/api/token";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}",
      },
      body: "grant_type=client_credentials",
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["access_token"];
    } else {
      print("Erreur Spotify: ${response.body}");
      return null;
    }
  }
}
