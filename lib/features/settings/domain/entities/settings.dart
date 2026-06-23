enum ThemeModeOption { system, light, dark }

class AppSettings {
  final ThemeModeOption themeMode;
  final bool isAutoSaveEnabled;
  final bool isMarkdownEnabled;

  AppSettings({
    this.themeMode = ThemeModeOption.system,
    this.isAutoSaveEnabled = true,
    this.isMarkdownEnabled = true,
  });

  AppSettings copyWith({
    ThemeModeOption? themeMode,
    bool? isAutoSaveEnabled,
    bool? isMarkdownEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      isAutoSaveEnabled: isAutoSaveEnabled ?? this.isAutoSaveEnabled,
      isMarkdownEnabled: isMarkdownEnabled ?? this.isMarkdownEnabled,
    );
  }
}
