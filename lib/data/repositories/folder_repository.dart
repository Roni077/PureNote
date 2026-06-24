import 'package:purenote/domain/models/folder.dart';

abstract class FolderRepository {
  Future<List<Folder>> getFolders();
  Future<Folder?> getFolderById(String id);
  Future<void> addFolder(Folder folder);
  Future<void> saveFolder(Folder folder);
  Future<void> deleteFolder(String id);
}
