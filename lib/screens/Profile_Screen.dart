import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Back Button
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded,
                      size: 28,
                      color: Color(0xFF0C1A37)),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.edit_rounded,
                      size: 24,
                      color: Color(0xFF4DD4DE)),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 20),

            // Profile Header
            Center(
              child: Column(
                children: [
                  // Gradient Circle Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4DD4DE), Color(0xFF0C1A37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(
                            'https://randomuser.me/api/portraits/men/42.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mohamed Ali',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C1A37),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tunis, Tunisia',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5A6C8A),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge(FontAwesomeIcons.medal, 'Gold Runner'),
                      SizedBox(width: 8),
                      _buildBadge(FontAwesomeIcons.fire, '5 Day Streak'),
                      SizedBox(width: 8),
                      _buildBadge(FontAwesomeIcons.trophy, 'Top 10%'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Personal Information Section
            _buildSectionTitle('Personal Information'),
            SizedBox(height: 12),
            _buildProfileItem(
              icon: Icons.person_outline_rounded,
              title: "Username",
              value: "mo_ali_run",
              color: Color(0xFF4DD4DE),
            ),
            _buildProfileItem(
              icon: Icons.email_outlined,
              title: "Email",
              value: "m.ali@example.tn",
              color: Color(0xFF0C1A37),
            ),
            _buildProfileItem(
              icon: Icons.phone_outlined,
              title: "Phone",
              value: "+216 12 345 678",
              color: Color(0xFF4DD4DE),
            ),
            _buildProfileItem(
              icon: Icons.cake_outlined,
              title: "Date of Birth",
              value: "15 March 1990",
              color: Color(0xFF0C1A37),
            ),
            SizedBox(height: 24),

            // Running Statistics
            _buildSectionTitle('Running Statistics'),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    value: "156",
                    label: "Total Runs",
                    icon: FontAwesomeIcons.running,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    value: "643 km",
                    label: "Distance",
                    icon: FontAwesomeIcons.road,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    value: "5:42",
                    label: "Avg Pace",
                    icon: FontAwesomeIcons.clock,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    value: "2,450",
                    label: "Calories",
                    icon: FontAwesomeIcons.fire,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Settings Section
            _buildSectionTitle('Settings'),
            SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: "Notifications",
              color: Color(0xFF4DD4DE),
              isSwitch: true,
              switchValue: true,
            ),
            _buildSettingsItem(
              icon: Icons.language_outlined,
              title: "Language",
              textValue: "English",
              color: Color(0xFF0C1A37),
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              color: Color(0xFF4DD4DE),
              isSwitch: true,
              switchValue: false,
            ),
            SizedBox(height: 32),

            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red, backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Reusable Components
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0C1A37),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Color(0xFF0C1A37)),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0C1A37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A6C8A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0C1A37),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0xFF4DD4DE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: Color(0xFF4DD4DE)),
                ),
                Spacer(),
                Icon(Icons.trending_up_rounded,
                    color: Color(0xFF4DD4DE), size: 20),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1A37),
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF5A6C8A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Color color = const Color(0xFF0C1A37),
    String? textValue,
    bool isSwitch = false,
    bool switchValue = false,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0C1A37),
                ),
              ),
            ),
            if (isSwitch)
              Switch(
                value: switchValue,
                onChanged: (bool newValue) {},
                activeColor: Color(0xFF4DD4DE),
              )
            else if (textValue != null)
              Text(
                textValue,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A6C8A),
                ),
              ),
            if (!isSwitch)
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: TextStyle(color: Color(0xFF0C1A37))),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF5A6C8A))),
          ),
          TextButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
              Navigator.pop(context); // Close profile screen
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}