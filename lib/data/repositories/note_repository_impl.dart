import 'package:purenote/domain/models/note.dart';
import 'package:purenote/data/repositories/note_repository.dart';
import 'package:purenote/data/services/note_local_data_source.dart';
import 'package:purenote/data/models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _dataSource;

  NoteRepositoryImpl(this._dataSource);

  @override
  Future<List<Note>> getNotes() async {
    final models = await _dataSource.getAllNotes();
    return models.where((m) => !m.isTrashed).map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Note>> getTrashedNotes() async {
    final models = await _dataSource.getAllNotes();
    return models.where((m) => m.isTrashed).map((e) => e.toDomain()).toList();
  }

  @override
  Future<void> moveToTrash(String id) async {
    final note = await getNoteById(id);
    if (note != null) {
      final trashedNote = note.copyWith(isTrashed: true, updatedAt: DateTime.now());
      await updateNote(trashedNote);
    }
  }

  @override
  Future<void> restoreFromTrash(String id) async {
    final note = await getNoteById(id);
    if (note != null) {
      final restoredNote = note.copyWith(isTrashed: false, updatedAt: DateTime.now());
      await updateNote(restoredNote);
    }
  }

  @override
  Future<void> cleanUpTrash() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final trashed = await getTrashedNotes();
    final idsToDelete = trashed
        .where((n) => n.updatedAt.isBefore(thirtyDaysAgo))
        .map((n) => n.id)
        .toList();
    if (idsToDelete.isNotEmpty) {
      await deleteMultipleNotes(idsToDelete);
    }
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await _dataSource.getNoteByUuid(id);
    return model?.toDomain();
  }
  
  @override
  Future<void> addNote(Note note) async {
    await _dataSource.saveNote(NoteModel.fromDomain(note));
  }

  @override
  Future<void> updateNote(Note note) async {
    await _dataSource.saveNote(NoteModel.fromDomain(note));
  }

  @override
  Future<void> saveNote(Note note) async {
    await _dataSource.saveNote(NoteModel.fromDomain(note));
  }

  @override
  Future<void> deleteNote(String id) async {
    await _dataSource.deleteNoteByUuid(id);
  }

  @override
  Future<void> deleteMultipleNotes(List<String> ids) async {
    await _dataSource.deleteNotesByUuids(ids);
  }
}
