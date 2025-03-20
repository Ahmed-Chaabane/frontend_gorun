import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyAuth {
  final String clientId = '37c7fc0b8d4e46dcb150e8caaa7f6bf9'; // Votre Client ID
  final String clientSecret = '100ee72078fb4c739bc04aa4518b0e05'; // Votre Client Secret
  final String redirectUri = 'myapp://callback'; // Schéma d'URL personnalisé
  final String scope = 'user-read-private user-read-email streaming'; // Permissions

  Future<String> authenticate() async {
    final authUrl = 'https://accounts.spotify.com/authorize?'
        'client_id=$clientId&'
        'response_type=code&'
        'redirect_uri=$redirectUri&'
        'scope=$scope';

    try {
      final result = await FlutterWebAuth.authenticate(
        url: authUrl,
        callbackUrlScheme: 'myapp', // Doit correspondre au schéma de redirectUri
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Code d\'autorisation non reçu');
      }

      final token = await _getAccessToken(code);
      return token;
    } catch (e) {
      print('Erreur d\'authentification : $e');
      rethrow;
    }
  }

  Future<String> _getAccessToken(String code) async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Erreur lors de l\'obtention du token : ${response.body}');
    }
  }
}

class SpotifyScreen extends StatelessWidget {
  final SpotifyAuth _spotifyAuth = SpotifyAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spotify Player'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _spotifyAuth.authenticate,
          child: Text('Se connecter à Spotify'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    routes: {
      '/callback': (context) => CallbackScreen(),
    },
    home: SpotifyScreen(),
  ));
}

class CallbackScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final code = Uri.base.queryParameters['code'];
    if (code != null) {
      // Échangez le code contre un token d'accès
      // ...
    }
    return Scaffold(
      body: Center(
        child: Text('Authentification réussie !'),
      ),
    );
  }
}