import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/ui/features/auth/view_models/auth_view_model.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometrics();
    });
  }

  Future<void> _checkBiometrics() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.isBiometricsEnabled && authViewModel.canUseBiometrics) {
      await authViewModel.authenticateWithBiometrics();
    }
  }

  void _onKeypadPressed(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _error = '';
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.authenticateWithPin(_pin);
    
    if (!success) {
      setState(() {
        _error = 'Incorrect PIN';
        _pin = '';
      });
    }
  }

  Widget _buildKeypadButton(String digit) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _onKeypadPressed(digit),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIndicator() {
    final authViewModel = context.watch<AuthViewModel>();
    
    if (authViewModel.isBiometricsEnabled && authViewModel.canUseBiometrics) {
      return IconButton(
        icon: const Icon(Icons.fingerprint, size: 40),
        onPressed: _checkBiometrics,
      );
    }
    return const SizedBox(width: 80, height: 80);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Enter PIN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                );
              }),
            ),
            const SizedBox(height: 64),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['1', '2', '3'].map(_buildKeypadButton).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['4', '5', '6'].map(_buildKeypadButton).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['7', '8', '9'].map(_buildKeypadButton).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionIndicator(),
                    _buildKeypadButton('0'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: _onBackspace,
                        borderRadius: BorderRadius.circular(40),
                        child: const SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(
                            child: Icon(Icons.backspace_outlined, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
