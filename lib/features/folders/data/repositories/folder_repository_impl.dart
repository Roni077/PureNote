import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/folder_local_data_source.dart';
import '../models/folder_model.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource _localDataSource;

  FolderRepositoryImpl(this._localDataSource);

  @override
  Future<List<Folder>> getFolders() async {
    final models = await _localDataSource.getAllFolders();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Folder?> getFolderById(String id) async {
    final model = await _localDataSource.getFolderByUuid(id);
    return model?.toDomain();
  }

  @override
  Future<void> saveFolder(Folder folder) async {
    final model = FolderModel.fromDomain(folder);
    await _localDataSource.saveFolder(model);
  }

  @override
  Future<void> deleteFolder(String id) async {
    await _localDataSource.deleteFolderByUuid(id);
  }
}
