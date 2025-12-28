// lib/pages/login.dart
import 'package:flutter/material.dart';
import 'package:feelcare/pages/home_page.dart'; 
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feelcare/themes/colors.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb; // 1. ADD THIS IMPORT

class LoginScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const LoginScreen({super.key, required this.themeProvider});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabledByUser = false; 

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    
    // 2. ONLY check biometrics if NOT on Web to avoid the MissingPluginException
    if (!kIsWeb) {
      _checkBiometricsAndAutoTrigger();
    }
  }

  // --- Biometric Authentication Logic ---
  
  Future<void> _checkBiometricsAndAutoTrigger() async {
    // Extra safety: double check kIsWeb here
    if (kIsWeb) return;

    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      final prefs = await SharedPreferences.getInstance();
      final bool enabled = prefs.getBool('biometricEnabled') ?? false; 

      if (mounted) {
        setState(() {
          _isBiometricAvailable = canCheckBiometrics && isDeviceSupported;
          _isBiometricEnabledByUser = enabled; 
        });

        if (_isBiometricAvailable && _isBiometricEnabledByUser) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _authenticateWithBiometrics();
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (kIsWeb) return; // Prevent execution on Web

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your face or fingerprint to log in to FeelCare.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
          biometricOnly: true, 
        ),
      );

      if (authenticated) {
        _loginWithStoredCredentials();
      }
    } catch (e) {
      debugPrint('Biometric error: $e');
    }
  }

  Future<void> _loginWithStoredCredentials() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');

    if (storedEmail != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home'); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back! Logged in via Biometrics.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in manually once to enable biometrics.')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- Regular Login Logic ---

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
    if (!value) {
      await prefs.remove('email');
      await prefs.remove('biometricEnabled'); 
    } else {
      await prefs.setString('email', _emailController.text);
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthService>(context, listen: false).signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        await _saveRememberMe(_rememberMe);

        if (mounted) Navigator.pushReplacementNamed(context, '/home'); 
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.message}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, 
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: Icon(widget.themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.themeProvider.toggleTheme(!(widget.themeProvider.themeMode == ThemeMode.dark)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.favorite_rounded, size: 80, color: colorScheme.primary),
                const SizedBox(height: 16),
                Text('Welcome to FeelCare', style: textTheme.headlineMedium),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Invalid email' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                            _saveRememberMe(_rememberMe);
                          },
                        ),
                        const Text('Remember Me'),
                      ],
                    ),
                    TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading ? const CircularProgressIndicator() : const Text('Login'),
                  ),
                ),

                // 3. UI GUARD: Hide the biometric button entirely on Web
                if (!kIsWeb && _isBiometricAvailable && _isBiometricEnabledByUser) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use Biometrics'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                ],

                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
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