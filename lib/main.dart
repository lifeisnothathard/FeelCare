import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feelcare/pages/login.dart';
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/pages/sign_up.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Import your home page widget here (Gantikan dengan path fail home page awak yang betul):
import 'package:feelcare/core/dashboard.dart'; // Import DashboardPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
      title: 'FeelCare',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute: '/login', // Aplikasi bermula dari skrin login
      routes: {
        '/login': (context) => LoginScreen(themeProvider: ThemeProvider()),
        '/signup': (context) => SignUpScreen(),
        // ***** TAMBAH BARIS INI *****
        '/home': (context) => DashboardPage(themeProvider: themeProvider), // Gantikan DashboardPage() dengan widget home screen sebenar awak
      },
    );
  }
}