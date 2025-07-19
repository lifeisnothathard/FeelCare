// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Assuming you use FirebaseAuth for user stream
import 'package:feelcare/drawer/side_dashboard.dart'; // AppDrawer
import 'package:feelcare/themes/theme_provider.dart';

// Import your tab pages
import 'package:feelcare/pages/habits_tab.dart';
import 'package:feelcare/pages/dashboard_tab.dart';
import 'package:feelcare/widgets/add_habit_mood_dialog.dart'; // Correct dialog import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // User can be accessed if provided in main.dart's MultiProvider
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 2, // We have two tabs: Habits and Dashboard
      child: Builder( // Use Builder to access the TabController
        builder: (BuildContext defaultTabContext) {
          // Access the TabController provided by DefaultTabController
          final TabController tabController = DefaultTabController.of(defaultTabContext);

          return Scaffold(
            appBar: AppBar(
              title: const Text('FeelCare'),
              centerTitle: false,
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Habits'),
                  Tab(text: 'Dashboard'),
                ],
              ),
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
            drawer: AppDrawer(themeProvider: themeProvider),
            body: const TabBarView(
              children: [
                HabitsTab(), // Your Habits tab content
                DashboardTab(), // Your Dashboard tab content
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Determine the current tab's index
                final int currentTabIndex = tabController.index;
                // Based on the index, decide the initial type for the dialog
                final String initialType = currentTabIndex == 0 ? 'habit' : 'mood';

                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    // Pass the determined initial type to the dialog
                    return AddHabitMoodDialog(initialEntryType: initialType);
                  },
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
            ),
          );
        },
      ),
    );
  }
}