import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../../domain/entities/settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeModeOption>(
              value: settings.themeMode,
              onChanged: (ThemeModeOption? newValue) {
                if (newValue != null) {
                  ref.read(settingsNotifierProvider.notifier).updateThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeModeOption.system,
                  child: Text('System Default'),
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
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Editor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.save_outlined),
            title: const Text('Auto-Save'),
            subtitle: const Text('Automatically save notes while typing'),
            value: settings.isAutoSaveEnabled,
            onChanged: (bool value) {
              ref.read(settingsNotifierProvider.notifier).toggleAutoSave(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.text_format),
            title: const Text('Markdown Support'),
            subtitle: const Text('Enable markdown rendering in the editor'),
            value: settings.isMarkdownEnabled,
            onChanged: (bool value) {
              ref.read(settingsNotifierProvider.notifier).toggleMarkdown(value);
            },
          ),
        ],
      ),
    );
  }
}
