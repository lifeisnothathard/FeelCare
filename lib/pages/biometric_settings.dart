// TODO Implement this library.// lib/pages/biometric_settings.dart

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  String _biometricType = 'Biometric';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadBiometricSetting();
  }

  Future<void> _checkBiometrics() async {
    bool canCheck = false;
    List<BiometricType> availableBiometrics = [];

    try {
      canCheck = await auth.canCheckBiometrics;
      if (canCheck) {
        availableBiometrics = await auth.getAvailableBiometrics();
        if (availableBiometrics.contains(BiometricType.face)) {
          _biometricType = 'Face ID/Face Authentication';
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          _biometricType = 'Fingerprint/Touch ID';
        } else {
          _biometricType = 'Biometric';
        }
      }
    } catch (e) {
      print("Error checking biometrics: $e");
      canCheck = false;
    }

    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheck;
      });
    }
  }

  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // Use a key to store the setting. Change this key if needed.
        _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool newValue) async {
    // If the user is trying to enable biometrics, check if they are authorized first.
    if (newValue) {
      bool authenticated = false;
      try {
        authenticated = await auth.authenticate(
          localizedReason: 'Verify your identity to enable $_biometricType login',
          options: const AuthenticationOptions(
            stickyAuth: true,
          ),
        );
      } catch (e) {
        print("Authentication error: $e");
      }

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isBiometricEnabled', true);
        if (mounted) {
          setState(() {
            _isBiometricEnabled = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_biometricType login enabled successfully!')),
          );
        }
      } else {
        // Authentication failed or was cancelled, keep the switch off
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Authentication failed or cancelled.')),
          );
        }
      }
    } else {
      // Disabling biometrics
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isBiometricEnabled', false);
      if (mounted) {
        setState(() {
          _isBiometricEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_biometricType login disabled.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Settings'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secure Login',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),

                  if (_canCheckBiometrics)
                    // This is the TOGGLE SWITCH!
                    Card(
                      elevation: 2,
                      child: SwitchListTile(
                        title: Text('Enable $_biometricType Login'),
                        subtitle: Text(
                            'Use your device\'s $_biometricType for faster login.'),
                        value: _isBiometricEnabled,
                        onChanged: _toggleBiometric,
                        secondary: Icon(Icons.fingerprint, color: colorScheme.primary),
                      ),
                    )
                  else
                    // Message if biometrics are not available
                    Card(
                      color: Colors.yellow[100],
                      child: const ListTile(
                        leading: Icon(Icons.warning_amber, color: Colors.amber),
                        title: Text('Biometrics Not Available'),
                        subtitle: Text(
                            'Your device does not support biometric authentication, or it is not set up in your device settings.'),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Note: This setting saves to your local device only and must be enabled on each device you use.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}