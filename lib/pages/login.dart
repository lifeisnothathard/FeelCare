// lib/pages/login.dart
import 'package:flutter/material.dart';
import 'package:feelcare/pages/home_page.dart'; // Ensure correct import
import 'package:feelcare/themes/theme_provider.dart';
import 'package:feelcare/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:feelcare/themes/colors.dart'; // Import AppColors for direct access if needed, but prefer theme.of(context)

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

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadRememberMe();
  }

  // --- Biometric Authentication Logic (kept as is, but will use theme colors for UI feedback) ---
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (mounted) {
      setState(() {
        _isBiometricAvailable = canCheckBiometrics;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint or face to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // Authenticated with biometrics, now log in using stored credentials
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
    final storedPassword = prefs.getString('password'); // **WARNING: Storing passwords directly is insecure.**

    if (storedEmail != null && storedPassword != null) {
      try {
        await Provider.of<AuthService>(context, listen: false).signInWithEmail(
          storedEmail,
          storedPassword,
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/home'); // CHANGED: Navigate to /home
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.message}', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No stored credentials found.', style: TextStyle(color: Theme.of(context).colorScheme.onError))),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        // Note: We typically don't load password here for security reasons.
        // Biometric login would rely on a token or Firebase persistence.
      }
    });
  }

  Future<void> _saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', value);
    if (!value) {
      await prefs.remove('email');
      await prefs.remove('password'); // Remove if not remembering
    } else {
      await prefs.setString('email', _emailController.text);
      // await prefs.setString('password', _passwordController.text); // Again, be cautious with this.
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
        // Save remember me preference
        await _saveRememberMe(_rememberMe);

        if (mounted) Navigator.pushReplacementNamed(context, '/home'); // CHANGED: Navigate to /home
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

  // Inside _LoginScreenState class
  void _resetPassword() async {
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

  // >>> KOD _socialLogin YANG TELAH DIUBAH <<<
  void _socialLogin(String type) async {
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
        userCredential = null; // Pastikan userCredential adalah null jika tidak disokong
      }


      if (userCredential != null && userCredential.user != null) {
        // Successfully logged in with social provider
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as ${userCredential.user!.displayName ?? userCredential.user!.email}')),
          );
          // Navigate to home page or dashboard
          Navigator.pushReplacementNamed(context, '/home'); // CHANGED: Navigate to /home
        }
      } else {
        // User cancelled or no credential returned
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
      backgroundColor: colorScheme.surface, // Use theme background color
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
                  Icons.favorite_border, // Example: a heart or a calming leaf icon
                  size: 100,
                  color: colorScheme.primary, // Use primary color for the icon
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to FeelCare',
                  style: textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface), // Use theme text style
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Sign in to track your habits and emotions!',
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)), // Use theme text style
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
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface), // Text color in input
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
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface), // Text color in input
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
                      backgroundColor: _isLoading ? colorScheme.primary.withOpacity(0.5) : colorScheme.primary, // Button color
                      foregroundColor: colorScheme.onPrimary, // Text color
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
                if (_isBiometricAvailable) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _authenticateWithBiometrics,
                      icon: Icon(Icons.fingerprint, color: colorScheme.primary),
                      label: Text('Login with Biometrics', style: textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary, width: 2), // Border color
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
                    // BUTANG GOOGLE SUDAH DIBUANG
                    // IconButton(
                    //   icon: Icon(Icons.g_mobiledata, size: 40, color: colorScheme.primary),
                    //   onPressed: () => _socialLogin('google'),
                    //   tooltip: 'Login with Google',
                    // ),
                    // const SizedBox(width: 20), // Boleh buang ini jika tiada butang Google

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
