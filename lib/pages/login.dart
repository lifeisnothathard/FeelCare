// lib/pages/login.dart
import 'package:flutter/material.dart';
import 'package:feelcare/pages/home_page.dart'; // Ensure correct import
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feelcare/themes/colors.dart'; 

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
  // NEW: Track if the user has enabled biometrics via settings
  bool _isBiometricEnabledByUser = false; 

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
    _checkBiometrics(); 
  }

  // --- Biometric Authentication Logic ---
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final prefs = await SharedPreferences.getInstance();
    // Load the user's preference for biometric login
    final bool enabled = prefs.getBool('biometricEnabled') ?? false; 

    if (mounted) {
      setState(() {
        _isBiometricAvailable = canCheckBiometrics;
        _isBiometricEnabledByUser = enabled; // Set user preference
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your face to log in, or use your fingerprint.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        _loginWithStoredCredentials();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Biometric authentication failed or canceled.', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric authentication error: $e', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
        );
      }
    }
  }

  Future<void> _loginWithStoredCredentials() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    // Note: Since we stopped storing the password, this function now relies on 
    // the user's Firebase session persistence or a stored token 
    // (which requires advanced setup not covered here). 
    // For this demonstration, we'll assume Firebase persistence handles the login 
    // once biometrics are confirmed. For true secure login, a token 
    // should be retrieved and stored, not the password.

    if (storedEmail != null) {
      // In a real app, you would use biometrics to decrypt a security token
      // and use the token to sign into Firebase. 
      // Since we don't have that token logic, we rely on the authentication 
      // context already being established via Firebase's persistent user session.
      
      // Navigate directly if biometric is successful and email is known
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home'); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in successfully via Biometrics.')),
        );
      }
      
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No stored credentials found. Please log in manually.', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

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
      // REMOVED INSECURE PASSWORD STORAGE
      // await prefs.remove('password'); 
      await prefs.remove('biometricEnabled'); 
    } else {
      await prefs.setString('email', _emailController.text);
      // DO NOT STORE PASSWORD
      // await prefs.setString('password', _passwordController.text); 
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<AuthService>(context, listen: false).signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        // Save remember me preference (and email)
        await _saveRememberMe(_rememberMe);

        // Update biometric check to see if the biometric button should now show
        _checkBiometrics(); 

        if (mounted) Navigator.pushReplacementNamed(context, '/home'); 
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.message}', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
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
  }

  void _resetPassword() async {
    // ... (reset password function remains unchanged) ...
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset password.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthService>(context, listen: false).resetPassword(_emailController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending password reset email: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _socialLogin(String type) async {
    // ... (social login function remains unchanged) ...
    setState(() {
      _isLoading = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      UserCredential? userCredential;

      // HANYA ada Facebook Social Login sahaja
      if (type == 'facebook') {
        userCredential = await authService.signInWithFacebook();
      } else {
        // Jika type bukan 'facebook', maklumkan pengguna bahawa kaedah lain tidak disokong
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Social login type "$type" is not supported (Google has been removed).')),
          );
        }
        userCredential = null; 
      }

      if (userCredential != null && userCredential.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as ${userCredential.user!.displayName ?? userCredential.user!.email}')),
          );
          Navigator.pushReplacementNamed(context, '/home'); 
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Social login cancelled or failed.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during social login: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: Text('Login', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary)),
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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Logo/Icon for "Cute and Calming" feel
                Icon(
                  Icons.favorite_border, 
                  size: 100,
                  color: colorScheme.primary, 
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to FeelCare',
                  style: textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface), 
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Sign in to track your habits and emotions!',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)), 
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
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
                    labelText: 'Password',
                    hintText: 'Enter your password',
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
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                            _saveRememberMe(_rememberMe);
                          },
                          activeColor: colorScheme.primary,
                        ),
                        Text('Remember Me', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.8))),
                      ],
                    ),
                    TextButton(
                      onPressed: _resetPassword,
                      child: Text('Forgot Password?', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                        : Text('Login', style: textTheme.titleMedium),
                  ),
                ),
                const SizedBox(height: 20),

                // Biometric Login Button
                // ONLY SHOW IF AVAILABLE ON DEVICE AND ENABLED BY USER
                if (_isBiometricAvailable && _isBiometricEnabledByUser) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _authenticateWithBiometrics,
                      icon: Icon(Icons.face_unlock_outlined, color: colorScheme.primary),
                      label: Text('Login with Face ID / Biometrics', style: textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary, width: 2), 
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                Text('Or login with', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.facebook, size: 40, color: colorScheme.primary),
                      onPressed: () => _socialLogin('facebook'),
                      tooltip: 'Login with Facebook',
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Register button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text('Sign Up', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
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