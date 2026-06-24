import 'dart:convert';
import 'package:crypto/crypto.dart';
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


  String _hashPin(String pin) {
    final bytes = utf8.encode("${pin}purenote_salt_2026");
    return sha256.convert(bytes).toString();
  }

  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: _hashPin(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    if (storedPin != null && storedPin.length == 4) {
      if (storedPin == pin) {
        await setPin(pin); // upgrade to hash
        return true;
      }
      return false;
    }
    return storedPin == _hashPin(pin);
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
