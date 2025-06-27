// lib/main.dart
import 'package:feelcare/core/dashboard.dart';
import 'package:feelcare/pages/home_page.dart';
import 'package:feelcare/pages/login.dart';
import 'package:feelcare/pages/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:feelcare/pages/splash_screen.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/auth_service.dart';
import 'package:feelcare/firebase_options.dart'; // Import firebase options
import 'package:feelcare/themes/colors.dart'; // Import our consolidated AppColors
import 'package:feelcare/themes/light_mode.dart'; // Import light mode theme
import 'package:feelcare/themes/dark_mode.dart'; // Import dark mode theme
import 'package:feelcare/pages/profile_screen.dart'; // Import ProfileScreen widget
import 'package:feelcare/pages/dashboard_page.dart'; // Import DashboardPage widget

// Remove the local AppColors class definition as we now import it from themes/colors.dart
// class AppColors {
//   static const Color primaryGreen = Color(0xFF43A047);
//   static const Color secondaryGreen = Color(0xFF66BB6A);
//   static const Color darkPrimaryGreen = Color(0xFF2E7031);
//   static const Color darkSecondaryGreen = Color(0xFF388E3C);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use generated Firebase options
  );

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider.value(value: themeProvider),
        Provider(create: (_) => AuthService()),
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
      theme: lightMode, // Use the defined lightMode theme
      darkTheme: darkMode, // Use the defined darkMode theme
      themeMode: themeProvider.themeMode,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => LoginScreen(themeProvider: themeProvider),
        '/signup': (_) => SignUpScreen(themeProvider: themeProvider),
        '/home': (_) => const HomePage(),
        // Add DashboardPage to routes
        '/dashboard': (_) => DashboardPage(themeProvider: themeProvider),
        '/profile': (_) => ProfileScreen(themeProvider: themeProvider),
      },
    );
  }
}