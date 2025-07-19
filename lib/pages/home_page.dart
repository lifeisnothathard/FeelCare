// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feelcare/drawer/side_dashboard.dart'; // AppDrawer
import 'package:feelcare/themes/theme_provider.dart';

// Import your tab pages
import 'package:feelcare/pages/habits_tab.dart';
import 'package:feelcare/pages/dashboard_tab.dart'; // Assuming this path is correct now

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 2, // We have two tabs: Habits and Dashboard
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FeelCare'), // Consistent title as per screenshot
          centerTitle: false, // Align title to the left
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Habits'),
              Tab(text: 'Dashboard'),
            ],
          ),
          actions: [
            // Dark/Light Mode Toggle Button on the right of AppBar
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
        drawer: AppDrawer(themeProvider: themeProvider),
        body: TabBarView(
          children: [
            HabitsTab(), // Your Habits tab content
            DashboardTab(), // Your Dashboard tab content
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Handle the action for the plus button, e.g., navigate to add new habit
            print('Add new item button pressed'); // For debugging
            // Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewHabitScreen())); // Example
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
