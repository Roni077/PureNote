// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PureNote';

  @override
  String get notes => 'Notes';

  @override
  String get folders => 'Folders';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search notes...';

  @override
  String get noNotes => 'No notes found';

  @override
  String get untitled => 'Untitled';

  @override
  String get titleHint => 'Title';

  @override
  String get contentHint => 'Start writing...';

  @override
  String get autoSave => 'Auto-Save';

  @override
  String get autoSaveDescription => 'Automatically save notes while editing';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get markdownPreview => 'Markdown Preview';

  @override
  String get markdownPreviewDescription =>
      'Enable markdown rendering in view mode';

  @override
  String get addFolder => 'Add Folder';

  @override
  String get folderNameHint => 'Folder Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get deleteFolder => 'Delete Folder';

  @override
  String get deleteFolderConfirm =>
      'Are you sure you want to delete this folder?';

  @override
  String get delete => 'Delete';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get deleteNoteConfirm => 'Are you sure you want to delete this note?';

  @override
  String get newFolder => 'New Folder';

  @override
  String get create => 'Create';

  @override
  String get allNotes => 'All Notes';

  @override
  String get tags => 'Tags';

  @override
  String get newTag => 'New Tag';

  @override
  String get syncNotes => 'Sync Notes';

  @override
  String get selected => ' selected';

  @override
  String get sortByDateModified => 'Sort by Date Modified';

  @override
  String get sortByDateCreated => 'Sort by Date Created';

  @override
  String get sortByTitle => 'Sort by Title (A-Z)';

  @override
  String get noNotesFound => 'No notes found.';

  @override
  String get searchApplied =>
      'Search applied. Please press back to view results.';

  @override
  String get appSettings => 'App Settings';
}
