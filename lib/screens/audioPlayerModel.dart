import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerModel with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  int _currentTrackIndex = 0; // Stocke l'index du morceau en cours

  AudioPlayer get player => _player;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  int get currentTrackIndex => _currentTrackIndex;

  AudioPlayerModel() {
    _initStreams();
  }

  void _initStreams() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _player.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    });
  }

  /// Définit l'index du morceau en cours
  void setCurrentTrackIndex(int index) {
    _currentTrackIndex = index;
    notifyListeners();
  }

  /// Joue un morceau, en reprenant la lecture si nécessaire
  Future<void> play(String audioPath, {bool isNewTrack = true}) async {
    try {
      if (isNewTrack) {
        await _player.setSourceAsset(audioPath);
      }

      await _player.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la lecture audio: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _position = position;
    notifyListeners();
  }

  Future<void> savePosition() async {
    final currentPosition = await player.getCurrentPosition();
    _position = currentPosition ?? Duration.zero;
    notifyListeners();
  }

  void disposePlayer() {
    _player.dispose();
  }
}
