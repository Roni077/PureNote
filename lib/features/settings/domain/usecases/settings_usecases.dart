import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;
  GetSettingsUseCase(this.repository);

  Future<AppSettings> execute() {
    return repository.getSettings();
  }
}

class SaveSettingsUseCase {
  final SettingsRepository repository;
  SaveSettingsUseCase(this.repository);

  Future<void> execute(AppSettings settings) {
    return repository.saveSettings(settings);
  }
}
