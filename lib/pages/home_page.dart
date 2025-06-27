// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feelcare/drawer/side_dashboard.dart'; // Ensure this import is correct
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/auth_service.dart';
import 'package:feelcare/themes/colors.dart'; // Import AppColors

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String displayEmail = user?.email ?? 'No email';
    String displayName = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: colorScheme.surface, // Use theme surface for background
      appBar: AppBar(
        title: Text(
          'Welcome ${user?.displayName ?? ''}',
          style: textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: colorScheme.onPrimary,
            ),
            onPressed: () => themeProvider.toggleTheme(
              !(themeProvider.themeMode == ThemeMode.dark),
            ),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      // Pass user info to AppDrawer
      drawer: AppDrawer(
        themeProvider: themeProvider,
        userEmail: displayEmail,
        userName: displayName,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.photoURL != null)
              CircleAvatar(
                radius: 60, // Slightly larger avatar
                backgroundImage: NetworkImage(user!.photoURL!),
                backgroundColor: colorScheme.secondary, // Fallback background
              )
            else
              CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.secondary,
                child: Icon(Icons.person, size: 60, color: colorScheme.onSecondary), // Default person icon
              ),
            const SizedBox(height: 20),
            Text(
              'Logged in as:',
              style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            Text(
              user?.email ?? 'No email',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
            ),
            if (user?.displayName != null && user!.displayName!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Display Name: ${user.displayName}',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<AuthService>(context, listen: false).signOut();
                  // Navigate to login screen after sign out
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $e')),
                  );
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final ThemeProvider themeProvider;
  final String userEmail;
  final String userName;

  const AppDrawer({
    super.key,
    required this.themeProvider,
    required this.userEmail,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: colorScheme.secondary,
              child: Icon(Icons.person, size: 50, color: colorScheme.onSecondary),
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: colorScheme.onSurface),
            title: Text('Home', style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: colorScheme.onSurface),
            title: Text('Settings', style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          Spacer(),
          SwitchListTile(
            title: Text('Dark Mode', style: TextStyle(color: colorScheme.onSurface)),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: Icon(
              themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}