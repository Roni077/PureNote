import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/notes/data/models/note_model.dart';
import '../../features/folders/data/models/folder_model.dart';
import '../../features/tags/data/models/tag_model.dart';


class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          NoteModelSchema,
          FolderModelSchema,
          TagModelSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
