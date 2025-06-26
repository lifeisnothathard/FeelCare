import 'package:flutter/material.dart';
import 'package:wecare/drawer/side_dashboard.dart';
import 'package:wecare/habit_data/new_habit.dart';
import 'package:wecare/themes/colors.dart';
import 'package:wecare/themes/theme_provider.dart';
import 'package:wecare/widgets/add_habit.dart';
import 'package:wecare/widgets/dashboard_tab.dart';

// The main DashboardPage, acting as a container for tabs and overall structure.
class DashboardPage extends StatefulWidget {
  final ThemeProvider themeProvider; // Receive ThemeProvider instance

  const DashboardPage({super.key, required this.themeProvider});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void _showAddEntryDialog(BuildContext context) {
    final Brightness _ = Theme.of(context).brightness;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEntryDialog(
          habitName: "Read a book", // Example: Pass actual habit name
          dayNumber: "Day 8",       // Example: Pass actual day
          icon: Icons.book,         // Example: Pass actual habit icon
          iconColor: AppColors.darkGreen, // Pass theme-aware color
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme's brightness. This will update when the theme changes.
    final Brightness currentBrightness = Theme.of(context).brightness;

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor, // Use theme-aware background
        appBar: AppBar(
          // AppBar colors are now managed by ThemeData in main.dart, so we don't set them here.
          // The title's text style also comes from AppBarTheme.
          title: const Text('Flux'),
          actions: [
            // Theme Toggle icon
            IconButton(
              icon: Icon(
                currentBrightness == Brightness.light ? Icons.dark_mode : Icons.light_mode,
                // Icon color is automatically set by AppBarTheme.foregroundColor
              ),
              onPressed: widget.themeProvider.toggleTheme, // Call toggleTheme from provider
              tooltip: 'Toggle Theme',
            )
          ],
          // TabBar placed at the bottom of the AppBar for navigation
          bottom: PreferredSize( // Removed 'const' keyword here
            preferredSize: const Size.fromHeight(kToolbarHeight), // Standard height for tabs
            child: Align(
              alignment: Alignment.centerLeft, // Align tabs to the left
              child: TabBar( // Removed 'const' keyword here
                isScrollable: true, // Allow tabs to scroll if many
                // TabBar theme properties are now set globally in ThemeData,
                // so no need to explicitly set indicatorColor, labelColor, etc. here.
                tabs: const [
                  Tab(text: 'Habits'),
                  Tab(text: 'Dashboard'),
                ],
              ),
            ),
          ),
        ),
        drawer: const AppDrawer(), // Assign your reusable AppDrawer widget here
        body: const TabBarView(
          children: [
            HabitsTab(), // Content for the 'Habits' tab
            DashboardTab(), // Content for the 'Dashboard' tab
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEntryDialog(context), // Call the dialog function
          // FAB background and foreground colors are from FloatingActionButtonThemeData
          child: const Icon(Icons.add, size: 30), // Plus icon
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
