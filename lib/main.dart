import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecare/pages/login.dart';
import 'package:wecare/themes/theme_provider.dart';

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