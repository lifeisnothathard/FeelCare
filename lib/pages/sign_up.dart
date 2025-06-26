// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _signUp() async {
  final user = await AuthService().signUpWithEmail(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );

  if (user != null) {
    // Navigate to login screen after successful sign up
    Navigator.pushReplacementNamed(context, '/login');
    // Optionally clear fields
    _emailController.clear();
    _passwordController.clear();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sign up failed. Try again.")),
    );
   }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text("Sign Up"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
