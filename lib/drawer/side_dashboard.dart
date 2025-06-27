import 'package:flutter/material.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/themes/colors.dart'; // Pastikan ini diimport
import 'package:firebase_auth/firebase_auth.dart'; // Pastikan ini diimport

class AppDrawer extends StatelessWidget {
  final ThemeProvider themeProvider;

  const AppDrawer({
    super.key,
    required this.themeProvider,  // HANYA themeProvider yang diperlukan di sini
  });

  @override
  Widget build(BuildContext context) {
    // Dapatkan data pengguna secara langsung dari Firebase di sini
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'No email';
    final userName = user?.displayName ?? 'User';

    return Drawer(
      backgroundColor: AppColors.backgroundColor, // Gunakan AppColors dari themes/colors.dart
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName), // Gunakan userName yang didapatkan di sini
            accountEmail: Text(userEmail), // Gunakan userEmail yang didapatkan di sini
            currentAccountPicture: user?.photoURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL!),
                  )
                : CircleAvatar(
                    backgroundColor: AppColors.primaryGreen, // Contoh warna latar belakang
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U', // Initial huruf pertama nama
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen, // Gunakan warna tema untuk header
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: AppColors.textColor), // Contoh warna icon
            title: Text('Home', style: TextStyle(color: AppColors.textColor)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Navigate to home page if not already there
              // Navigator.pushReplacementNamed(context, '/home'); // Anda mungkin sudah di home, ini hanya contoh
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: AppColors.textColor),
            title: Text('Profile', style: TextStyle(color: AppColors.textColor)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(context, '/profile'); // Pastikan route '/profile' didefinisikan di main.dart
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.textColor),
            title: Text('Settings', style: TextStyle(color: AppColors.textColor)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Handle settings navigation
            },
          ),
          Divider(color: AppColors.textColor.withOpacity(0.5)), // Contoh divider
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.textColor),
            title: Text('Logout', style: TextStyle(color: AppColors.textColor)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            },
          ),
          // Theme toggle (optional, if you want it in the drawer)
          ListTile(
            leading: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.textColor,
            ),
            title: Text('Toggle Theme', style: TextStyle(color: AppColors.textColor)),
            onTap: () {
              themeProvider.toggleTheme(themeProvider.themeMode != ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}

class AppColors {
  // Definisikan warna-warna yang digunakan di sini
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textColor = Color(0xFF333333);
  static const Color backgroundColor = Colors.white; // atau warna lain yang Anda inginkan
}