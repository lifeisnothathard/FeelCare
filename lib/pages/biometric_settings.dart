import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});
  @override
  State<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheck = await auth.canCheckBiometrics;
    setState(() => _canCheckBiometrics = canCheck);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Settings"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Secure Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (!_canCheckBiometrics)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber),
                    SizedBox(width: 10),
                    Expanded(child: Text("Biometrics Not Available on this device.")),
                  ],
                ),
              )
            else
              const ListTile(
                leading: Icon(Icons.fingerprint),
                title: Text("Enable Biometric Authentication"),
                trailing: Switch(value: true, onChanged: null),
              ),
          ],
        ),
      ),
    );
  }
}