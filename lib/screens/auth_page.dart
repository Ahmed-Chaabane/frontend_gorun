import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String? _accessToken;
  String? _errorMessage;

  Future<String> authenticateWithSpotify() async {
    try {
      // Étape 1 : Redirection vers l'URL d'autorisation de Spotify
      final result = await FlutterWebAuth.authenticate(
        url:
        'https://accounts.spotify.com/authorize?client_id=YOUR_CLIENT_ID&response_type=code&redirect_uri=YOUR_REDIRECT_URI&scope=user-library-read%20user-read-playback-state%20user-modify-playback-state',
        callbackUrlScheme: 'YOUR_CALLBACK_URL_SCHEME',
      );

      // Étape 2 : Récupérer le code d'autorisation depuis l'URL de redirection
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw Exception('Authorization code not found');
      }

      // Étape 3 : Échanger le code d'autorisation contre un token d'accès
      final tokenResponse = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic YOUR_BASE64_ENCODED_CLIENT_ID_AND_SECRET',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': 'YOUR_REDIRECT_URI',
        },
      );

      // Vérifier si la requête a réussi
      if (tokenResponse.statusCode == 200) {
        final accessToken = json.decode(tokenResponse.body)['access_token'];
        return accessToken;
      } else {
        throw Exception(
            'Failed to load access token: ${tokenResponse.statusCode} - ${tokenResponse.body}');
      }
    } catch (e) {
      throw Exception('Failed to authenticate with Spotify: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Démarrer le processus d'authentification au chargement de la page
    authenticateWithSpotify().then((token) {
      setState(() {
        _accessToken = token;
        _errorMessage = null;
      });
    }).catchError((error) {
      setState(() {
        _errorMessage = error.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spotify Authentication')),
      body: Center(
        child: _errorMessage != null
            ? Text('Error: $_errorMessage', style: TextStyle(color: Colors.red))
            : _accessToken == null
            ? CircularProgressIndicator()
            : Text('Access Token: $_accessToken'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AuthPage(),
  ));
}