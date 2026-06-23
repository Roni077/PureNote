import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/settings/domain/entities/settings.dart';

class PureNoteApp extends ConsumerWidget {
  const PureNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    final settingsState = ref.watch(settingsNotifierProvider);
    
    ThemeMode themeMode = ThemeMode.system;
    if (settingsState.settings.themeMode == ThemeModeOption.light) {
      themeMode = ThemeMode.light;
    } else if (settingsState.settings.themeMode == ThemeModeOption.dark) {
      themeMode = ThemeMode.dark;
    }

    return MaterialApp.router(
      title: 'PureNote',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
