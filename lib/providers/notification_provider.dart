import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  String _notificationMessage = "Chargement..."; // Message par défaut
  String _errorMessage = ''; // Message d'erreur
  bool _hasError = false; // Indicateur d'erreur
  late Timer _timer; // Timer pour actualiser les notifications

  String get notificationMessage => _notificationMessage;
  String get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  NotificationProvider() {
    // Commencer à récupérer la notification
    fetchNotification();
    // Met à jour la notification toutes les minutes
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchNotification();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Arrête le timer quand le provider est détruit
    super.dispose();
  }

  // Méthode pour récupérer une notification depuis le service
  Future<void> fetchNotification() async {
    _errorMessage = '';
    _hasError = false;

    // Récupération du message depuis le service de notification
    String? message = await NotificationService.getRandomNotification();
    if (message != null) {
      _notificationMessage = message;
    } else {
      _hasError = true;
      _errorMessage = 'Erreur lors de la récupération de la notification';
    }
    notifyListeners(); // Notifie les widgets qui écoutent ce provider
  }

  // Méthode pour mettre à jour la notification manuellement
  void updateNotification() {
    fetchNotification();
  }

  // Méthode pour forcer une erreur et afficher un message personnalisé
  void forceError(String errorMessage) {
    _hasError = true;
    _errorMessage = errorMessage;
    _notificationMessage = ''; // Masquer le message de notification en cas d'erreur
    notifyListeners(); // Notifie les widgets écoutant ce provider
  }
}
