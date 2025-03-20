import 'package:audioplayers/audioplayers.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class MusicService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSpotifyConnected = false;
  bool get isSpotifyConnected => _isSpotifyConnected;

  // Connexion à Spotify (réutiliser si déjà connecté)
  Future<void> connectToSpotify() async {
    if (_isSpotifyConnected) return;  // Si déjà connecté, on ne refait pas la connexion
    try {
      _isSpotifyConnected = await SpotifySdk.connectToSpotifyRemote(
        clientId: '37c7fc0b8d4e46dcb150e8caaa7f6bf9',
        redirectUrl: 'https://edcd-197-17-88-55.ngrok-free.app/callback',
      );
    } catch (e) {
      print('Erreur connexion Spotify : $e');
    }
  }

  Future<void> playSpotifyMusic(String spotifyUri) async {
    if (!_isSpotifyConnected) await connectToSpotify(); // Connexion si nécessaire
    try {
      await SpotifySdk.play(spotifyUri: spotifyUri);
    } catch (e) {
      print('Erreur lecture Spotify : $e');
    }
  }

  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
    await SpotifySdk.pause();
  }

  Future<void> resumeMusic() async {
    await _audioPlayer.resume();
    await SpotifySdk.resume();
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
    await SpotifySdk.pause();
  }
}
