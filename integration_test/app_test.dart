import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:purenote/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('create a new note, write content, and verify it exists',
        (tester) async {
      // Start the app
      app.main();
      
      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Ensure we are on the Home screen
      expect(find.text('PureNote'), findsOneWidget);

      // Tap the FAB to create a new note
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // We should be on the Editor screen now.
      // Find the text fields for Title and Content
      final titleField = find.byType(TextField).first;
      final contentField = find.byType(TextField).last;

      // Enter text
      await tester.enterText(titleField, 'Integration Test Note');
      await tester.enterText(contentField, 'This note was created automatically via an integration test.');
      await tester.pumpAndSettle();

      // Tap the back button (or save button) to return to the home screen
      // Assuming there's a back button or an explicit save button. 
      // Let's just find the back button in the AppBar.
      final backButton = find.byTooltip('Back');
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
      } else {
        // Alternatively, use pop
        Navigator.pop(tester.element(titleField));
      }
      await tester.pumpAndSettle();

      // We should be back on the Home screen.
      // Verify that the new note's title is displayed.
      expect(find.text('Integration Test Note'), findsWidgets);
    });
  });
}
