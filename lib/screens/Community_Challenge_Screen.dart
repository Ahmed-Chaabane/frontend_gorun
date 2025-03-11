import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CommunityChallengeScreen extends StatefulWidget {
  @override
  _CommunityChallengeScreenState createState() =>
      _CommunityChallengeScreenState();
}

class _CommunityChallengeScreenState extends State<CommunityChallengeScreen> {
  String? selectedChallenge;

  List<Map<String, dynamic>> communityChallenges = [];

  @override
  void initState() {
    super.initState();
    fetchChallenges(); // Appel pour charger les défis
  }

  Map<String, IconData> iconNameToIconData = {
    'dumbbell': FontAwesomeIcons.dumbbell,
    'running': FontAwesomeIcons.running,
    'spa': FontAwesomeIcons.spa,
    'heartbeat': FontAwesomeIcons.heartbeat,
    'weight': FontAwesomeIcons.weight,
    'bicycle': FontAwesomeIcons.bicycle,
    'swimmer': FontAwesomeIcons.swimmer,
    'om': FontAwesomeIcons.om,
    'shoePrints': FontAwesomeIcons.shoePrints,
    'users': FontAwesomeIcons.users,
    'hiking': FontAwesomeIcons.hiking,
    'bed': FontAwesomeIcons.bed,
    'dancing': FontAwesomeIcons.personDressBurst,
    // Ajoute d'autres icônes ici selon le besoin
  };

  // Fonction pour récupérer les défis depuis l'API Node.js
  Future<void> fetchChallenges() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/DefiCommunautaire'));

    print('Réponse brute de l\'API : ${response.body}'); // Log de débogage

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      setState(() {
        communityChallenges = data.map((item) {
          return {
            'id': item['id_defi_communautaire'], // Assurez-vous que c'est le bon nom de colonne
            'name': item['nom_defi'],
            'icon': iconNameToIconData[item['icon']] ?? FontAwesomeIcons.question,
            'description': item['description'],
            'participants': item['participants'] ?? 0,
            'reward': item['recompense'] ?? '',
            'progress': item['progression'] ?? 0.0,
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load challenges');
    }
  }

  // Fonction pour rejoindre un défi
  Future<void> joinChallenge(String challengeId) async {
    print('Tentative de rejoindre le défi avec ID : $challengeId'); // Log de débogage
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Aucun utilisateur connecté.'); // Log de débogage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous devez être connecté pour participer à un défi.')),
        );
        return;
      }

      final String firebaseUid = user.uid;
      print('UID Firebase de l\'utilisateur : $firebaseUid'); // Log de débogage

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/utilisateur/firebase_uid/$firebaseUid'),
      );

      print('Réponse de l\'API : ${response.statusCode} - ${response.body}'); // Log de débogage

      if (response.statusCode != 200) {
        print('Erreur lors de la récupération des informations utilisateur : ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la récupération des informations utilisateur.')),
        );
        return;
      }

      final Map<String, dynamic> userData = jsonDecode(response.body);
      print('Données utilisateur : $userData'); // Log de débogage

      final dynamic userIdDynamic = userData['id_utilisateur'];
      if (userIdDynamic == null) {
        print('ID utilisateur non trouvé dans la réponse de l\'API.'); // Log de débogage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID utilisateur non trouvé.')),
        );
        return;
      }

      final int userId = userIdDynamic as int; // Assurez-vous que c'est un entier

      final int challengeIdInt = int.tryParse(challengeId) ?? -1; // Utilisez une valeur par défaut si le parsing échoue
      if (challengeIdInt == -1) {
        print('ID du défi invalide : $challengeId'); // Log de débogage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID du défi invalide.')),
        );
        return;
      }

      final Uri url = Uri.parse('http://localhost:3000/api/defiparticipants');
      final body = json.encode({
        'id_defi': challengeIdInt,
        'id_utilisateur': userId,
        'firebase_uid': firebaseUid,
        'progression': 0.0,
        'statut': 'en cours',
      });

      print('Envoi de la requête POST à /api/defiparticipants avec le corps : $body'); // Log de débogage

      final postResponse = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Réponse de l\'API : ${postResponse.statusCode} - ${postResponse.body}'); // Log de débogage

      if (postResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous avez rejoint le défi avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la participation au défi.')),
        );
      }
    } catch (e) {
      print('Erreur lors de la participation au défi : $e'); // Log de débogage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue : $e')),
      );
    }
  }

  Widget _buildChallengeCard(Map<String, dynamic> challengeData, int index) {
    final String challengeName = challengeData['name'];
    final IconData icon = challengeData['icon'];
    final String description = challengeData['description'];
    final int participants = challengeData['participants'];
    final String reward = challengeData['reward'];
    final double progress = challengeData['progress'];
    bool isSelected = selectedChallenge == challengeName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedChallenge = isSelected ? null : challengeName;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: isSelected ? 220 : 150, // Expand the card if selected
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFF5BA41) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0x05323247),
                blurRadius: 15,
                offset: const Offset(0, 3),
                spreadRadius: -1.50,
              ),
              BoxShadow(
                color: const Color(0x0C0C1A4B),
                blurRadius: 3.75,
                offset: const Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            // Ajout de SingleChildScrollView pour éviter le débordement
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challengeName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Color(0xFF808B9A),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            description,
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Color(0xFF808B9A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Participants: $participants',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Color(0xFF808B9A),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Reward: $reward',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Color(0xFF808B9A),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    isSelected ? Colors.white : Color(0xFF4DD4DE)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: isSelected
                        ? Icon(
                      icon,
                      size: 70,
                      color: Colors.white,
                    )
                        : CustomPaint(
                      size: Size(70, 70),
                      painter: GradientIconPainter(
                        icon: icon,
                        size: 70,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          if (selectedChallenge == null) {
            print('Aucun défi sélectionné.'); // Log de débogage
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Veuillez sélectionner un défi.')),
            );
            return;
          }

          final selectedChallengeData = communityChallenges.firstWhere(
                (challenge) => challenge['name'] == selectedChallenge,
            orElse: () {
              print('Défi sélectionné non trouvé dans la liste des défis.'); // Log de débogage
              return {};
            },
          );

          if (selectedChallengeData.isEmpty) {
            print('Aucun défi sélectionné trouvé.'); // Log de débogage
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aucun défi sélectionné trouvé.')),
            );
            return;
          }

          print('Données du défi sélectionné : $selectedChallengeData'); // Log de débogage

          final dynamic challengeIdDynamic = selectedChallengeData['id'];
          if (challengeIdDynamic == null) {
            print('ID du défi est null dans les données du défi.'); // Log de débogage
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ID du défi non trouvé.')),
            );
            return;
          }

          final String challengeId = challengeIdDynamic.toString();
          print('ID du défi sélectionné : $challengeId'); // Log de débogage

          joinChallenge(challengeId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF162A5A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 70),
        ),
        child: const Text(
          'Rejoindre le défi',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 40),
            _buildTitleSection(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            const SizedBox(height: 24),
            if (communityChallenges.isNotEmpty)
              for (int i = 0; i < communityChallenges.length; i++)
                _buildChallengeCard(communityChallenges[i], i),
            const SizedBox(height: 24),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF808B9A), size: 24),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home_screen'),
          ),
          const SizedBox(width: 8),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Text(
      'Relevez des défis ensemble !',
      style: TextStyle(
        color: const Color(0xFF39434F),
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Participez à des défis communautaires et gagnez des récompenses !',
      style: TextStyle(
        color: const Color(0xFF808B9A),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class GradientIconPainter extends CustomPainter {
  final IconData icon;
  final double size;
  final Gradient gradient;

  GradientIconPainter({
    required this.icon,
    required this.size,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, this.size, this.size);
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    final TextSpan span = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: this.size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        foreground: paint,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: this.size, maxWidth: this.size);
    textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}