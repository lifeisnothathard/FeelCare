// lib/core/dashboard/dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/themes/colors.dart'; // <<< CORRECT IMPORT FOR APPCOLORS
import 'package:feelcare/widgets/dashboard_tab.dart';
import 'package:feelcare/habit_data/new_habit.dart'; // This is your HabitsTab, ensure path is correct
import 'package:feelcare/drawer/side_dashboard.dart'; // AppDrawer

// New Imports for Habit/Mood Tracking
import 'package:feelcare/widgets/add_habit_mood_dialog.dart'; // <<< NEW DIALOG IMPORT
import 'package:feelcare/services/habit_mood_service.dart'; // <<< NEW SERVICE IMPORT

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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  // Update this method to show the new dialog
  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddHabitMoodDialog(); // <<< Use the new dialog (no longer AddEntryDialog)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // These are no longer passed to AppDrawer, but can be kept for other uses if needed
    // String displayName = _currentUser?.displayName ?? 'User';
    // String displayEmail = _currentUser?.email ?? 'No email';

    return DefaultTabController(
      length: 2, // You have 'Habits' and 'Dashboard' tabs
      child: Scaffold(
        backgroundColor: AppColors.getAdaptiveBackgroundColor(context), // <<< Use adaptive background color
        appBar: AppBar(
          title: const Text('FeelCare'),
          backgroundColor: Theme.of(context).colorScheme.primary, // Use theme's primary color
          actions: [
            IconButton(
              icon: Icon(
                widget.themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              onPressed: () {
                // Correct way to toggle theme
                widget.themeProvider.toggleTheme(
                    widget.themeProvider.themeMode == ThemeMode.light); // <<< CORRECTED TOGGLE LOGIC
              },
              tooltip: 'Toggle Theme',
            )
          ],
          // --- MODIFICATION STARTS HERE ---
          bottom: const TabBar( // DIRECTLY USE TABBAR
            isScrollable: true,
            indicatorColor: Colors.yellow, // Indikator akan berwarna kuning terang
            indicatorWeight: 5.0,        // Buat indikator lebih tebal
            labelColor: Colors.white,    // Warna teks untuk tab yang dipilih
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: 'Habits'),
              Tab(text: 'Dashboard'),
            ],
          ),
          // --- MODIFICATION ENDS HERE ---
        ),
        // ***** HANTAR THEMEPROVIDER SAHAJA KE APPDRAWER *****
        drawer: AppDrawer(
          // REMOVED userEmail and userName parameters as AppDrawer no longer needs them
          themeProvider: widget.themeProvider, // <<< HANTAR THEMEPROVIDER SAHAJA
        ),
        body: Provider<HabitMoodService>( // <<< WRAP WITH PROVIDER HERE
          create: (_) => HabitMoodService(),
          child: const TabBarView(
            children: [
              HabitsTab(),
              DashboardTab(),
            ],
          ),
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