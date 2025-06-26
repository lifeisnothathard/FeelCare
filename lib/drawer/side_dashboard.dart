import 'package:flutter/material.dart';
import 'package:wecare/core/dashboard.dart';
import 'package:wecare/pages/home_page.dart';
import 'package:wecare/pages/login.dart';
import 'package:wecare/themes/colors.dart';
import 'package:wecare/themes/theme_provider.dart';
// import 'package:your_project_name/login.dart'; // If you have a login page to go back to

// A reusable widget that defines the content of the application's side drawer.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme's brightness to apply theme-aware colors.

    return Drawer(
      // The background color of the drawer itself
      backgroundColor: AppColors.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero, // Remove default ListView padding for header
        children: <Widget>[
          // Drawer Header with User Info or App Logo
          UserAccountsDrawerHeader(
            accountName: Text(
              'John Doe', // Replace with dynamic user name
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textColor, // Text color adapts
              ),
            ),
            accountEmail: Text(
              'john.doe@example.com', // Replace with dynamic user email
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textColor.withValues(), // Text color adapts
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.cardBackground, // Circle background adapts
              child: Icon(
                Icons.person,
                color: AppColors.darkGreen, // Icon color adapts
                size: 50,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen, // Header background adapts
              image: DecorationImage(
                image: NetworkImage(
                  'https://placehold.co/600x200/5E35B1/FFFFFF?text=Background', // Placeholder image (consider local assets)
                ),
                fit: BoxFit.cover,
                // Apply a color filter to the image to make it less prominent
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(), // Darkens the image slightly
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Drawer Items (List Tiles for navigation)
          ListTile(
            leading: Icon(Icons.home, color: AppColors.textColor),
            title: Text(
              'Home',
              style: TextStyle(color: AppColors.textColor),
            ),
            onTap: () {
              // Close the drawer
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(themeProvider: ThemeProvider(),))
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: AppColors.textColor),
            title: Text(
              'Dashboard',
              style: TextStyle(color: AppColors.textColor),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage(themeProvider: ThemeProvider()))
              );
              
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.textColor),
            title: Text(
              'Settings',
              style: TextStyle(color: AppColors.textColor),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Settings...')),
              );
              // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          const Divider(), // A visual divider

          ListTile(
            leading: Icon(Icons.info, color: AppColors.textColor),
            title: Text(
              'About Us',
              style: TextStyle(color: AppColors.textColor),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to About Us...')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail, color: AppColors.textColor),
            title: Text(
              'Contact',
              style: TextStyle(color: AppColors.textColor),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Contact...')),
              );
            },
          ),
          // Optional: Logout button in drawer
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent), // Red accent for logout
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              // Implement actual logout logic here (clear session, navigate to login)
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(themeProvider: ThemeProvider()))
              );
            },
          ),
        ],
      ),
    );
  }
}
