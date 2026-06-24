import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:purenote/ui/core/theme/app_theme.dart';
import 'package:purenote/ui/core/config/router/app_router.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/ui/features/auth/view_models/auth_view_model.dart';
import 'package:purenote/ui/features/auth/views/lock_screen.dart';
import 'package:purenote/l10n/app_localizations.dart';

class PureNoteApp extends StatelessWidget {
  const PureNoteApp({super.key});

  ThemeMode _getThemeMode(dynamic option) {
    if (option.toString() == 'ThemeModeOption.light') return ThemeMode.light;
    if (option.toString() == 'ThemeModeOption.dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsViewModel, child) {
        return MaterialApp.router(
          title: 'PureNote',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _getThemeMode(settingsViewModel.settings.themeMode),
          routerConfig: appRouter,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          debugShowCheckedModeBanner: false,
          builder: (context, routerChild) {
            return Consumer<AuthViewModel>(
              builder: (context, authViewModel, _) {
                return Stack(
                  children: [
                    if (routerChild != null) routerChild,
                    if (authViewModel.isLocked) const LockScreen(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
