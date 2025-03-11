import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audioPlayerModel.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayerModel _audioPlayerModel;

  // Liste des pistes audio
  final List<Map<String, String>> _tracks = [
    {
      "title": "Epic Run",
      "artist": "Neffex Thug Radio",
      "albumArt": "assets/images/album1.jpg",
      "audioPath": "assets/audio/song3.mp3",
    },
    {
      "title": "Power Up",
      "artist": "Neffex Thug Radio",
      "albumArt": "assets/images/album2.jpg",
      "audioPath": "assets/audio/song4.mp3",
    },
    {
      "title": "Power Up",
      "artist": "Neffex Thug Radio",
      "albumArt": "assets/images/album3.jpg",
      "audioPath": "assets/audio/song5.mp3",
    },
  ];

  int _currentTrackIndex = 0;
  bool _isTrackLoading = false;
  bool _isFirstLoad = true; // Indicateur pour la première lecture

  @override
  void initState() {
    super.initState();
    _audioPlayerModel = Provider.of<AudioPlayerModel>(context, listen: false);

    // Utilise WidgetsBinding pour exécuter le code après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_audioPlayerModel.isPlaying &&
          _audioPlayerModel.position == Duration.zero) {
        loadTrack(
            _currentTrackIndex); // Charger automatiquement la première piste si nécessaire
      }
    });
  }

  Future<void> loadTrack(int index) async {
    if (_isTrackLoading) return;

    setState(() {
      _isTrackLoading = true;
    });

    try {
      await _audioPlayerModel.stop(); // Arrêter la lecture précédente
      // Charger la nouvelle piste
      if (kIsWeb) {
        await _audioPlayerModel.player
            .setSourceUrl(_tracks[index]["audioPath"]!);
      } else {
        await _audioPlayerModel.player
            .setSourceAsset(_tracks[index]["audioPath"]!);
      }
      // Reprendre automatiquement si nécessaire
      if (!_isFirstLoad || _audioPlayerModel.position != Duration.zero) {
        await _audioPlayerModel.seek(_audioPlayerModel.position);
        await _audioPlayerModel.play('', isNewTrack: false);
      }
      _isFirstLoad = false; // Désactiver après la première lecture
      await Future.delayed(const Duration(milliseconds: 150)); //Ajout du delai
    } catch (e) {
      print("Erreur lors du chargement de la piste : $e");
    } finally {
      if (!mounted) return;

      setState(() {
        _isTrackLoading = false;
      });
    }
  }

  Future<void> navigateTrack(bool isNext) async {
    int newIndex = _currentTrackIndex + (isNext ? 1 : -1);

    if (newIndex >= 0 && newIndex < _tracks.length) {
      // Précharger l'image
      await precacheImage(AssetImage(_tracks[newIndex]["albumArt"]!), context);

      setState(() {
        _currentTrackIndex = newIndex;
      });
      await loadTrack(newIndex); // Charger la nouvelle piste
    } else {
      print(isNext
          ? "Aucune autre piste disponible."
          : "Déjà sur la première piste.");
    }
  }

  @override
  void dispose() {
    _audioPlayerModel
        .savePosition(); // Sauvegarder la position avant de quitter
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
              ),
            ),
          ),
          // Bouton Retour
          Positioned(
            top: 20,
            left: 15,
            child: IconButton(
              key: const Key('back_button'),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isTrackLoading)
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                _buildAlbumCover(),
                _buildTrackDetails(),
                PlayerWidget(), // Contrôles de lecture
                const SizedBox(height: 20),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Affichage de la couverture de l'album
  Widget _buildAlbumCover() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Container(
          key: ValueKey<String>(_tracks[_currentTrackIndex]["albumArt"]!),
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(_tracks[_currentTrackIndex]["albumArt"]!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  // Détails de la piste
  Widget _buildTrackDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            _tracks[_currentTrackIndex]["title"]!,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            _tracks[_currentTrackIndex]["artist"]!,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Boutons de navigation (Précédent/Suivant)
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('previous_button'),
          onPressed: () => navigateTrack(false),
          icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white),
        ),
        IconButton(
          key: const Key('next_button'),
          onPressed: () => navigateTrack(true),
          icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
        ),
      ],
    );
  }
}

// Widget de contrôle du lecteur
class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          key: const Key('play_button'),
          onPressed: audioPlayerModel.isPlaying
              ? null
              : () => audioPlayerModel.play('', isNewTrack: false),
          iconSize: 48.0,
          icon: const Icon(Icons.play_arrow),
          color: Colors.white,
        ),
        IconButton(
          key: const Key('pause_button'),
          onPressed: audioPlayerModel.isPlaying
              ? () => audioPlayerModel.pause()
              : null,
          iconSize: 48.0,
          icon: const Icon(Icons.pause),
          color: Colors.white,
        ),
        IconButton(
          key: const Key('stop_button'),
          onPressed:
              audioPlayerModel.isPlaying ? () => audioPlayerModel.stop() : null,
          iconSize: 48.0,
          icon: const Icon(Icons.stop),
          color: Colors.white,
        ),
      ],
    );
  }
}
