import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flèche de retour qui défile avec le contenu
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, size: 28),
                onPressed: () => Navigator.pop(context),
                splashRadius: 20,
              ),
            ),
            SizedBox(height: 12),

            // Section "Comment puis-je vous aider?"
            Container(
              height: 120,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.support_agent_rounded,
                        size: 28, color: Colors.blue),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comment puis-je vous aider?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Trouvez des solutions ou contactez notre équipe',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            _buildSectionTitle('Aide Rapide'),
            SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.help_outline_rounded,
              title: "FAQ",
              subtitle: "Questions fréquemment posées",
              color: Colors.blue,
              height: 80,
              onTap: () => _launchUrl('https://votresite.com/faq-tn'),
            ),
            _buildHelpItem(
              icon: Icons.video_library_rounded,
              title: "Tutoriels Vidéo",
              subtitle: "Guides pas à pas",
              color: Colors.purple,
              height: 80,
              onTap: () => _launchUrl('https://youtube.com/votrechaine'),
            ),
            SizedBox(height: 24),

            _buildSectionTitle('Nous Contacter'),
            SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.email_rounded,
              title: "Email Support",
              subtitle: "Réponse sous 24 heures",
              color: Colors.teal,
              height: 80,
              onTap: () => _launchEmail('support@gorun.com'),
            ),
            _buildHelpItem(
              icon: Icons.phone_rounded,
              title: "Support Téléphonique",
              subtitle: "+216 29 373 096",
              color: Colors.green,
              height: 80,
              onTap: () => _launchPhone('+216XXXXXXXX'),
            ),
            SizedBox(height: 24),

            _buildSectionTitle('Ressources Utiles'),
            SizedBox(height: 12),
            _buildResourceCard(
              title: "Guide d'Utilisation",
              description: "Manuel complet de l'application",
              icon: Icons.article_rounded,
              color: Colors.blue,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double height,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir le lien';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Demande de support',
    );

    if (await canLaunch(params.toString())) {
      await launch(params.toString());
    } else {
      throw 'Impossible d\'ouvrir l\'email';
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri params = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunch(params.toString())) {
      await launch(params.toString());
    } else {
      throw 'Impossible de composer le numéro';
    }
  }

  Future<void> _openMapLocation() async {
    final url = 'https://www.google.com/maps?q=36.8065,10.1815';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir la carte';
    }
  }
}