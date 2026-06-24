import 'package:isar/isar.dart';
import 'package:purenote/data/models/settings_model.dart';
import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/data/services/isar_service.dart';

class SettingsLocalDataSource {
  final IsarService _isarService;

  SettingsLocalDataSource(this._isarService);

  Future<SettingsModel> getSettings() async {
    final isar = await _isarService.db;
    final settings = await isar.settingsModels.get(1);
    
    if (settings != null) {
      return settings;
    } else {
      // Return default settings and save them
      final defaultSettings = SettingsModel()
        ..id = 1
        ..themeMode = ThemeModeOption.system
        ..isAutoSaveEnabled = true
        ..isMarkdownEnabled = true;
        
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.settingsModels.put(settings);
    });
  }
}
