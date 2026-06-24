import 'package:flutter/material.dart';
import 'package:purenote/domain/models/note.dart';
import 'package:purenote/ui/features/notes/views/note_card.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:purenote/l10n/app_localizations.dart';

void main() {
  runApp(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('NoteCard Preview')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              NoteCard(
                note: Note(
                  id: '1',
                  title: 'Grocery List',
                  content: '- Milk\n- Eggs\n- Bread',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
              const SizedBox(height: 16),
              NoteCard(
                note: Note(
                  id: '2',
                  title: '',
                  content: 'A note without a title to test fallback.',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
