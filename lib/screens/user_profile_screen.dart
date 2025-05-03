import 'package:flutter/material.dart';
import '../services/spotify_api_service.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final SpotifyApiService apiService = SpotifyApiService();
  bool isLoading = true;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      userProfile = await apiService.getUserProfile();
    } catch (e) {
      print("Erreur : $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfile == null) {
      return Scaffold(body: Center(child: Text('Erreur de chargement du profil')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profil Spotify')),
      body: Center(
        child: Column(
          children: [
            Text('Nom: ${userProfile!['display_name']}'),
            Text('Email: ${userProfile!['email']}'),
            Image.network(userProfile!['images'][0]['url']),
          ],
        ),
      ),
    );
  }
}