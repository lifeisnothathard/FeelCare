// lib/main.dart
import 'package:feelcare/drawer/dashboard.dart'; // Assuming this is DashboardPage
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
import 'package:feelcare/firebase_options.dart'; // Import firebase options
import 'package:feelcare/themes/colors.dart'; // Import our consolidated AppColors
// The following imports are redundant if themeProvider handles them,
// but keeping them if they define specific ThemeData objects.
// import 'package:feelcare/themes/light_mode.dart'; // Import light mode theme
// import 'package:feelcare/themes/dark_mode.dart'; // Import dark mode theme
import 'package:feelcare/pages/profile_screen.dart'; // Import ProfileScreen widget

// Define AppColors if not already defined elsewhere.
// If AppColors is already defined in 'package:feelcare/themes/colors.dart',
// this block can be removed to avoid duplication.
// Keeping it here for now as per your provided code.
class AppColors {
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color secondaryGreen = Color(0xFF66BB6A);
  static const Color darkPrimaryGreen = Color(0xFF2E7031);
  static const Color darkSecondaryGreen = Color(0xFF388E3C);

  // Add getAdaptiveBackgroundColor if it's part of AppColors
  static Color getAdaptiveBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white // Light mode background
        : Colors.grey[900]!; // Dark mode background
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Add this line
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  runApp(
    MultiProvider(
      providers: [
        // Provides the FirebaseAuth user stream for authentication state changes
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null, // Initial data before stream emits
          catchError: (_, err) => null, // Handle potential errors in the stream
        ),
        // Provides the ThemeProvider as a ChangeNotifierProvider
        // This allows widgets to listen for theme changes and rebuild
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        // Provides AuthService
        Provider<AuthService>(create: (_) => AuthService()),
        // IMPORTANT: Provide HabitMoodService as a ChangeNotifierProvider
        // since it now extends ChangeNotifier and uses notifyListeners().
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
    // Access the ThemeProvider from the widget tree
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Set to false for production
      title: 'FeelCare',
      // Define light theme using ThemeData.light() and custom colors
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
        '/home': (_) => const HomePage(), // HomePage is the main content with tabs
        // DashboardPage is imported from drawer/dashboard.dart,
        // ensure it's still needed as a separate route if HomePage handles tabs.
        // If HomePage is the primary dashboard, this route might be redundant.
        '/dashboard': (_) => DashboardPage(themeProvider: themeProvider),
        '/profile': (_) => ProfileScreen(themeProvider: themeProvider),
      },
    );
  }
}