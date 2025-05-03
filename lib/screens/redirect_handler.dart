import 'dart:async';
import 'package:uni_links/uni_links.dart';
import '../services/spotify_token_service.dart';

class RedirectHandler {
  static Future<void> listenForRedirects(Function(String code) onCodeReceived) async {
    try {
      uriLinkStream.listen((Uri? uri) async {
        if (uri != null && uri.host == "spotify-callback") {
          final String code = uri.queryParameters['code'] ?? '';
          if (code.isNotEmpty) {
            onCodeReceived(code); // Passez le code à votre backend
          }
        }
      });
    } catch (e) {
      print("Erreur lors de l'écoute des redirections : $e");
    }
  }
}