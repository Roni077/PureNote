import '../entities/folder.dart';

abstract class FolderRepository {
  Future<List<Folder>> getFolders();
  Future<Folder?> getFolderById(String id);
  Future<void> saveFolder(Folder folder);
  Future<void> deleteFolder(String id);
}
