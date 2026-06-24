import 'package:flutter/material.dart';
import 'package:purenote/data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final AuthService authService;

  bool _isLocked = false;
  bool _hasPin = false;
  bool _isBiometricsEnabled = false;
  bool _canUseBiometrics = false;

  bool get isLocked => _isLocked;
  bool get hasPin => _hasPin;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  bool get canUseBiometrics => _canUseBiometrics;

  AuthViewModel({required this.authService}) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _lockAppIfNeeded();
    }
  }

  Future<void> _initialize() async {
    _hasPin = await authService.hasPin();
    _isBiometricsEnabled = await authService.isBiometricsEnabled();
    _canUseBiometrics = await authService.canUseBiometrics();
    
    if (_hasPin) {
      _isLocked = true;
    }
    notifyListeners();
  }

  Future<void> _lockAppIfNeeded() async {
    if (await authService.hasPin() && !_isLocked) {
      _isLocked = true;
      notifyListeners();
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    final success = await authService.verifyPin(pin);
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_isBiometricsEnabled) return false;
    
    final success = await authService.authenticateWithBiometrics('Unlock PureNote');
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
    return success;
  }

  Future<void> setupPin(String pin) async {
    await authService.setPin(pin);
    _hasPin = true;
    notifyListeners();
  }

  Future<void> removePin() async {
    await authService.removePin();
    _hasPin = false;
    _isBiometricsEnabled = false;
    _isLocked = false;
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool value) async {
    await authService.setBiometricsEnabled(value);
    _isBiometricsEnabled = value;
    notifyListeners();
  }
}
