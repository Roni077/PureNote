enum ThemeModeOption { system, light, dark }

class AppSettings {
  final ThemeModeOption themeMode;
  final bool isAutoSaveEnabled;
  final bool isMarkdownEnabled;

  final bool hasCompletedOnboarding;

  AppSettings({
    this.themeMode = ThemeModeOption.system,
    this.isAutoSaveEnabled = true,
    this.isMarkdownEnabled = true,
    this.hasCompletedOnboarding = false,
  });

  AppSettings copyWith({
    ThemeModeOption? themeMode,
    bool? isAutoSaveEnabled,
    bool? isMarkdownEnabled,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      isAutoSaveEnabled: isAutoSaveEnabled ?? this.isAutoSaveEnabled,
      isMarkdownEnabled: isMarkdownEnabled ?? this.isMarkdownEnabled,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
