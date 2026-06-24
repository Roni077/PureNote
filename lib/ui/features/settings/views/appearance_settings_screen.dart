import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();
    final settings = settingsViewModel.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeModeOption>(
              value: settings.themeMode,
              onChanged: (ThemeModeOption? newValue) {
                if (newValue != null) {
                  settingsViewModel.updateThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeModeOption.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeModeOption.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeModeOption.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.preview),
            title: const Text('Markdown Preview'),
            subtitle: const Text('Enable split-pane markdown preview in editor'),
            value: settings.isMarkdownEnabled,
            onChanged: (value) {
              settingsViewModel.toggleMarkdown(value);
            },
          ),
        ],
      ),
    );
  }
}
