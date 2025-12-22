import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/habit_mood_service.dart';
import 'package:feelcare/pages/habits_tab.dart';
import 'package:feelcare/pages/dashboard_tab.dart';
import 'package:feelcare/widgets/add_habit_mood_dialog.dart';
import 'package:feelcare/drawer/side_dashboard.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this

// Compatibility extension
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
  // Connectivity & Motion Variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;
  static const double shakeThreshold = 15.0;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // 1. CONNECTIVITY: Watch for internet changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        _isOffline = results.contains(ConnectivityResult.none);
      });
    });

    // 2. MOTION SENSOR: Shake to Add
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x.abs() > shakeThreshold || event.y.abs() > shakeThreshold) {
        if (DateTime.now().difference(_lastShakeTime) > const Duration(seconds: 2)) {
          _lastShakeTime = DateTime.now();
          _triggerShakeAction();
        }
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _triggerShakeAction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✨ Shake detected! ✨'), duration: Duration(seconds: 1)),
    );
    _showAddDialog(initialType: 'habit');
  }

  void _showAddDialog({required String initialType}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AddHabitMoodDialog(initialEntryType: initialType),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                  // HEART LOTTIE: Pulsing next to the name
                  Lottie.asset('assets/lottie/heart.json', width: 30, height: 30),
                  const SizedBox(width: 5),
                  const Text('FeelCare'),
                  const SizedBox(width: 8),
                  
                  // STREAK BADGE with STAR LOTTIE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Lottie.asset('assets/lottie/star.json', width: 25, height: 25),
                        Text(
                          '$streakCount',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fingerprint),
                  onPressed: () => Navigator.pushNamed(context, '/biometric_settings'),
                ),
                IconButton(
                  icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => themeProvider.toggleTheme(!(themeProvider.themeMode == ThemeMode.dark)),
                ),
              ],
              bottom: const TabBar(
                tabs: [Tab(text: 'Habits'), Tab(text: 'Dashboard')],
              ),
            ),
            drawer: AppDrawer(themeProvider: themeProvider),
            body: Column(
              children: [
                // OFFLINE BANNER with LOADING LOTTIE
                if (_isOffline)
                  Container(
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/lottie/loading.json', width: 20, height: 20),
                        const SizedBox(width: 10),
                        const Text("Offline Mode - Syncing Paused", 
                          style: TextStyle(color: Colors.brown, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.week,
                  headerVisible: false,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
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