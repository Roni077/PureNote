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
        ],
      ),
    );
  }
}
