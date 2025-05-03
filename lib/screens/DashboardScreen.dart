import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_gorun/services/spotify_token_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? userData; // Données utilisateur
  List<dynamic> playlist = []; // Playlists de l'utilisateur
  String? currentTrackName; // Piste en cours
  List<dynamic> devices = []; // Appareils connectés

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDevices();
  }

  // Fonction pour récupérer les données depuis /api/dashboard
  Future<void> fetchData() async {
    final accessToken = await SpotifyTokenService().getAccessToken();
    if (accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/dashboard"), // Assurez-vous que c'est /api/dashboard
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data['user'];
          playlist = data['playlists'];
          currentTrackName = data['currentTrack'];
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
    }
  }

  // Fonction pour récupérer les appareils connectés
  Future<void> fetchDevices() async {
    final accessToken = await SpotifyTokenService().getAccessToken();
    if (accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/spotify/devices"),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        setState(() {
          devices = json.decode(response.body);
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des appareils : $e");
    }
  }

  // Widget pour afficher une playlist individuelle
  Widget playlistTile(Map<String, dynamic> playlistData) {
    final imageUrl = playlistData['images']?.isNotEmpty == true
        ? playlistData['images'][0]['url']
        : null; // URL de l'image de la playlist
    final playlistName = playlistData['name'];
    final trackCount = playlistData['tracks']['total'];

    return ListTile(
      leading: imageUrl != null
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        width: 50,
        height: 50,
      )
          : Icon(Icons.music_note, size: 50),
      title: Text(playlistName),
      subtitle: Text("$trackCount pistes"),
      onTap: () {
        // Action à effectuer lorsque l'utilisateur clique sur une playlist
        print("Playlist sélectionnée : $playlistName");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bienvenue, ${userData!['display_name']}!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (userData!['images']?.isNotEmpty == true)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: userData!['images'][0]['url'],
                        width: 100,
                        height: 100,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.account_circle, size: 100),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            Text(
              "Piste en cours : ${currentTrackName ?? 'Aucune piste en cours'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Mes Playlists",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: playlist.isEmpty
                  ? Center(child: Text("Aucune playlist trouvée"))
                  : ListView.builder(
                itemCount: playlist.length,
                itemBuilder: (context, index) {
                  return playlistTile(playlist[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}