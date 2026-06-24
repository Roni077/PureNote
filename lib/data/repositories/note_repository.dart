import 'package:purenote/domain/models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<Note?> getNoteById(String id);
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> deleteMultipleNotes(List<String> ids);
}
