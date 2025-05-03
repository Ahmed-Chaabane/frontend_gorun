import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyLoginScreen extends StatelessWidget {
  const SpotifyLoginScreen({super.key});

  // Ouvre Spotify dans le navigateur
  Future<void> _openSpotify() async {
    const url = 'https://open.spotify.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Impossible d\'ouvrir Spotify';
    }
  }

  // Ouvre une playlist spécifique
  Future<void> _openPlaylist() async {
    const playlistUrl = 'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M';
    if (await canLaunchUrl(Uri.parse(playlistUrl))) {
      await launchUrl(
        Uri.parse(playlistUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ouvrir Spotify'),
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF191414), Color(0xFF1DB954)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note, size: 100, color: Colors.white),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _openSpotify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Ouvrir Spotify',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openPlaylist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Playlist du moment',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}