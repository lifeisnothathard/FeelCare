import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecare/pages/login.dart';
import 'package:wecare/themes/theme_provider.dart';

void main() {
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
      title: 'WeCare',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      home: LoginScreen(themeProvider: ThemeProvider(),),
    );
  }
}
