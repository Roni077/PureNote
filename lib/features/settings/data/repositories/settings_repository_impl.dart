import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<AppSettings> getSettings() async {
    final model = await _localDataSource.getSettings();
    return model.toDomain();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final model = SettingsModel.fromDomain(settings);
    await _localDataSource.saveSettings(model);
  }
}
