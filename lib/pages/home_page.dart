// home_page.dart snippet
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feelcare/drawer/side_dashboard.dart'; // This is the import for AppDrawer
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user?.displayName ?? ''}'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(
              !(themeProvider.themeMode == ThemeMode.dark),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(themeProvider: themeProvider), // <--- THIS LINE
      body: Center(
        child: Column(
          // ... rest of your body
        ),
      ),
    );
  }
}