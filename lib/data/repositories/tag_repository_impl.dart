import 'package:purenote/domain/models/tag.dart';
import 'package:purenote/data/repositories/tag_repository.dart';
import 'package:purenote/data/services/tag_local_data_source.dart';
import 'package:purenote/data/models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDataSource _dataSource;

  TagRepositoryImpl(this._dataSource);

  @override
  Future<List<Tag>> getTags() async {
    final models = await _dataSource.getAllTags();
    return models.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Tag?> getTagById(String id) async {
    final model = await _dataSource.getTagByUuid(id);
    return model?.toDomain();
  }
  
  @override
  Future<void> addTag(Tag tag) async {
    await _dataSource.saveTag(TagModel.fromDomain(tag));
  }

  @override
  Future<void> saveTag(Tag tag) async {
    await _dataSource.saveTag(TagModel.fromDomain(tag));
  }

  @override
  Future<void> deleteTag(String id) async {
    await _dataSource.deleteTagByUuid(id);
  }
}
