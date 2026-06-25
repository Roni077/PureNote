import 'package:flutter/material.dart';
import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/data/repositories/settings_repository_impl.dart';
import 'package:purenote/data/services/backup_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepositoryImpl settingsRepository;
  final BackupService backupService;
  
  AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;

  SettingsViewModel({
    required this.settingsRepository,
    required this.backupService,
  }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final result = await settingsRepository.getSettings();
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool('hasCompletedOnboarding') ?? false;
    _settings = result.copyWith(hasCompletedOnboarding: hasCompleted);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeModeOption mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleAutoSave(bool value) async {
    _settings = _settings.copyWith(isAutoSaveEnabled: value);
    await settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleMarkdown(bool value) async {
    _settings = _settings.copyWith(isMarkdownEnabled: value);
    await settingsRepository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    _settings = _settings.copyWith(hasCompletedOnboarding: true);
    notifyListeners();
  }

  Future<void> exportBackup() async {
    await backupService.exportBackup();
  }

  Future<void> importBackup() async {
    await backupService.importBackup();
  }
}
