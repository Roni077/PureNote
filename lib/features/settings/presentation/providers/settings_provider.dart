import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../../../app/app_providers.dart';

// Use Cases & Repository Providers
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return SettingsLocalDataSource(isarService);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});

final getSettingsUseCaseProvider = Provider<GetSettingsUseCase>((ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final saveSettingsUseCaseProvider = Provider<SaveSettingsUseCase>((ref) {
  return SaveSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

// State classes
class SettingsState {
  final AppSettings settings;
  final bool isLoading;

  SettingsState({
    required this.settings,
    this.isLoading = true,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// State Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final GetSettingsUseCase _getSettings;
  final SaveSettingsUseCase _saveSettings;

  SettingsNotifier(this._getSettings, this._saveSettings)
      : super(SettingsState(settings: AppSettings())) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    final settings = await _getSettings.execute();
    state = state.copyWith(settings: settings, isLoading: false);
  }

  Future<void> updateThemeMode(ThemeModeOption mode) async {
    final updated = state.settings.copyWith(themeMode: mode);
    await _saveSettings.execute(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> toggleAutoSave(bool value) async {
    final updated = state.settings.copyWith(isAutoSaveEnabled: value);
    await _saveSettings.execute(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> toggleMarkdown(bool value) async {
    final updated = state.settings.copyWith(isMarkdownEnabled: value);
    await _saveSettings.execute(updated);
    state = state.copyWith(settings: updated);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    ref.watch(getSettingsUseCaseProvider),
    ref.watch(saveSettingsUseCaseProvider),
  );
});
