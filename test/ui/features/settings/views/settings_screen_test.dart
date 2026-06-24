import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:purenote/domain/models/settings.dart';
import 'package:purenote/ui/features/settings/view_models/settings_view_model.dart';
import 'package:purenote/ui/features/settings/views/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:purenote/l10n/app_localizations.dart';

import 'package:purenote/ui/features/auth/view_models/auth_view_model.dart';

class MockSettingsViewModel extends Mock implements SettingsViewModel {}
class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockSettingsViewModel mockViewModel;
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockViewModel = MockSettingsViewModel();
    mockAuthViewModel = MockAuthViewModel();
    
    when(() => mockAuthViewModel.hasPin).thenReturn(false);
    when(() => mockAuthViewModel.canUseBiometrics).thenReturn(false);
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsViewModel>.value(value: mockViewModel),
        ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en', '')],
        home: SettingsScreen(),
      ),
    );
  }

  testWidgets('SettingsScreen renders correctly with default settings', (WidgetTester tester) async {
    when(() => mockViewModel.settings).thenReturn(AppSettings(
      themeMode: ThemeModeOption.system,
      isAutoSaveEnabled: true,
      isMarkdownEnabled: true,
    ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Auto-Save'), findsOneWidget);
    expect(find.text('Markdown Preview'), findsOneWidget);
    
    // Check if Switch widgets exist
    expect(find.byType(Switch), findsNWidgets(2));
  });

  testWidgets('SettingsScreen calls toggleAutoSave when Switch is toggled', (WidgetTester tester) async {
    when(() => mockViewModel.settings).thenReturn(AppSettings(
      themeMode: ThemeModeOption.system,
      isAutoSaveEnabled: true,
      isMarkdownEnabled: true,
    ));
    when(() => mockViewModel.toggleAutoSave(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    // Find the first switch (Auto-Save)
    final switchFinder = find.byType(Switch).first;
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    verify(() => mockViewModel.toggleAutoSave(false)).called(1);
  });
}
