import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
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

  testWidgets('SettingsScreen renders correctly with navigation tiles', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Security'), findsOneWidget);
    expect(find.text('Data & Backup'), findsOneWidget);
    
    // Check if ListTile widgets exist
    expect(find.byType(ListTile), findsNWidgets(3));
  });
}
