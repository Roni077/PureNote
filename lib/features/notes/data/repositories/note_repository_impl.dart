import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _localDataSource;

  NoteRepositoryImpl(this._localDataSource);

  @override
  Future<List<Note>> getNotes() async {
    final models = await _localDataSource.getAllNotes();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await _localDataSource.getNoteByUuid(id);
    return model?.toDomain();
  }

  @override
  Future<void> saveNote(Note note) async {
    final model = NoteModel.fromDomain(note);
    await _localDataSource.saveNote(model);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _localDataSource.deleteNoteByUuid(id);
  }

  @override
  Future<void> deleteNotes(List<String> ids) async {
    await _localDataSource.deleteNotesByUuids(ids);
  }
}
