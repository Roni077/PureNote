import 'package:isar/isar.dart';
import '../models/settings_model.dart';
import '../../domain/entities/settings.dart';
import '../../../../core/database/isar_service.dart';

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
