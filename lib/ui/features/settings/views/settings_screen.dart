import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Appearance'),
            subtitle: const Text('Theme mode, Markdown preview'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/appearance');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            subtitle: const Text('App lock, Biometrics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/security');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Data & Backup'),
            subtitle: const Text('Auto-save, Export & Import backups'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/backup');
            },
          ),
        ],
      ),
    );
  }
}
