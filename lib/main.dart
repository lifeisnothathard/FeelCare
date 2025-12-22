// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz; // Added for scheduling

// Relative imports
import 'drawer/dashboard.dart';
import 'pages/home_page.dart';
import 'pages/login.dart';
import 'pages/sign_up.dart';
import 'pages/splash_screen.dart';
import 'pages/profile_screen.dart';
import 'pages/biometric_settings.dart';
import 'themes/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/habit_mood_service.dart';
import 'firebase_options.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings = 
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(initializationSettings);
    
    // Request permissions for iOS/Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // NEW: Schedule a daily reminder for the user to check their habits
  static Future<void> scheduleDailyReminder() async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'FeelCare Reminder 🌿',
      'Time to check in on your habits and mood!',
      _nextInstanceOfTime(20, 0), // Sets reminder for 8:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

class AppColors {
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color secondaryGreen = Color(0xFF66BB6A);
  static const Color darkPrimaryGreen = Color(0xFF2E7031);
  static const Color darkSecondaryGreen = Color(0xFF388E3C);

  static Color getAdaptiveBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[900]!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize and schedule notifications
  await NotificationService.init();
  await NotificationService.scheduleDailyReminder();

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>(
          create: (_) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        Provider<AuthService>(create: (_) => AuthService()),
        // This service will now handle your "Streak" and "Calendar" data logic
        ChangeNotifierProvider<HabitMoodService>(create: (_) => HabitMoodService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FeelCare',
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryGreen,
          secondary: AppColors.secondaryGreen,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimaryGreen,
          secondary: AppColors.darkSecondaryGreen,
          surface: Color(0xFF121212),
          onSurface: Colors.white70,
        ),
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => LoginScreen(themeProvider: themeProvider),
        '/signup': (_) => SignUpScreen(themeProvider: themeProvider),
        '/home': (_) => const HomePage(), // This is where you add the Motion Sensor & Calendar
        '/dashboard': (_) => DashboardPage(themeProvider: themeProvider),
        '/profile': (_) => ProfileScreen(themeProvider: themeProvider),
        '/biometric_settings': (_) => const BiometricSettingsScreen(), // Biometric sensor setup here
      },
    );
  }
}