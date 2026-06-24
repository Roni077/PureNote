import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _pinKey = 'app_pin_hash';
  static const String _pinSaltKey = 'app_pin_salt';
  static const String _biometricsEnabledKey = 'app_biometrics_enabled';

  // --- PIN Management ---

  Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode("$pin$salt");
    return sha256.convert(bytes).toString();
  }

  Future<void> setPin(String pin) async {
    final salt = DateTime.now().millisecondsSinceEpoch.toString(); // Simple dynamic salt
    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinKey, value: _hashPin(pin, salt));
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    if (storedPin != null && storedPin.length == 4) {
      if (storedPin == pin) {
        await setPin(pin); // upgrade to hash with secure salt
        return true;
      }
      return false;
    }
    
    final storedSalt = await _secureStorage.read(key: _pinSaltKey);
    if (storedSalt != null) {
      return storedPin == _hashPin(pin, storedSalt);
    } else {
      // Fallback to static salt in case of previous upgrade
      final staticHash = _hashPin(pin, "purenote_salt_2026");
      if (storedPin == staticHash) {
        await setPin(pin); // Upgrade to dynamic salt
        return true;
      }
      return false;
    }
  }

  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _pinSaltKey);
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
