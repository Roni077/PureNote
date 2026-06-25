import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:purenote/app/purenote_app.dart';
import 'package:purenote/app/dependency_injection.dart';
import 'package:purenote/ui/core/utils/error_reporter.dart';
import 'package:purenote/ui/core/config/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorReporter.initialize();

  final prefs = await SharedPreferences.getInstance();
  isFirstLaunch = !(prefs.getBool('hasCompletedOnboarding') ?? false);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1024, 768),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    const AppDependencyInjection(
      child: PureNoteApp(),
    ),
  );
}
