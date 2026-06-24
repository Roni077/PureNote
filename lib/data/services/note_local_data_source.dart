import 'package:isar/isar.dart';
import 'package:purenote/data/models/note_model.dart';
import 'package:purenote/data/services/isar_service.dart';

class NoteLocalDataSource {
  final IsarService _isarService;

  NoteLocalDataSource(this._isarService);

  Future<List<NoteModel>> getAllNotes() async {
    final isar = await _isarService.db;
    return await isar.noteModels.where().sortByUpdatedAtDesc().findAll();
  }

  Future<NoteModel?> getNoteByUuid(String uuid) async {
    final isar = await _isarService.db;
    return await isar.noteModels.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> saveNote(NoteModel note) async {
    final isar = await _isarService.db;
    
    // We need to keep the Isar auto-increment ID if the note already exists
    final existingNote = await getNoteByUuid(note.uuid);
    if (existingNote != null) {
      note.id = existingNote.id;
    }

    await isar.writeTxn(() async {
      await isar.noteModels.put(note);
    });
  }

  Future<void> deleteNoteByUuid(String uuid) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.noteModels.filter().uuidEqualTo(uuid).deleteAll();
    });
  }

  Future<void> deleteNotesByUuids(List<String> uuids) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.noteModels.filter().anyOf(uuids, (q, uuid) => q.uuidEqualTo(uuid)).deleteAll();
    });
  }
}
