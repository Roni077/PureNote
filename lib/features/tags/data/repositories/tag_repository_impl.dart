import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/tag_local_data_source.dart';
import '../models/tag_model.dart';

class TagRepositoryImpl implements TagRepository {
  final TagLocalDataSource _localDataSource;

  TagRepositoryImpl(this._localDataSource);

  @override
  Future<List<Tag>> getTags() async {
    final models = await _localDataSource.getAllTags();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Tag?> getTagById(String id) async {
    final model = await _localDataSource.getTagByUuid(id);
    return model?.toDomain();
  }

  @override
  Future<void> saveTag(Tag tag) async {
    final model = TagModel.fromDomain(tag);
    await _localDataSource.saveTag(model);
  }

  @override
  Future<void> deleteTag(String id) async {
    await _localDataSource.deleteTagByUuid(id);
  }
}
