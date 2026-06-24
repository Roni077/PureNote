import 'package:purenote/domain/models/note.dart';
import 'package:purenote/data/repositories/note_repository.dart';
import 'package:purenote/data/services/note_local_data_source.dart';
import 'package:purenote/data/services/sync_service.dart';
import 'package:purenote/data/models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _dataSource;
  final SyncService _syncService;

  NoteRepositoryImpl(this._dataSource, this._syncService);

  Future<SyncResponse> syncWithCloud() async {
    final models = await _dataSource.getAllNotes();
    final notes = models.map((e) => e.toDomain()).toList();
    return await _syncService.syncNotes(notes);
  }

  @override
  Future<List<Note>> getNotes() async {
    final models = await _dataSource.getAllNotes();
    return models.map((e) => e.toDomain()).toList();
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
