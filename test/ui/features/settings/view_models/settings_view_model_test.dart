import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/data/repositories/settings_repository_impl.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/data/services/backup_service.dart';

class MockSettingsRepository extends Mock implements SettingsRepositoryImpl {}
class MockBackupService extends Mock implements BackupService {}

void main() {
  late MockSettingsRepository mockRepository;
  late MockBackupService mockBackupService;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockSettingsRepository();
    mockBackupService = MockBackupService();
    registerFallbackValue(AppSettings());
  });

  group('SettingsViewModel', () {
    test('initialization fetches settings and updates state', () async {
      final mockSettings = AppSettings(themeMode: ThemeModeOption.dark);
      when(() => mockRepository.getSettings()).thenAnswer((_) async => mockSettings);

      final viewModel = SettingsViewModel(settingsRepository: mockRepository, backupService: mockBackupService);
      await Future.delayed(Duration.zero);

      expect(viewModel.settings.themeMode, ThemeModeOption.dark);
      verify(() => mockRepository.getSettings()).called(1);
    });

    test('updateThemeMode saves new settings and updates state', () async {
      when(() => mockRepository.getSettings()).thenAnswer((_) async => AppSettings());
      when(() => mockRepository.saveSettings(any())).thenAnswer((_) async => {});

      final viewModel = SettingsViewModel(settingsRepository: mockRepository, backupService: mockBackupService);
      await Future.delayed(Duration.zero);

      await viewModel.updateThemeMode(ThemeModeOption.light);

      expect(viewModel.settings.themeMode, ThemeModeOption.light);
      verify(() => mockRepository.saveSettings(any())).called(1);
    });
  });
}
