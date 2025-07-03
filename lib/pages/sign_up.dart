// lib/pages/sign_up.dart
import 'package:feelcare/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:feelcare/themes/colors.dart'; // Import AppColors

class SignUpScreen extends StatefulWidget {
  final ThemeProvider themeProvider; // Add themeProvider
  const SignUpScreen({super.key, required this.themeProvider});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Added for password visibility

  Future<void> _setDisplayNameFromEmail(User user) async {
    try {
      final emailPrefix = user.email?.split('@').first ?? 'User';
      developer.log('Attempting to set display name to: $emailPrefix', name: 'NameUpdate');

      await user.updateDisplayName(emailPrefix);
      await user.reload();

      final updatedUser = FirebaseAuth.instance.currentUser;
      developer.log('Name update successful. New name: ${updatedUser?.displayName}', name: 'NameUpdate');
    } catch (e) {
      developer.log('Failed to set display name: $e', name: 'NameUpdateError');
      rethrow;
    }
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await Provider.of<AuthService>(context, listen: false).signUpWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (userCredential.user != null) {
        await _setDisplayNameFromEmail(userCredential.user!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up successful! Welcome, ${userCredential.user!.displayName ?? userCredential.user!.email}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
          );
          Navigator.pushReplacementNamed(context, '/dashboard'); // Navigate to dashboard after successful signup
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.message}', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!value.contains('@')) return 'Please enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Sign Up', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: colorScheme.onPrimary,
            ),
            onPressed: () => widget.themeProvider.toggleTheme(
              !(widget.themeProvider.themeMode == ThemeMode.dark),
            ),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_alt_1, // A welcoming sign-up icon
                  size: 100,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Your FeelCare Account',
                  style: textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Join us to start your habit tracking journey!',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Create a strong password",
                    prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: colorScheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? colorScheme.primary.withOpacity(0.5) : colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : Text("Sign Up", style: textTheme.titleMedium),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('Login here', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}