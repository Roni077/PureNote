import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';


class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      // We will add schemas here as we create them in later phases
      return await Isar.open(
        [
          // NoteSchema,
          // FolderSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
