// lib/core/dashboard.dart
import 'package:feelcare/tabs/habits_tab.dart'; // This will become HabitsTab
import 'package:flutter/material.dart';
import 'package:feelcare/drawer/side_dashboard.dart'; // Ensure this import is correct
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/widgets/add_entry_dialog.dart';
import 'package:feelcare/widgets/dashboard_tab.dart';
import 'package:feelcare/themes/colors.dart'; // Import the consolidated AppColors

class DashboardPage extends StatefulWidget {
  final ThemeProvider themeProvider;
  const DashboardPage({super.key, required this.themeProvider});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    // Listen for auth state changes to update the UI if the user logs in/out
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  void _showAddEntryDialog(BuildContext context) {
    // This dialog will be enhanced later to include emotion and motivation inputs.
    // For now, ensure it respects the theme.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEntryDialog(
          habitName: "Example Habit", // Replace with actual habit later
          dayNumber: "Day 1", // Replace with actual day later
          icon: Icons.run_circle, // Example icon
          iconColor: Theme.of(context).colorScheme.primary, // Use theme primary color
        );
      },
    );
  }

   @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final displayEmail = user?.email ?? 'Loading...';
    final displayName = user?.displayName ?? 'Loading...';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FeelCare'),
          actions: [
            IconButton(
              icon: Icon(
                widget.themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              ),
              onPressed: () {
                // PERHATIAN: Perbetulkan cara toggleTheme dipanggil
                widget.themeProvider.toggleTheme(widget.themeProvider.themeMode != ThemeMode.dark);
              },
              tooltip: 'Toggle Theme',
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Habits'),
                  Tab(text: 'Dashboard'),
                ],
              ),
            ),
          ),
        ),
        // ***** HANTAR THEMEPROVIDER SAHAJA KE APPDRAWER *****
        drawer: AppDrawer(
          themeProvider: widget.themeProvider, // <<< HANTAR THEMEPROVIDER SAHAJA
        ),
        body: TabBarView(
          children: [
            HabitsTab(),
            DashboardTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEntryDialog(context),
          child: const Icon(Icons.add, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
