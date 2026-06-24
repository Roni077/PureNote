import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';

class BackupSettingsScreen extends StatelessWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final settings = settingsViewModel.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Backup'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.save),
            title: const Text('Auto-Save'),
            subtitle: const Text('Automatically save notes while editing'),
            value: settings.isAutoSaveEnabled,
            onChanged: (value) {
              settingsViewModel.toggleAutoSave(value);
            },
          ),
          const Divider(),
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
        ],
      ),
    );
  }
}
