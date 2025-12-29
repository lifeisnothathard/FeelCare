import 'package:local_auth/local_auth.dart';
import 'package:shake/shake.dart';

class HardwareService {
  final LocalAuthentication auth = LocalAuthentication();

  // Biometrics (Mobile only)
  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(localizedReason: 'Please authenticate to open FeelCare');
    } catch (e) {
      return false;
    }
  }

  // Shake Detection
  void initShake(Function onShake) {
    ShakeDetector.autoStart(onPhoneShake: () => onShake());
  }
}