import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/ui/features/notes/views/note_card.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:purenote/l10n/app_localizations.dart';

void main() {
  testWidgets('NoteCard renders note title and content correctly', (WidgetTester tester) async {
    final note = Note(
      id: '1',
      title: 'Hello World',
      content: 'This is a test note content.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        home: Scaffold(
          body: NoteCard(note: note),
        ),
      ),
    );

    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('This is a test note content.'), findsOneWidget);
  });

  testWidgets('NoteCard renders Untitled if title is empty', (WidgetTester tester) async {
    final note = Note(
      id: '2',
      title: '',
      content: 'No title note',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        home: Scaffold(
          body: NoteCard(note: note),
        ),
      ),
    );

    expect(find.text('Untitled'), findsOneWidget);
    expect(find.text('No title note'), findsOneWidget);
  });
}
