// lib/main.dart
import 'package:feelcare/drawer/dashboard.dart';
import 'package:feelcare/pages/home_page.dart';
import 'package:feelcare/pages/login.dart';
import 'package:feelcare/pages/sign_up.dart';
import 'package:feelcare/services/habit_mood_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:feelcare/pages/splash_screen.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/auth_service.dart';
import 'package:feelcare/firebase_options.dart';
import 'package:feelcare/themes/colors.dart';
import 'package:feelcare/pages/profile_screen.dart';
import 'package:feelcare/pages/biometric_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

// ⭐ ADD THIS
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }
}

class AppColors {
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color secondaryGreen = Color(0xFF66BB6A);
  static const Color darkPrimaryGreen = Color(0xFF2E7031);
  static const Color darkSecondaryGreen = Color(0xFF388E3C);

  static Color getAdaptiveBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.grey[900]!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ ADD THIS FOR LOCAL NOTIFICATION TIMEZONE
  tz.initializeTimeZones();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⭐ ADD THIS: INITIALIZE ALL NOTIFICATIONS
  await NotificationService.init();

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
          catchError: (_, __) => null,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<HabitMoodService>(
          create: (_) => HabitMoodService(),
        ),
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

      // LIGHT THEME
      theme: ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryGreen,
          secondary: AppColors.secondaryGreen,
          // Add other colors as needed for your light theme
          surface: Colors.white, // Example surface color
          onSurface: Colors.black87, // Example text color on background
        ),
        // You can also define text themes, button themes, etc. here
        // textTheme: lightTextTheme, // If you have a custom lightTextTheme
      ),
      // Define dark theme using ThemeData.dark() and custom colors
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimaryGreen,
          secondary: AppColors.darkSecondaryGreen,
          // Add other colors as needed for your dark theme
          surface: Color(0xFF121212), // Example dark surface color
          onSurface: Colors.white70, // Example text color on dark background
        ),
        // textTheme: darkTextTheme, // If you have a custom darkTextTheme
      ),
      themeMode: themeProvider.themeMode, // Use the theme mode from ThemeProvider
      initialRoute: '/splash', // Start with the splash screen
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => LoginScreen(themeProvider: themeProvider),
        '/signup': (_) => SignUpScreen(themeProvider: themeProvider),
        '/home': (_) => const HomePage(),
        '/dashboard': (_) => DashboardPage(themeProvider: themeProvider),
        '/profile': (_) => ProfileScreen(themeProvider: themeProvider),
        '/biometric_settings': (_) => const BiometricSettingsScreen(),
      },
    );
  }
}
