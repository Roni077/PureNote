import '../entities/folder.dart';
import '../repositories/folder_repository.dart';

class GetFoldersUseCase {
  final FolderRepository repository;
  GetFoldersUseCase(this.repository);

  Future<List<Folder>> execute() {
    return repository.getFolders();
  }
}

class CreateFolderUseCase {
  final FolderRepository repository;
  CreateFolderUseCase(this.repository);

  Future<void> execute(Folder folder) {
    return repository.saveFolder(folder);
  }
}

class DeleteFolderUseCase {
  final FolderRepository repository;
  DeleteFolderUseCase(this.repository);

  Future<void> execute(String id) {
    return repository.deleteFolder(id);
  }
}
