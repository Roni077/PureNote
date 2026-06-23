import 'package:isar/isar.dart';
import '../models/folder_model.dart';
import '../../../../features/notes/data/models/note_model.dart';
import '../../../../core/database/isar_service.dart';

class FolderLocalDataSource {
  final IsarService _isarService;

  FolderLocalDataSource(this._isarService);

  Future<List<FolderModel>> getAllFolders() async {
    final isar = await _isarService.db;
    return await isar.folderModels.where().sortByName().findAll();
  }

  Future<FolderModel?> getFolderByUuid(String uuid) async {
    final isar = await _isarService.db;
    return await isar.folderModels.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> saveFolder(FolderModel folder) async {
    final isar = await _isarService.db;
    
    final existingFolder = await getFolderByUuid(folder.uuid);
    if (existingFolder != null) {
      folder.id = existingFolder.id;
    }

    await isar.writeTxn(() async {
      await isar.folderModels.put(folder);
    });
  }

  Future<void> deleteFolderByUuid(String uuid) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.folderModels.filter().uuidEqualTo(uuid).deleteAll();
      // Optionally remove folderId from notes here, or handle at domain layer
      final notesInFolder = await isar.noteModels.filter().folderIdEqualTo(uuid).findAll();
      for (var note in notesInFolder) {
        note.folderId = null;
        await isar.noteModels.put(note);
      }
    });
  }
}
