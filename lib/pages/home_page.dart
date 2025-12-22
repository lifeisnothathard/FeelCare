import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:feelcare/drawer/side_dashboard.dart'; 
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/habit_mood_service.dart'; // To get streak data
import 'package:feelcare/pages/habits_tab.dart';
import 'package:feelcare/pages/dashboard_tab.dart';
import 'package:feelcare/widgets/add_habit_mood_dialog.dart';
import 'package:sensors_plus/sensors_plus.dart'; // For Motion Sensor
import 'package:table_calendar/table_calendar.dart'; // For Calendar

// Compatibility extension: provide a currentStreak getter when the service doesn't define it.
// This lets the UI safely read a streak value (returns null if not available).
extension HabitMoodServiceCurrentStreak on HabitMoodService {
  int? get currentStreak {
    try {
      final dynamic d = this;
      return d.currentStreak as int?;
    } catch (_) {
      return null;
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Motion Sensor variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  static const double shakeThreshold = 15.0; // Sensitivity of the shake
  DateTime _lastShakeTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 1. MOTION SENSOR: Listen for shakes to open the "Add" dialog quickly
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() > shakeThreshold || event.y.abs() > shakeThreshold) {
        // Prevent multiple triggers in a split second
        if (DateTime.now().difference(_lastShakeTime) > const Duration(seconds: 2)) {
          _lastShakeTime = DateTime.now();
          _triggerShakeAction();
        }
      }
    });
  }

  @override
  void dispose() {
    // Stop listening when the page is destroyed to save battery
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _triggerShakeAction() {
    // Provide haptic feedback (optional) and open the dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shake detected! Opening Quick Add...'), duration: Duration(seconds: 1)),
    );
    _showAddDialog(initialType: 'habit');
  }

  void _showAddDialog({required String initialType}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddHabitMoodDialog(initialEntryType: initialType);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // 2. STREAK: Watch the HabitMoodService for the current streak count
    final habitService = context.watch<HabitMoodService>();
    final streakCount = habitService.currentStreak ?? 0;

    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (BuildContext defaultTabContext) {
          final TabController tabController = DefaultTabController.of(defaultTabContext);

          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  const Text('FeelCare'),
                  const SizedBox(width: 8),
                  // STREAK DISPLAY: Shows a flame icon and the count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                        Text(
                          '$streakCount',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                // BIOMETRIC SHORTCUT: Quick access to biometric settings
                IconButton(
                  icon: const Icon(Icons.fingerprint),
                  onPressed: () => Navigator.pushNamed(context, '/biometric_settings'),
                ),
                IconButton(
                  icon: Icon(themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode),
                  onPressed: () => themeProvider.toggleTheme(
                    !(themeProvider.themeMode == ThemeMode.dark),
                  ),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Habits'),
                  Tab(text: 'Dashboard'),
                ],
              ),
            ),
            drawer: AppDrawer(themeProvider: themeProvider),
            body: Column(
              children: [
                // 3. CALENDAR: Added a sleek weekly calendar at the top
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.week, // Single row calendar
                  headerVisible: false, // Keep it minimal
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    children: [
                      HabitsTab(),
                      DashboardTab(),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final String initialType = tabController.index == 0 ? 'habit' : 'mood';
                _showAddDialog(initialType: initialType);
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