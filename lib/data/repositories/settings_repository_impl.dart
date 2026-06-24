import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/data/repositories/settings_repository.dart';
import 'package:purenote/data/services/settings_local_data_source.dart';
import 'package:purenote/data/models/settings_model.dart';

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
