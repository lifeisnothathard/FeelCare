// lib/drawer/side_dashboard.dart
import 'package:flutter/material.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/themes/colors.dart'; // Ensure this is correctly imported
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  final ThemeProvider themeProvider;

  const AppDrawer({
    super.key,
    required this.themeProvider, // HANYA themeProvider yang diperlukan di sini
  });

  @override
  Widget build(BuildContext context) {
    // Dapatkan data pengguna secara langsung dari Firebase di sini
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'No email';
    final userName = user?.displayName ?? 'User';

    // Get adaptive colors for the drawer
    final Color drawerBackgroundColor = AppColors.getAdaptiveBackgroundColor(context);
    final Color drawerTextColor = AppColors.getAdaptiveTextColor(context);
    final Color drawerHeaderColor = Theme.of(context).colorScheme.primary; // Use theme primary

    return Drawer(
      backgroundColor: drawerBackgroundColor, // Use adaptive background color
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)), // Use theme's onPrimary
            accountEmail: Text(userEmail, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8))), // Use theme's onPrimary
            currentAccountPicture: user?.photoURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.photoURL!),
                  )
                : CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary, // Use theme's secondary for placeholder
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 24), // Use theme's onSecondary
                    ),
                  ),
            decoration: BoxDecoration(
              color: drawerHeaderColor, // Use theme primary color for header
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: drawerTextColor),
            title: Text('Home', style: TextStyle(color: drawerTextColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: drawerTextColor),
            title: Text('Profile', style: TextStyle(color: drawerTextColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          // Removed Settings ListTile
          // ListTile(
          //   leading: Icon(Icons.settings, color: drawerTextColor),
          //   title: Text('Settings', style: TextStyle(color: drawerTextColor)),
          //   onTap: () {
          //     Navigator.pop(context);
          //     // Handle settings navigation
          //   },
          // ),
          Divider(color: drawerTextColor.withOpacity(0.5)), // Kept the divider to separate main items from logout
          ListTile(
            leading: Icon(Icons.logout, color: drawerTextColor),
            title: Text('Logout', style: TextStyle(color: drawerTextColor)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            },
          ),
          // Removed Toggle Theme ListTile
          // ListTile(
          //   leading: Icon(
          //     themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
          //     color: drawerTextColor,
          //   ),
          //   title: Text('Toggle Theme', style: TextStyle(color: drawerTextColor)),
          //   onTap: () {
          //     themeProvider.toggleTheme(themeProvider.themeMode != ThemeMode.dark);
          //   },
          // ),
        ],
      ),
    );
  }
}
