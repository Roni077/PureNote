import 'package:purenote/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';

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
        ],
      ),
    );
  }
}
