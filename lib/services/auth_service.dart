import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String baseUrl = 'http://localhost:3000';

  // Créer un compte utilisateur (email et mot de passe)
  Future<String> createAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String firebaseUid,
  }) async {
    try {
      // Récupérer l'UID Firebase de l'utilisateur actuellement connecté
      final String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;

      if (firebaseUid == null) {
        return 'Erreur : Aucun utilisateur Firebase n\'est connecté.';
      }

      // Enregistrer l'utilisateur dans votre backend
      final Uri url = Uri.parse('$baseUrl/api/utilisateur/');
      final body = json.encode({
        'nom': firstName,
        'prenom': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'firebase_uid': firebaseUid, // UID Firebase
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        // Après l'enregistrement, se connecter directement
        await signInWithEmailAndPassword(email: email, password: password);
        return 'Compte créé et connecté avec succès!';
      } else {
        final responseBody = jsonDecode(response.body);
        return 'Erreur lors de l\'enregistrement dans le backend : ${responseBody['error']}';
      }
    } catch (e) {
      return 'Erreur lors de la création du compte : $e';
    }
  }

  // Connexion avec Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // L'utilisateur a annulé la connexion

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await user.reload();
        User? updatedUser = _auth.currentUser;

        final userId = updatedUser?.uid;
        print('ID de l\'utilisateur Google : $userId');

        return updatedUser;
      }
    } catch (e) {
      print("❌ Erreur connexion Google : $e");
    }
    return null;
  }

  // Gérer l'utilisateur Google
  // Gérer l'utilisateur Google et authentifier directement
  Future<String> handleUser(User user) async {
    try {
      bool exists = await checkIfUserExists(user.email!);
      if (!exists) {
        // Si l'utilisateur n'existe pas, nous l'enregistrons et l'authentifions directement
        await registerUser(user);
        await signInWithGoogle(); // Authentifier l'utilisateur après l'enregistrement
        return 'Compte Google enregistré et authentifié avec succès.';
      } else {
        await signInWithGoogle(); // Authentifier l'utilisateur existant
        return 'Connexion réussie avec Google.';
      }
    } catch (e) {
      return 'Une erreur est survenue lors du traitement de votre demande : $e';
    }
  }

  // Vérifier si l'utilisateur existe
  Future<bool> checkIfUserExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/utilisateur/email/$email'),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur vérification utilisateur : $e');
      rethrow;
    }
  }

  // Modifier un utilisateur
  Future<String> updateUserDetails({
    required String firebaseUid,
    List<String>? selectedSports,
    List<String>? objectifs_amelioration,
    List<String>? preferences_sportives,
    List<String>? lieux_pratique,
    String? frequence_entrainement,
    List<String>? health_conditions,
    String? regime_alimentaire,
    String? telephone,
    String? sexe,
    int? age,
    double? taille,
    double? poids,
  }) async {
    try {
      final Uri url = Uri.parse('http://localhost:3000/api/utilisateur/update_user_details/$firebaseUid');

      Map<String, dynamic> updateFields = {};

      if (telephone != null) updateFields['telephone'] = sexe;
      if (sexe != null) updateFields['sexe'] = sexe;
      if (age != null) updateFields['age'] = age;
      if (taille != null) updateFields['taille'] = double.parse(taille.toStringAsFixed(3));
      if (poids != null) updateFields['poids'] = double.parse(poids.toStringAsFixed(2));
      if (selectedSports != null) updateFields['selectedSports'] = selectedSports;
      if (preferences_sportives != null) updateFields['preferences_sportives'] = preferences_sportives;
      if (lieux_pratique != null) updateFields['lieux_pratique'] = lieux_pratique;
      if (frequence_entrainement != null) updateFields['frequence_entrainement'] = frequence_entrainement;
      if (health_conditions != null) updateFields['health_conditions'] = health_conditions;
      if (regime_alimentaire != null) updateFields['regime_alimentaire'] = regime_alimentaire;
      if (objectifs_amelioration != null) updateFields['objectifs_amelioration'] = objectifs_amelioration;

      print('Données à mettre à jour: $updateFields');

      final body = json.encode(updateFields);

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Réponse du serveur: ${response.body}'); // Log pour déboguer

      if (response.statusCode == 200) {
        return 'Mise à jour réussie';
      } else {
        final responseBody = jsonDecode(response.body);
        return 'Erreur : ${responseBody['error']}';
      }
    } catch (e) {
      return 'Erreur de mise à jour : $e';
    }
  }

  Future<void> processUserDataWithML() async {
    final url = Uri.parse('https://ton-api.com/getUserDataForML');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> userData = jsonDecode(response.body);

        // Télécharger et charger le modèle IA
        final model = await FirebaseModelDownloader.instance.getModel(
            "training_recommendation_model",
            FirebaseModelDownloadType.localModelUpdateInBackground
        );

        print('Modèle IA téléchargé avec succès: ${model.file.path}');

        // Appliquer le modèle aux données (exemple simplifié)
        for (var user in userData) {
          generateTrainingPlan(user);
        }
      } else {
        print('Erreur lors de la récupération des données');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  void generateTrainingPlan(Map<String, dynamic> user) {
    String uid = user['firebase_uid'];
    List<String> sports = List<String>.from(user['selectedSports']);
    String frequency = user['frequence_entrainement'];
    String regime = user['regime_alimentaire'];

    print('Génération du plan pour UID: $uid');

    // Exemples basés sur les données
    if (sports.contains("Tennis") && frequency == "more than 3 times per week") {
      print("Plan d'entraînement : Séances de cardio et agilité");
    } else if (sports.contains("Yoga")) {
      print("Plan d'entraînement : Exercices de flexibilité et méditation");
    }

    if (regime == "Vegan") {
      print("Plan alimentaire : Protéines végétales et compléments B12");
    }
  }


  // Enregistrer un utilisateur Google
  Future<String> registerUser(User user) async {
    try {
      final body = json.encode({
        'nom': user.displayName ?? '',
        'email': user.email,
        'photoUrl': user.photoURL ?? '',
        'provider': 'google',
        'firebase_uid': user.uid,  // Ajouter l'UID Firebase ici aussi
      });
      final response = await http.post(
        Uri.parse('$baseUrl/api/utilisateur/create'),
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      if (response.statusCode == 201) {
        return 'Utilisateur Google enregistré.';
      } else {
        throw Exception('Erreur lors de l\'inscription : ${response.statusCode}');
      }
    } catch (e) {
      return 'Erreur enregistrement Google : $e';
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print('Déconnexion réussie.');
    } catch (e) {
      print('Erreur déconnexion : $e');
    }
  }

  // Connexion avec email et mot de passe
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Utilisation de Firebase pour la connexion avec email et mot de passe
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Connexion réussie
        print('Utilisateur connecté : ${user.uid}');
        return 'Connexion réussie avec email et mot de passe.';
      } else {
        return 'Erreur de connexion. L\'utilisateur n\'a pas pu être authentifié.';
      }
    } catch (e) {
      // Gérer l'erreur ici
      return 'Erreur lors de la connexion : $e';
    }
  }

  // Stream pour surveiller les changements d'état d'authentification
  Stream<User?> get user => _auth.authStateChanges();

  // Récupérer l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Méthode pour récupérer l'ID de l'utilisateur actuel
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
