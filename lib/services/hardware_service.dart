import 'package:local_auth/local_auth.dart';
import 'package:shake/shake.dart';

class HardwareService {
  final LocalAuthentication auth = LocalAuthentication();

  // 1. Biometrics
  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to open FeelCare',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // 2. Shake Detection - Guna PhoneShakeCallback terus
  void initShake(PhoneShakeCallback onShake) {
    ShakeDetector.autoStart(
      onPhoneShake: onShake,
    );
  }
}