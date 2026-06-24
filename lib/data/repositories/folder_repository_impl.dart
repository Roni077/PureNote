import 'package:purenote/domain/models/folder.dart';
import 'package:purenote/data/repositories/folder_repository.dart';
import 'package:purenote/data/services/folder_local_data_source.dart';
import 'package:purenote/data/models/folder_model.dart';

class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource _dataSource;

  FolderRepositoryImpl(this._dataSource);

  @override
  Future<List<Folder>> getFolders() async {
    final models = await _dataSource.getAllFolders();
    return models.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Folder?> getFolderById(String id) async {
    final model = await _dataSource.getFolderByUuid(id);
    return model?.toDomain();
  }

  @override
  Future<void> addFolder(Folder folder) async {
    await _dataSource.saveFolder(FolderModel.fromDomain(folder));
  }

  @override
  Future<void> saveFolder(Folder folder) async {
    await _dataSource.saveFolder(FolderModel.fromDomain(folder));
  }

  @override
  Future<void> deleteFolder(String id) async {
    await _dataSource.deleteFolderByUuid(id);
  }
}
