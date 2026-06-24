import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/ui/features/auth/view_models/auth_view_model.dart';
import 'package:purenote/l10n/app_localizations.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.security),
      ),
      body: ListView(
        children: [
          _buildSecuritySettings(context),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.hasPin) {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(AppLocalizations.of(context)!.disableAppLock),
            subtitle: const Text('App lock is currently enabled.'),
            onTap: () async {
              await authViewModel.removePin();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App lock disabled.')));
              }
            },
          ),
          if (authViewModel.canUseBiometrics)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Use Biometrics'),
              subtitle: const Text('Unlock with Face ID, Touch ID, or Windows Hello.'),
              value: authViewModel.isBiometricsEnabled,
              onChanged: (value) {
                authViewModel.toggleBiometrics(value);
              },
            ),
        ],
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.lock_open),
        title: const Text('Enable App Lock'),
        subtitle: const Text('Protect your notes with a 4-digit PIN.'),
        onTap: () async {
          final pin = await _showPinSetupDialog(context);
          if (pin != null && pin.length == 4) {
            await authViewModel.setupPin(pin);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App lock enabled.')));
            }
          }
        },
      );
    }
  }

  Future<String?> _showPinSetupDialog(BuildContext context) async {
    String enteredPin = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Set 4-Digit PIN'),
            content: TextField(
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter 4 digits'),
              onChanged: (value) {
                enteredPin = value;
                if (value.length == 4) {
                  Navigator.pop(context, enteredPin);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}
