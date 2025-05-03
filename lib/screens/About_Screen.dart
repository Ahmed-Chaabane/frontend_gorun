import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For social icons

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, size: 28),
                onPressed: () => Navigator.pop(context),
                splashRadius: 20,
              ),
            ),
            SizedBox(height: 12),

            // Header
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
                    child: Icon(Icons.info_outline_rounded,
                        size: 28, color: Colors.blue),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About GoRun',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your running companion in Tunisia',
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

            // App Information
            _buildSectionTitle('App Information'),
            SizedBox(height: 12),
            _buildAboutItem(
              icon: Icons.apps_rounded,
              title: "Version",
              subtitle: "v1.0.0",
              color: Colors.blue,
            ),
            _buildAboutItem(
              icon: Icons.update_rounded,
              title: "Last Updated",
              subtitle: "April 2025",
              color: Colors.green,
            ),
            SizedBox(height: 24),

            // Company Information (Tunisia specific)
            _buildSectionTitle('Our Company'),
            _buildAboutItem(
              icon: Icons.location_on_rounded,
              title: "Location",
              subtitle: "Tunis, Tunisia",
              color: Colors.red,
              onTap: () => _launchMaps(36.8065, 10.1815), // Tunis coordinates
            ),
            _buildAboutItem(
              icon: Icons.phone_rounded,
              title: "Contact",
              subtitle: "+216 29 373 096",
              color: Colors.orange,
              onTap: () => _launchPhone("+21629373096"),
            ),
            SizedBox(height: 24),

            // Legal Information
            _buildSectionTitle('Legal'),
            SizedBox(height: 12),
            _buildAboutItem(
              icon: Icons.privacy_tip_rounded,
              title: "Privacy Policy",
              subtitle: "How we protect your data",
              color: Colors.indigo,
              onTap: () => _launchUrl('https://gorun.tn/privacy'),
            ),
            _buildAboutItem(
              icon: Icons.description_rounded,
              title: "Terms of Service",
              subtitle: "Usage terms and conditions",
              color: Colors.brown,
              onTap: () => _launchUrl('https://gorun.tn/terms'),
            ),
            SizedBox(height: 24),

            // Tunisian Social Media
            _buildSectionTitle('Follow Us'),
            SizedBox(height: 12),
            _buildSocialButton(
              icon: FontAwesomeIcons.facebookF,
              label: "Facebook",
              color: Color(0xFF1877F2), // Facebook blue
              onTap: () => _launchUrl('https://facebook.com/GoRunTunisia'),
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.instagram,
              label: "Instagram",
              color: Color(0xFFE1306C), // Instagram gradient start
              onTap: () => _launchUrl('https://instagram.com/gorun_tn'),
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.xTwitter,
              label: "Twitter",
              color: Colors.black,
              onTap: () => _launchUrl('https://twitter.com/GoRun_TN'),
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.linkedinIn,
              label: "LinkedIn",
              color: Color(0xFF0077B5), // LinkedIn blue
              onTap: () => _launchUrl('https://linkedin.com/company/gorun-tunisia'),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Reusable components
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

  Widget _buildAboutItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
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
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
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
          height: 70,
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
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
      throw 'Could not launch phone';
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch maps';
    }
  }
}