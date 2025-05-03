import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button (same style)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, size: 28),
                onPressed: () => Navigator.pop(context),
                splashRadius: 20,
              ),
            ),
            SizedBox(height: 12),

            // Header (matching help screen style)
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
                    child: Icon(Icons.settings_rounded,
                        size: 28, color: Colors.blue),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paramètres de l\'application',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Personnalisez votre expérience',
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

            // Account Section
            _buildSectionTitle('Compte'),
            SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.person_outline_rounded,
              title: "Profil",
              subtitle: "Modifiez vos informations",
              color: Colors.blue,
              onTap: () => _navigateTo(context, '/profile'),
            ),
            _buildSettingsItem(
              icon: Icons.lock_outline_rounded,
              title: "Sécurité",
              subtitle: "Mot de passe et authentification",
              color: Colors.orange,
              onTap: () => _navigateTo(context, '/security'),
            ),
            SizedBox(height: 24),

            // Preferences Section
            _buildSectionTitle('Préférences'),
            SizedBox(height: 12),
            _buildSettingsSwitchItem(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              subtitle: "Activer/Désactiver les alertes",
              color: Colors.purple,
              value: true,
              onChanged: (val) {},
            ),
            _buildSettingsItem(
              icon: Icons.language_rounded,
              title: "Langue",
              subtitle: "Français",
              color: Colors.green,
              onTap: () => _showLanguageDialog(context),
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode_outlined,
              title: "Thème",
              subtitle: "Automatique",
              color: Colors.indigo,
              onTap: () => _showThemeDialog(context),
            ),
            SizedBox(height: 24),

            // Privacy Section
            _buildSectionTitle('Confidentialité'),
            SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: "Politique de confidentialité",
              subtitle: "Comment nous utilisons vos données",
              color: Colors.red,
              onTap: () => _launchUrl('https://example.com/privacy'),
            ),
            _buildSettingsItem(
              icon: Icons.description_outlined,
              title: "Conditions d'utilisation",
              subtitle: "Lire les termes",
              color: Colors.teal,
              onTap: () => _launchUrl('https://example.com/terms'),
            ),
            SizedBox(height: 24),

            // Support Section (matches help screen style)
            _buildSectionTitle('Support'),
            SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.help_outline_rounded,
              title: "Aide & Support",
              subtitle: "FAQ et contact",
              color: Colors.blue,
              onTap: () => _navigateTo(context, '/help_support'),
            ),
            _buildSettingsItem(
              icon: Icons.info_outline_rounded,
              title: "À propos",
              subtitle: "Version 1.0.0",
              color: Colors.grey,
              onTap: () => _navigateTo(context, '/about'),
            ),
            SizedBox(height: 40),

            // Logout button (different style for emphasis)
            Center(
              child: TextButton(
                onPressed: () => _showLogoutDialog(context),
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable components (same style as help screen) -----------------

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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
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
          height: 80,
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

  Widget _buildSettingsSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Container(
        height: 80,
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods -------------------------------------------------

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir le lien';
    }
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Français', true),
            _buildLanguageOption('English', false),
            _buildLanguageOption('العربية', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
      onTap: () {},
    );
  }

  void _showThemeDialog(BuildContext context) {
    // Pour lire le thème
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, 'Automatique', ThemeMode.system),
            _buildThemeOption(context, 'Clair', ThemeMode.light),
            _buildThemeOption(context, 'Sombre', ThemeMode.dark),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, ThemeMode mode) {
    final themeController = Provider.of<ThemeController>(context);

    return ListTile(
      title: Text(title),
      trailing: themeController.themeMode == mode
          ? Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        themeController.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Se déconnecter'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
            },
            child: Text('Déconnecter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
