import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _pinKey = 'app_pin_hash';
  static const String _biometricsEnabledKey = 'app_biometrics_enabled';

  // --- PIN Management ---

  Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin == pin;
  }

  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _biometricsEnabledKey);
  }

  // --- Biometrics Management ---

  Future<bool> isBiometricsEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricsEnabledKey);
    return enabled == 'true';
  }

  Future<void> setBiometricsEnabled(bool value) async {
    await _secureStorage.write(key: _biometricsEnabledKey, value: value.toString());
  }

  Future<bool> canUseBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // fallback to device PIN if biometrics fail
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
