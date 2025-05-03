import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpotifyAuthService {
  final storage = FlutterSecureStorage();
  final String redirectUri = 'http://localhost:3000/callback';  // URL de redirection
  final String clientId = '37c7fc0b8d4e46dcb150e8caaa7f6bf9';
  final String clientSecret = '100ee72078fb4c739bc04aa4518b0e05';

  // Fonction d'authentification pour ouvrir Spotify
  Future<void> authenticate() async {
    final String authUrl = 'https://accounts.spotify.com/authorize?response_type=code&client_id=$clientId&scope=user-read-email%20user-read-private%20user-top-read&redirect_uri=$redirectUri';

    // Ouvrir l'URL dans le navigateur
    if (await canLaunch(authUrl)) {
      await launch(authUrl);
    } else {
      throw 'Impossible d\'ouvrir l\'URL d\'authentification Spotify';
    }
  }

  // Fonction pour gérer le callback après l'authentification
  Future<void> handleCallback(String code) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/spotify/callback'), // Ton endpoint backend
      body: {'code': code},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'access_token', value: data['access_token']);
      await storage.write(key: 'refresh_token', value: data['refresh_token']);
      print('Tokens stockés');
    } else {
      throw Exception('Erreur lors de l\'échange du code');
    }
  }

  // Fonction pour récupérer le token d'accès
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }
}

class SpotifyAuthPage extends StatelessWidget {
  final SpotifyAuthService authService = SpotifyAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentification Spotify')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await authService.authenticate(); // Ouvre l'URL pour l'authentification
          },
          child: Text('Se connecter avec Spotify'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SpotifyAuthPage()));
}
