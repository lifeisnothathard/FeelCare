import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final email = TextEditingController(), pass = TextEditingController(), name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Lottie.asset('assets/lottie/loading refresh.json', height: 150),
              if (!isLogin) TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
              TextField(controller: pass, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (isLogin) await auth.login(email.text, pass.text);
                  else await auth.signUp(email.text, pass.text, name.text);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text(isLogin ? "Login" : "Register"),
              ),
              TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? "Create Account" : "Back to Login"))
            ],
          ),
        ),
      ),
    );
  }
}