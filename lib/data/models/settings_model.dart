import 'package:isar/isar.dart';
import 'package:purenote/domain/models/settings.dart';

part 'settings_model.g.dart';

@collection
class SettingsModel {
  Id id = 1; // Always 1 for singleton settings

  @enumerated
  late ThemeModeOption themeMode;

  late bool isAutoSaveEnabled;
  late bool isMarkdownEnabled;
  late bool hasCompletedOnboarding;

  AppSettings toDomain() {
    return AppSettings(
      themeMode: themeMode,
      isAutoSaveEnabled: isAutoSaveEnabled,
      isMarkdownEnabled: isMarkdownEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  static SettingsModel fromDomain(AppSettings settings) {
    return SettingsModel()
      ..id = 1
      ..themeMode = settings.themeMode
      ..isAutoSaveEnabled = settings.isAutoSaveEnabled
      ..isMarkdownEnabled = settings.isMarkdownEnabled
      ..hasCompletedOnboarding = settings.hasCompletedOnboarding;
  }
}
