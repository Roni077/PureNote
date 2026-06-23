import 'package:isar/isar.dart';
import '../models/tag_model.dart';
import '../../../../features/notes/data/models/note_model.dart';
import '../../../../core/database/isar_service.dart';

class TagLocalDataSource {
  final IsarService _isarService;

  TagLocalDataSource(this._isarService);

  Future<List<TagModel>> getAllTags() async {
    final isar = await _isarService.db;
    return await isar.tagModels.where().sortByName().findAll();
  }

  Future<TagModel?> getTagByUuid(String uuid) async {
    final isar = await _isarService.db;
    return await isar.tagModels.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> saveTag(TagModel tag) async {
    final isar = await _isarService.db;
    
    final existingTag = await getTagByUuid(tag.uuid);
    if (existingTag != null) {
      tag.id = existingTag.id;
    }

    await isar.writeTxn(() async {
      await isar.tagModels.put(tag);
    });
  }

  Future<void> deleteTagByUuid(String uuid) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.tagModels.filter().uuidEqualTo(uuid).deleteAll();
      
      // Remove tagId from all notes
      final notesWithTag = await isar.noteModels.filter().tagIdsElementEqualTo(uuid).findAll();
      for (var note in notesWithTag) {
        final tags = List<String>.from(note.tagIds);
        tags.remove(uuid);
        note.tagIds = tags;
        await isar.noteModels.put(note);
      }
    });
  }
}
