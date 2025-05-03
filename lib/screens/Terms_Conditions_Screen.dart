import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionsScreen extends StatelessWidget {
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

            // Header (matching previous screens style)
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
                    child: Icon(Icons.description_rounded,
                        size: 28, color: Colors.blue),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please read our terms carefully',
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

            // Terms Content
            _buildSectionTitle('Last Updated: June 2023'),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'By using our application, you agree to these terms and conditions. '
                    'Please read them carefully before using our services.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Sections
            _buildTermsSection(
              title: '1. Acceptance of Terms',
              content: 'By accessing or using our mobile application, you agree '
                  'to be bound by these Terms and Conditions. If you disagree '
                  'with any part of the terms, you may not access the application.',
            ),

            _buildTermsSection(
              title: '2. User Responsibilities',
              content: 'You agree to use the application only for lawful purposes '
                  'and in a way that does not infringe the rights of, restrict, '
                  'or inhibit anyone else\'s use and enjoyment of the application.',
            ),

            _buildTermsSection(
              title: '3. Privacy Policy',
              content: 'Your use of the application is also governed by our Privacy Policy, '
                  'which explains how we collect, use, and protect your information.',
              showButton: true,
              buttonText: 'View Privacy Policy',
              onButtonTap: () => _launchUrl('https://yourwebsite.com/privacy'),
            ),

            _buildTermsSection(
              title: '4. Intellectual Property',
              content: 'All content included in the application, such as text, graphics, '
                  'logos, and images, is the property of our company and protected by '
                  'intellectual property laws.',
            ),

            _buildTermsSection(
              title: '5. Limitation of Liability',
              content: 'We shall not be liable for any indirect, incidental, special, '
                  'consequential, or punitive damages resulting from your use of the application.',
            ),

            _buildTermsSection(
              title: '6. Changes to Terms',
              content: 'We reserve the right to modify these terms at any time. '
                  'Your continued use of the application after such changes constitutes '
                  'your acceptance of the new terms.',
            ),

            SizedBox(height: 32),
            // Acceptance Checkbox
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                    activeColor: Colors.blue,
                  ),
                  Expanded(
                    child: Text(
                      'I have read and agree to the Terms & Conditions',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Reusable components (same style as previous screens) -----------------

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

  Widget _buildTermsSection({
    required String title,
    required String content,
    bool showButton = false,
    String buttonText = '',
    VoidCallback? onButtonTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        if (showButton) ...[
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onButtonTap,
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: 16),
        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  // Helper methods -------------------------------------------------

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}