import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      child: Icon(Icons.person, size: 48),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFFBF5102),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adewale O.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'adewale@gmail.com',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.orange[400]),
                          const SizedBox(width: 4.0),
                          const Text(
                            '4.8',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text('Silver Member', style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32.0),
          const Text(
            'Saved Places',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          
          _buildSettingsTile(
            icon: Icons.home,
            title: 'Home',
            subtitle: '142 Ahmadu Bello Way',
            trailing: IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
          ),
          _buildSettingsTile(
            icon: Icons.work,
            title: 'Work',
            subtitle: 'Landmark Centre',
            trailing: IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
          ),
          
          const SizedBox(height: 32.0),
          const Text(
            'Settings & Support',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Offers, Trip updates',
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFFBF5102)),
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Safety Settings',
            subtitle: 'Manage Trusted Contacts',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
          _buildSettingsTile(
            icon: Icons.headset_mic,
            title: 'Help & Support',
            subtitle: 'FAQs, Contact us',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'Version 1.0.0',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
          
          const SizedBox(height: 32.0),
          TextButton(
            onPressed: () {
               // Log out logic
               Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // assuming '/' is auth choice
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, color: Colors.black54),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}
