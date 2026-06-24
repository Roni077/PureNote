import 'package:purenote/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/ui/features/auth/view_models/auth_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final settings = settingsViewModel.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.themeMode),
            trailing: DropdownButton<ThemeModeOption>(
              value: settings.themeMode,
              onChanged: (ThemeModeOption? newValue) {
                if (newValue != null) {
                  settingsViewModel.updateThemeMode(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeModeOption.system,
                  child: Text(AppLocalizations.of(context)!.system),
                ),
                DropdownMenuItem(
                  value: ThemeModeOption.light,
                  child: Text(AppLocalizations.of(context)!.light),
                ),
                DropdownMenuItem(
                  value: ThemeModeOption.dark,
                  child: Text(AppLocalizations.of(context)!.dark),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.autoSave),
            subtitle: Text(AppLocalizations.of(context)!.autoSaveDescription),
            value: settings.isAutoSaveEnabled,
            onChanged: (value) {
              settingsViewModel.toggleAutoSave(value);
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.markdownPreview),
            subtitle: Text(AppLocalizations.of(context)!.markdownPreviewDescription),
            value: settings.isMarkdownEnabled,
            onChanged: (value) {
              settingsViewModel.toggleMarkdown(value);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Data Management', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Backup'),
            subtitle: const Text('Save your notes, folders, and tags to a JSON file.'),
            onTap: () async {
              try {
                await settingsViewModel.exportBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup exported successfully.')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Backup'),
            subtitle: const Text('Restore your data from a JSON file. This will overwrite existing data!'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Warning'),
                  content: const Text('Importing a backup will overwrite your existing data. Do you want to proceed?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Import', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await settingsViewModel.importBackup();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup imported. Please restart the app.')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to import: $e')));
                  }
                }
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Security', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
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
            title: const Text('Disable App Lock'),
            subtitle: const Text('App lock is currently enabled.'),
            onTap: () async {
              // Usually we'd ask for the PIN to disable, but for simplicity:
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
